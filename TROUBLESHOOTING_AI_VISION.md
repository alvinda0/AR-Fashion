# Troubleshooting AI Vision Chat

## Error: "Connection closed before full header was received"

### Penyebab:
1. **Model Cold Start** - Model perlu waktu untuk "bangun" saat pertama kali digunakan (20-60 detik)
2. **Timeout** - Request membutuhkan waktu lebih lama dari yang diharapkan
3. **Gambar Terlalu Besar** - File gambar > 5MB menyebabkan timeout
4. **Koneksi Internet Lambat** - Upload gambar memakan waktu lama
5. **API Key Salah** - Token tidak valid atau expired

### Solusi yang Sudah Diterapkan:

✅ **Timeout diperpanjang menjadi 60 detik**
```dart
.timeout(const Duration(seconds: 60))
```

✅ **Retry Logic** - Otomatis mencoba ulang 2x jika gagal
```dart
maxRetries = 2
```

✅ **Validasi Ukuran Gambar** - Maksimal 5MB
```dart
if (imageBytes.length > 5 * 1024 * 1024) {
  return 'Error: Ukuran gambar terlalu besar. Maksimal 5MB.';
}
```

✅ **History Dibatasi** - Hanya 10 pesan terakhir dikirim
```dart
final recentHistory = conversationHistory.length > 10 
    ? conversationHistory.sublist(conversationHistory.length - 10)
    : conversationHistory;
```

✅ **Loading Message Dinamis** - Memberitahu user apa yang sedang terjadi

### Cara Mengatasi:

#### 1. Tunggu dan Coba Lagi
Jika pertama kali menggunakan model:
- Tunggu 30-60 detik
- Coba kirim pesan lagi
- Model akan lebih cepat setelah "warm up"

#### 2. Kompres Gambar
Jika gambar terlalu besar:
```dart
final XFile? image = await _imagePicker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1024,      // Sudah diset
  maxHeight: 1024,     // Sudah diset
  imageQuality: 85,    // Sudah diset
);
```

#### 3. Periksa Koneksi Internet
- Pastikan koneksi stabil
- Gunakan WiFi jika memungkinkan
- Hindari menggunakan saat koneksi lemah

#### 4. Verifikasi API Key
Buka `lib/services/huggingface_service.dart`:
```dart
static const String _apiKey = 'hf_xxxxxxxxxxxxx';
```

Pastikan token:
- Dimulai dengan `hf_`
- Masih valid (cek di https://huggingface.co/settings/tokens)
- Memiliki permission yang benar

#### 5. Coba Model Alternatif
Jika masalah berlanjut, ganti model di `huggingface_service.dart`:

```dart
// Model saat ini (lebih lambat tapi lebih akurat)
static const String _visionModel = 'Qwen/Qwen3.5-35B-A3B:novita';

// Alternatif 1: Lebih cepat
static const String _visionModel = 'microsoft/Phi-3.5-vision-instruct';

// Alternatif 2: Balanced
static const String _visionModel = 'meta-llama/Llama-3.2-11B-Vision-Instruct';
```

## Error Lainnya

### Error 401: Unauthorized
**Penyebab**: API key tidak valid

**Solusi**:
1. Buat token baru di https://huggingface.co/settings/tokens
2. Pastikan memilih permission "Read"
3. Copy token dan paste ke `_apiKey`

### Error 429: Too Many Requests
**Penyebab**: Terlalu banyak request dalam waktu singkat

**Solusi**:
- Tunggu 1-2 menit
- Kurangi frekuensi request
- Pertimbangkan upgrade ke Hugging Face Pro

### Error 503: Service Unavailable
**Penyebab**: Model sedang loading atau server sibuk

**Solusi**:
- Tunggu 10-20 detik
- Coba lagi
- Aplikasi akan otomatis retry 2x

### Gambar Tidak Muncul di Chat
**Penyebab**: Permission tidak diberikan

**Solusi Android**:
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

**Solusi iOS**:
```xml
<!-- ios/Runner/Info.plist -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Pilih gambar untuk analisis AI</string>
```

### Response Lambat
**Tips untuk mempercepat**:

1. **Kurangi ukuran gambar**:
```dart
maxWidth: 800,   // Dari 1024
maxHeight: 800,  // Dari 1024
imageQuality: 70, // Dari 85
```

2. **Kurangi max_tokens**:
```dart
'max_tokens': 300, // Dari 500
```

3. **Batasi history**:
```dart
final recentHistory = conversationHistory.length > 6 
    ? conversationHistory.sublist(conversationHistory.length - 6)
    : conversationHistory;
```

## Testing Connection

Untuk test koneksi tanpa gambar:

```dart
// Test sederhana
final response = await _aiService.sendMessage('Hello');
print(response);
```

Jika text-only berhasil tapi dengan gambar gagal:
- Masalah ada di ukuran/format gambar
- Coba gambar yang lebih kecil

## Monitoring

Tambahkan logging untuk debug:

```dart
print('Sending message with image: ${imagePath != null}');
print('Image size: ${imageBytes.length} bytes');
print('Response status: ${response.statusCode}');
```

## Kapan Harus Ganti Provider?

Jika masalah terus berlanjut setelah semua solusi dicoba:

1. **Pertimbangkan provider lain**:
   - OpenAI GPT-4 Vision
   - Google Gemini Vision
   - Anthropic Claude 3

2. **Atau gunakan Hugging Face Inference API langsung**:
   - Lebih stabil
   - Tapi perlu setup berbeda

## Kontak Support

- Hugging Face Forum: https://discuss.huggingface.co/
- GitHub Issues: https://github.com/huggingface/huggingface_hub/issues
- Discord: https://hf.co/join/discord
