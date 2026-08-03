import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cache file GLB ke local storage agar model 3D load instan tanpa download ulang.
class ModelCacheService {
  static final ModelCacheService _instance = ModelCacheService._internal();
  factory ModelCacheService() => _instance;
  ModelCacheService._internal();

  /// localPath: productName → absolute path file GLB di device
  final Map<String, String> _localPaths = {};

  bool get hasCache => _localPaths.isNotEmpty;

  /// Preload semua GLB dari daftar model URL.
  /// [models] = list of {name, url}
  /// Dipanggil di DataCacheService.preFetchData setelah image targets loaded.
  Future<void> preloadModels(
      List<({String name, String url})> models) async {
    final cacheDir = await _getCacheDir();
    debugPrint('📦 Preloading ${models.length} GLB models...');

    for (final m in models) {
      if (m.url.isEmpty) continue;

      final fileName = _fileNameFromUrl(m.url);
      final localFile = File('${cacheDir.path}/$fileName');

      // Sudah ada di disk → langsung pakai
      if (await localFile.exists()) {
        _localPaths[m.name] = localFile.path;
        debugPrint('  ✅ ${m.name} (cached)');
        continue;
      }

      // Belum ada → download
      try {
        final bytes = await _downloadGlb(m.url);
        if (bytes != null && bytes.isNotEmpty) {
          await localFile.writeAsBytes(bytes, flush: true);
          _localPaths[m.name] = localFile.path;
          debugPrint('  ⬇️  ${m.name} downloaded (${bytes.length ~/ 1024} KB)');
        }
      } catch (e) {
        debugPrint('  ❌ ${m.name}: $e');
        // Tidak fatal — fallback ke URL remote tetap jalan
      }
    }

    debugPrint('📦 Preload done: ${_localPaths.length}/${models.length} cached');
  }

  /// Kembalikan `file://…` path jika sudah dicache, atau URL remote sebagai fallback.
  String resolveModelSrc(String name, String remoteUrl) {
    final local = _localPaths[name];
    if (local != null && File(local).existsSync()) {
      // ModelViewer membutuhkan URI dengan scheme
      return Uri.file(local).toString();
    }
    return remoteUrl;
  }

  /// Hapus cache lama (opsional, panggil saat update data)
  Future<void> clearCache() async {
    final cacheDir = await _getCacheDir();
    try {
      final files = cacheDir.listSync();
      for (final f in files) {
        if (f.path.endsWith('.glb')) await f.delete();
      }
    } catch (_) {}
    _localPaths.clear();
    debugPrint('🗑️ GLB cache cleared');
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Future<Directory> _getCacheDir() async {
    final base = await getApplicationCacheDirectory();
    final dir = Directory('${base.path}/glb_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _fileNameFromUrl(String url) {
    // Ambil nama file dari URL, e.g. "dayana_blue.glb"
    final uri = Uri.parse(url);
    return uri.pathSegments.last;
  }

  Future<Uint8List?> _downloadGlb(String url) async {
    try {
      // Coba via Supabase storage download (lebih cepat, auth otomatis)
      if (url.contains('supabase.co')) {
        final client = Supabase.instance.client;
        final path = _extractStoragePath(url);
        final bucket = _extractBucket(url);
        if (path.isNotEmpty && bucket.isNotEmpty) {
          return await client.storage.from(bucket).download(path);
        }
      }
    } catch (_) {}

    // Fallback: HTTP download biasa
    final request = await HttpClient()
        .getUrl(Uri.parse(url))
        .timeout(const Duration(seconds: 60));
    final response = await request.close()
        .timeout(const Duration(seconds: 60));
    if (response.statusCode != 200) return null;

    final chunks = <int>[];
    await for (final chunk in response) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }

  String _extractBucket(String url) {
    try {
      final uri = Uri.parse(url);
      // URL format: .../storage/v1/object/public/<bucket>/...
      final segments = uri.pathSegments;
      final publicIdx = segments.indexOf('public');
      if (publicIdx != -1 && publicIdx + 1 < segments.length) {
        return segments[publicIdx + 1];
      }
    } catch (_) {}
    return '';
  }

  String _extractStoragePath(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final publicIdx = segments.indexOf('public');
      if (publicIdx != -1 && publicIdx + 2 < segments.length) {
        return segments.sublist(publicIdx + 2).join('/');
      }
    } catch (_) {}
    return '';
  }
}
