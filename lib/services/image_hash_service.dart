import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Perceptual Hash (Average Hash / aHash) untuk image matching tanpa library tambahan.
///
/// Cara kerja:
///   1. Resize gambar ke 8×8 pixel
///   2. Convert ke grayscale
///   3. Bandingkan tiap pixel ke rata-rata → hasilkan 64-bit hash (8 bytes)
///   4. Bandingkan dua gambar via Hamming distance (0 = identik, 64 = total berbeda)
///
/// Threshold default: distance ≤ 12 (~81% mirip) dianggap match.
class ImageHashService {
  static final ImageHashService _instance = ImageHashService._internal();
  factory ImageHashService() => _instance;
  ImageHashService._internal();

  /// Hash referensi: productName → 8-byte aHash
  final Map<String, Uint8List> _referenceHashes = {};
  bool _isReady = false;

  bool get isReady => _isReady;
  int get referenceCount => _referenceHashes.length;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Download semua gambar referensi dan hitung hash-nya.
  /// Dipanggil setelah ImageTargets dimuat dari Supabase.
  Future<void> buildReferenceHashes(
      List<({String name, String imageUrl})> targets) async {
    _referenceHashes.clear();
    _isReady = false;

    debugPrint('🔢 Building pHash for ${targets.length} image targets...');

    final client = Supabase.instance.client;

    for (final t in targets) {
      if (t.imageUrl.isEmpty) continue;
      try {
        // Download bytes via Supabase HTTP client
        final bytes = await client.storage
            .from('image_target')
            .download(_extractStoragePath(t.imageUrl));

        final hash = await _computeHash(bytes);
        if (hash != null) {
          _referenceHashes[t.name] = hash;
          debugPrint('  ✅ ${t.name}');
        }
      } catch (e) {
        // Fallback: coba download langsung via Dart HttpClient
        try {
          final bytes = await _downloadBytes(t.imageUrl);
          if (bytes != null) {
            final hash = await _computeHash(bytes);
            if (hash != null) {
              _referenceHashes[t.name] = hash;
              debugPrint('  ✅ ${t.name} (fallback)');
            }
          }
        } catch (e2) {
          debugPrint('  ❌ ${t.name}: $e2');
        }
      }
    }

    _isReady = true;
    debugPrint('🔢 pHash ready: ${_referenceHashes.length}/${targets.length}');
  }

  /// Cocokkan foto kamera (path file) dengan semua referensi.
  /// Return nama produk terbaik, atau null jika tidak ada yang mirip.
  Future<String?> findBestMatch(String imagePath, {int maxDistance = 12}) async {
    if (_referenceHashes.isEmpty) return null;

    Uint8List queryBytes;
    try {
      queryBytes = await File(imagePath).readAsBytes();
    } catch (e) {
      debugPrint('pHash: cannot read file: $e');
      return null;
    }

    final queryHash = await _computeHash(queryBytes);
    if (queryHash == null) return null;

    String? bestName;
    int bestDist = maxDistance + 1;

    for (final entry in _referenceHashes.entries) {
      final dist = _hammingDistance(queryHash, entry.value);
      debugPrint('  pHash [${entry.key}]: dist=$dist');
      if (dist < bestDist) {
        bestDist = dist;
        bestName = entry.key;
      }
    }

    if (bestName != null) {
      debugPrint('✓ pHash match: $bestName (dist=$bestDist)');
    } else {
      debugPrint('✗ pHash: no match (threshold=$maxDistance)');
    }

    return bestName;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Future<Uint8List?> _computeHash(Uint8List imageBytes) async {
    return compute(_aHashIsolate, imageBytes);
  }

  int _hammingDistance(Uint8List a, Uint8List b) {
    int dist = 0;
    for (int i = 0; i < 8; i++) {
      int xor = a[i] ^ b[i];
      while (xor != 0) {
        dist++;
        xor &= xor - 1;
      }
    }
    return dist;
  }

  /// Ekstrak path relatif dari public URL Supabase storage.
  /// Contoh: https://xxx.supabase.co/storage/v1/object/public/image_target/image_targets/foo.jpg
  ///       → image_targets/foo.jpg
  String _extractStoragePath(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      // Cari index setelah nama bucket "image_target"
      final bucketIdx = segments.indexOf('image_target');
      if (bucketIdx != -1 && bucketIdx + 1 < segments.length) {
        return segments.sublist(bucketIdx + 1).join('/');
      }
      // Fallback: ambil segment setelah 'public'
      final publicIdx = segments.indexOf('public');
      if (publicIdx != -1 && publicIdx + 2 < segments.length) {
        return segments.sublist(publicIdx + 2).join('/');
      }
    } catch (_) {}
    return url;
  }

  Future<Uint8List?> _downloadBytes(String url) async {
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) return null;
    final chunks = <int>[];
    await for (final chunk in response) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }
}

// ─── Isolate function ─────────────────────────────────────────────────────────

/// Decode image bytes → grayscale 8×8 → 64-bit aHash.
/// Top-level agar bisa dipanggil via compute().
Future<Uint8List?> _aHashIsolate(Uint8List bytes) async {
  try {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 8,
      targetHeight: 8,
    );
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    img.dispose();
    if (byteData == null) return null;

    final rgba = byteData.buffer.asUint8List();

    // RGBA → grayscale (luminance)
    final gray = List<int>.generate(64, (i) {
      final o = i * 4;
      return (0.299 * rgba[o] + 0.587 * rgba[o + 1] + 0.114 * rgba[o + 2])
          .round();
    });

    final avg = gray.fold(0, (s, v) => s + v) ~/ 64;

    final hash = Uint8List(8);
    for (int i = 0; i < 64; i++) {
      if (gray[i] >= avg) {
        hash[i ~/ 8] |= (1 << (7 - (i % 8)));
      }
    }
    return hash;
  } catch (_) {
    return null;
  }
}
