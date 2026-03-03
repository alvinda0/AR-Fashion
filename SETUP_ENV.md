# Setup Environment Variables

## Untuk Developer Baru

Jika kamu clone repository ini, ikuti langkah berikut untuk setup API keys:

### 1. Copy File `.env.example`

```bash
cp .env.example .env
```

Atau di Windows:
```bash
copy .env.example .env
```

### 2. Dapatkan Hugging Face API Token

1. Buat akun di https://huggingface.co/join (gratis)
2. Login dan buka https://huggingface.co/settings/tokens
3. Klik "New token" atau "Create new token"
4. Isi:
   - Name: `AR Fashion App` (atau nama bebas)
   - Role: Pilih **"Read"**
5. Klik "Generate token"
6. Copy token yang muncul (dimulai dengan `hf_...`)

### 3. Edit File `.env`

Buka file `.env` dan ganti:

```
HF_TOKEN=your_huggingface_token_here
```

Dengan token yang kamu copy:

```
HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxx
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run App

```bash
flutter run
```

## File Structure

```
.
├── .env                 # API keys (JANGAN PUSH KE GITHUB!)
├── .env.example         # Template untuk developer lain
├── .gitignore           # Sudah include .env
└── lib/
    ├── main.dart        # Load .env saat app start
    └── services/
        └── huggingface_service.dart  # Baca token dari .env
```

## Keamanan

✅ File `.env` sudah ada di `.gitignore` - tidak akan ter-push ke GitHub
✅ File `.env.example` adalah template kosong - aman untuk di-push
✅ API key dibaca dari environment variable, bukan hardcoded

## Troubleshooting

### Error: "Unable to load asset: .env"

**Penyebab**: File `.env` belum dibuat atau tidak ada di root project

**Solusi**:
1. Pastikan file `.env` ada di root project (sejajar dengan `pubspec.yaml`)
2. Jalankan `flutter clean` dan `flutter pub get`
3. Restart app

### Error: "API key tidak valid"

**Penyebab**: Token salah atau expired

**Solusi**:
1. Cek file `.env`, pastikan token dimulai dengan `hf_`
2. Verifikasi token masih valid di https://huggingface.co/settings/tokens
3. Buat token baru jika perlu

### Token Ter-push ke GitHub (BAHAYA!)

**Jika tidak sengaja push API key ke GitHub**:

1. **SEGERA revoke token** di https://huggingface.co/settings/tokens
2. Buat token baru
3. Update file `.env` dengan token baru
4. Hapus token dari Git history:
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch lib/services/huggingface_service.dart" \
     --prune-empty --tag-name-filter cat -- --all
   ```
5. Force push:
   ```bash
   git push origin --force --all
   ```

## Best Practices

1. **Jangan pernah** commit file `.env` ke Git
2. **Selalu** gunakan `.env.example` sebagai template
3. **Dokumentasikan** environment variables yang dibutuhkan
4. **Rotate** API keys secara berkala
5. **Gunakan** different tokens untuk development dan production

## Production Deployment

Untuk production (Google Play / App Store), jangan include file `.env` di build.

Gunakan:
- **Android**: `BuildConfig` atau `gradle.properties`
- **iOS**: `Info.plist` atau Xcode environment variables
- **CI/CD**: GitHub Secrets, GitLab CI Variables, dll

## Referensi

- Hugging Face Tokens: https://huggingface.co/docs/hub/security-tokens
- Flutter Dotenv: https://pub.dev/packages/flutter_dotenv
- Git Secrets: https://git-secret.io/
