# Quick Start: Supabase Integration

## 🚀 5 Menit Setup

### 1. Buat Supabase Project (2 menit)

1. Buka https://supabase.com dan login
2. Klik **"New Project"**
3. Isi:
   - Name: `ar-fashion`
   - Password: (buat password)
   - Region: `Southeast Asia (Singapore)`
4. Klik **"Create new project"**
5. Tunggu ~2 menit

### 2. Copy API Keys (30 detik)

1. Di dashboard, buka **Settings** → **API**
2. Copy:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 3. Update Config (30 detik)

Buka `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'PASTE_YOUR_URL_HERE';
  static const String supabaseAnonKey = 'PASTE_YOUR_KEY_HERE';
  // ...
}
```

### 4. Setup Database (1 menit)

Di Supabase Dashboard, buka **SQL Editor** dan paste:

```sql
-- Create table
CREATE TABLE custom_models (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  file_path TEXT NOT NULL,
  image_target_path TEXT,
  supabase_model_url TEXT,
  supabase_image_url TEXT,
  uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  file_size BIGINT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE custom_models ENABLE ROW LEVEL SECURITY;

-- Allow all (development only!)
CREATE POLICY "Allow all" ON custom_models FOR ALL USING (true) WITH CHECK (true);
```

Klik **"Run"**.

### 5. Setup Storage (1 menit)

1. Buka **Storage** → **"New bucket"**
2. Name: `models`, Public: ✅, Create
3. **"New bucket"** lagi
4. Name: `images`, Public: ✅, Create

### 6. Test! (30 detik)

```bash
flutter pub get
flutter run
```

Coba upload model dari aplikasi!

## ✅ Checklist

- [ ] Supabase project created
- [ ] API keys copied
- [ ] Config updated
- [ ] Database table created
- [ ] Storage buckets created
- [ ] App tested

## 🎉 Done!

Aplikasi sekarang bisa:
- ✅ Upload model ke cloud
- ✅ Upload image target
- ✅ Sync antar device
- ✅ Backup lokal otomatis

## 📖 Dokumentasi Lengkap

Lihat `SUPABASE_SETUP_GUIDE.md` untuk:
- Security setup
- Production configuration
- Troubleshooting
- Advanced features

---

**Need Help?** Check console logs atau Supabase Dashboard logs.
