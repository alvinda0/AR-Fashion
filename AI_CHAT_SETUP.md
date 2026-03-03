# Setup AI Chat dengan Hugging Face

## Langkah-langkah Setup

### 1. Dapatkan API Key dari Hugging Face

1. Buka [https://huggingface.co/](https://huggingface.co/)
2. Buat akun atau login
3. Pergi ke Settings → Access Tokens: [https://huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)
4. Klik "New token"
5. Beri nama token (misalnya: "AR Fashion App")
6. Pilih role "read"
7. Copy token yang dihasilkan

### 2. Masukkan API Key ke Aplikasi

Buka file `lib/services/huggingface_service.dart` dan ganti:

```dart
static const String _apiKey = 'YOUR_HUGGINGFACE_API_KEY';
```

Dengan API key Anda:

```dart
static const String _apiKey = 'hf_xxxxxxxxxxxxxxxxxxxxx';
```

### 3. Install Dependencies

Jalankan perintah:

```bash
flutter pub get
```

### 4. Jalankan Aplikasi

```bash
flutter run
```

## Model yang Digunakan

Aplikasi ini menggunakan model `microsoft/DialoGPT-medium` untuk percakapan.

### Model Alternatif

Anda bisa mengganti model dengan yang lain:

1. **DialoGPT-small** (lebih cepat, lebih ringan)
   ```dart
   static const String _model = 'microsoft/DialoGPT-small';
   ```

2. **DialoGPT-large** (lebih akurat, lebih lambat)
   ```dart
   static const String _model = 'microsoft/DialoGPT-large';
   ```

3. **Blenderbot** (Facebook's conversational AI)
   ```dart
   static const String _model = 'facebook/blenderbot-400M-distill';
   ```

4. **GPT-2** (text generation)
   ```dart
   static const String _model = 'gpt2';
   ```

## Fitur Chat AI

- ✅ Percakapan interaktif dengan AI
- ✅ Context-aware (mengingat percakapan sebelumnya)
- ✅ UI chat modern dengan bubble messages
- ✅ Loading indicator saat AI mengetik
- ✅ Scroll otomatis ke pesan terbaru
- ✅ Support multi-line input

## Troubleshooting

### Error 503: Model Loading

Jika mendapat error 503, tunggu beberapa detik dan coba lagi. Model Hugging Face perlu waktu untuk "warm up" saat pertama kali digunakan.

### Error 401: Unauthorized

Pastikan API key Anda valid dan sudah dimasukkan dengan benar di `huggingface_service.dart`.

### Respons Lambat

Model inference API gratis dari Hugging Face bisa lambat. Untuk performa lebih baik:
- Gunakan model yang lebih kecil (DialoGPT-small)
- Pertimbangkan upgrade ke Hugging Face Pro
- Atau deploy model sendiri

## Customization

### Mengubah Personality AI

Edit welcome message di `ai_chat_screen.dart`:

```dart
_messages.add(
  ChatMessage(
    text: 'Halo! Saya adalah AI assistant untuk AR Fashion. Ada yang bisa saya bantu?',
    isUser: false,
  ),
);
```

### Mengubah Parameter Model

Edit di `huggingface_service.dart`:

```dart
'parameters': {
  'max_length': 100,      // Panjang maksimal respons
  'temperature': 0.7,     // Kreativitas (0.0-1.0)
  'top_p': 0.9,          // Nucleus sampling
  'do_sample': true,     // Enable sampling
},
```

## Catatan Penting

- API key gratis Hugging Face memiliki rate limit
- Model inference bisa lambat pada penggunaan pertama
- Untuk production, pertimbangkan hosting model sendiri
- Jangan commit API key ke repository publik

## Resources

- [Hugging Face Documentation](https://huggingface.co/docs)
- [Inference API Docs](https://huggingface.co/docs/api-inference/index)
- [Available Models](https://huggingface.co/models)
