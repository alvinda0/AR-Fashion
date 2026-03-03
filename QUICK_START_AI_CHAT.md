# Quick Start: AI Chat dengan Hugging Face

## 🚀 Langkah Cepat (5 Menit)

### 1. Dapatkan API Key (2 menit)

1. Buka: https://huggingface.co/settings/tokens
2. Login atau buat akun baru
3. Klik "New token"
4. Copy token yang muncul (format: `hf_xxxxxxxxxxxxx`)

### 2. Masukkan API Key (1 menit)

Buka file: `lib/services/huggingface_service.dart`

Ganti baris ini:
```dart
static const String _apiKey = 'YOUR_HUGGINGFACE_API_KEY';
```

Dengan:
```dart
static const String _apiKey = 'hf_xxxxxxxxxxxxx'; // Token Anda
```

### 3. Install & Run (2 menit)

```bash
# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run
```

### 4. Test Chat

1. Buka aplikasi
2. Tap menu "AI Chat"
3. Ketik pesan: "Halo!"
4. Tunggu respons dari AI

## ✅ Selesai!

Aplikasi Anda sekarang memiliki fitur AI Chat.

## 📱 Cara Menggunakan

### Menu Baru di Home Screen

Setelah update, home screen akan menampilkan menu baru:

```
🏠 Home Screen
├── 📷 AR Camera
├── 💬 AI Chat          ← BARU!
├── ▶️  Tutorial
├── 🖼️  Gallery
└── ℹ️  About
```

### Interface Chat

```
┌─────────────────────────┐
│  AI Chat Assistant      │
├─────────────────────────┤
│                         │
│  🤖 Halo! Saya AI...   │
│                         │
│      Halo juga! 👤     │
│                         │
│  🤖 Ada yang bisa...   │
│                         │
├─────────────────────────┤
│ [Ketik pesan...] [📤]  │
└─────────────────────────┘
```

## 🎨 Customization Cepat

### Ubah Welcome Message

File: `lib/screens/ai_chat_screen.dart`

```dart
_messages.add(
  ChatMessage(
    text: 'Selamat datang! Saya siap membantu Anda.',
    isUser: false,
  ),
);
```

### Ubah Model AI

File: `lib/services/huggingface_service.dart`

```dart
// Model cepat (recommended untuk testing)
static const String _model = 'microsoft/DialoGPT-small';

// Model standar (balanced)
static const String _model = 'microsoft/DialoGPT-medium';

// Model akurat (lebih lambat)
static const String _model = 'microsoft/DialoGPT-large';
```

### Ubah Warna

File: `lib/screens/ai_chat_screen.dart`

```dart
// Warna app bar
backgroundColor: const Color(0xFF00796B),

// Warna bubble user
color: const Color(0xFF00796B),
```

## ⚠️ Troubleshooting

### Error: "Model is loading"

**Penyebab**: Model Hugging Face perlu waktu untuk start up

**Solusi**: Tunggu 10-20 detik, lalu coba lagi

### Error: "Unauthorized"

**Penyebab**: API key salah atau tidak valid

**Solusi**: 
1. Check API key di Hugging Face settings
2. Pastikan sudah copy dengan benar
3. Regenerate token jika perlu

### Respons Lambat

**Penyebab**: API gratis Hugging Face bisa lambat

**Solusi**:
1. Gunakan model lebih kecil (DialoGPT-small)
2. Tunggu beberapa detik
3. Untuk production, pertimbangkan upgrade

### Build Error

**Solusi**:
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

## 📊 Fitur yang Sudah Ditambahkan

✅ Chat UI dengan bubble messages
✅ AI response menggunakan Hugging Face
✅ Context-aware conversation
✅ Loading indicator
✅ Auto-scroll ke pesan baru
✅ Multi-line input support
✅ Error handling
✅ Responsive design

## 🔧 File yang Ditambahkan

```
lib/
├── models/
│   └── chat_message.dart          # Model pesan
├── screens/
│   └── ai_chat_screen.dart        # UI chat
└── services/
    └── huggingface_service.dart   # API service

pubspec.yaml                        # + http package
lib/main.dart                       # + menu AI Chat
```

## 💡 Tips

1. **Testing**: Gunakan DialoGPT-small untuk testing cepat
2. **Production**: Upgrade ke DialoGPT-medium atau large
3. **API Key**: Jangan commit ke Git (tambahkan ke .gitignore)
4. **Rate Limit**: Free tier = 30k requests/month
5. **First Request**: Selalu lebih lambat (model loading)

## 📚 Dokumentasi Lengkap

- `AI_CHAT_SETUP.md` - Setup detail
- `AI_CHAT_FEATURES.md` - Fitur lengkap
- Hugging Face Docs: https://huggingface.co/docs

## 🎯 Next Steps

Setelah chat berjalan, Anda bisa:

1. Customize personality AI
2. Tambahkan voice input/output
3. Integrate dengan AR features
4. Simpan chat history
5. Tambahkan rekomendasi produk

## ❓ Butuh Bantuan?

- Check dokumentasi di folder project
- Visit Hugging Face docs
- Test dengan model berbeda
- Adjust parameters untuk hasil lebih baik

---

**Selamat! Aplikasi AR Fashion Anda sekarang memiliki AI Chat Assistant! 🎉**
