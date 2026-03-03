# Fitur AI Chat Assistant

## Overview

Fitur AI Chat Assistant telah ditambahkan ke aplikasi AR Fashion menggunakan Hugging Face API. Pengguna dapat berinteraksi dengan AI untuk mendapatkan bantuan, informasi produk, atau sekadar bercakap-cakap.

## Struktur File Baru

```
lib/
├── models/
│   └── chat_message.dart          # Model data untuk pesan chat
├── screens/
│   └── ai_chat_screen.dart        # UI halaman chat
└── services/
    └── huggingface_service.dart   # Service untuk API Hugging Face
```

## Cara Menggunakan

1. **Setup API Key**
   - Dapatkan API key dari [Hugging Face](https://huggingface.co/settings/tokens)
   - Masukkan ke `lib/services/huggingface_service.dart`

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

4. **Akses Chat**
   - Buka aplikasi
   - Pilih menu "AI Chat" dari home screen
   - Mulai chat dengan AI assistant

## Fitur Utama

### 1. Conversational AI
- Menggunakan model DialoGPT dari Microsoft
- Context-aware (mengingat percakapan sebelumnya)
- Natural language processing

### 2. Modern Chat UI
- Bubble messages untuk user dan bot
- Avatar icons untuk identifikasi
- Smooth scrolling
- Loading indicator

### 3. User Experience
- Auto-scroll ke pesan terbaru
- Multi-line text input
- Send dengan tombol atau Enter
- Responsive design

## Contoh Percakapan

```
User: Halo, apa itu AR Fashion?
Bot: AR Fashion adalah aplikasi yang memungkinkan Anda melihat produk fashion dalam 3D menggunakan teknologi Augmented Reality.

User: Bagaimana cara menggunakannya?
Bot: Cukup scan gambar produk dengan kamera, dan model 3D akan muncul di layar Anda.
```

## Customization

### Mengubah Model AI

Edit di `huggingface_service.dart`:

```dart
static const String _model = 'microsoft/DialoGPT-medium';
```

Model alternatif:
- `microsoft/DialoGPT-small` - Lebih cepat
- `microsoft/DialoGPT-large` - Lebih akurat
- `facebook/blenderbot-400M-distill` - Conversational AI
- `gpt2` - Text generation

### Mengubah Warna Tema

Edit di `ai_chat_screen.dart`:

```dart
backgroundColor: const Color(0xFF00796B),  // Warna app bar
color: const Color(0xFF00796B),            // Warna bubble user
```

### Mengubah Welcome Message

```dart
_messages.add(
  ChatMessage(
    text: 'Pesan sambutan Anda di sini',
    isUser: false,
  ),
);
```

## API Configuration

### Parameters yang Bisa Diatur

```dart
'parameters': {
  'max_length': 100,      // Panjang respons (20-200)
  'temperature': 0.7,     // Kreativitas (0.1-1.0)
  'top_p': 0.9,          // Sampling (0.1-1.0)
  'do_sample': true,     // Enable random sampling
},
```

### Rate Limits

Hugging Face Free Tier:
- 30,000 requests per month
- Rate limit: ~1 request per second
- Model loading time: 10-20 detik (first request)

## Best Practices

1. **Error Handling**
   - Aplikasi sudah handle error 503 (model loading)
   - Menampilkan pesan error yang user-friendly

2. **Performance**
   - Gunakan model kecil untuk respons cepat
   - Cache conversation history
   - Limit history length untuk efisiensi

3. **Security**
   - Jangan commit API key ke repository
   - Gunakan environment variables untuk production
   - Validasi input user

## Future Enhancements

Fitur yang bisa ditambahkan:

1. **Voice Input/Output**
   - Speech-to-text untuk input
   - Text-to-speech untuk respons

2. **Image Understanding**
   - Upload gambar produk
   - AI menjelaskan produk dari gambar

3. **Personalization**
   - Simpan preferensi user
   - Rekomendasi produk berdasarkan chat

4. **Multi-language**
   - Support bahasa Indonesia dan Inggris
   - Auto-detect bahasa user

5. **Chat History**
   - Simpan percakapan ke local storage
   - Export chat history

## Troubleshooting

### Model Loading Lama
**Solusi**: Model Hugging Face perlu "warm up". Tunggu 10-20 detik pada request pertama.

### Respons Tidak Relevan
**Solusi**: 
- Gunakan model yang lebih besar (DialoGPT-large)
- Adjust temperature parameter
- Berikan context yang lebih jelas

### API Key Error
**Solusi**: 
- Pastikan API key valid
- Check di Hugging Face settings
- Regenerate token jika perlu

## Resources

- [Hugging Face Models](https://huggingface.co/models)
- [DialoGPT Documentation](https://huggingface.co/microsoft/DialoGPT-medium)
- [Flutter HTTP Package](https://pub.dev/packages/http)
