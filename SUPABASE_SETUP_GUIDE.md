# Panduan Setup Supabase untuk AR Fashion

## 📋 Overview

Aplikasi AR Fashion sekarang terintegrasi dengan Supabase untuk:
- **Cloud Storage**: Upload model 3D (GLB/GLTF) dan image target
- **Database**: Menyimpan metadata model
- **Sync**: Data tersinkronisasi antar device

## 🚀 Setup Supabase Project

### 1. Buat Supabase Project

1. Buka [https://supabase.com](https://supabase.com)
2. Sign up / Login
3. Klik **"New Project"**
4. Isi detail project:
   - **Name**: `ar-fashion` (atau nama lain)
   - **Database Password**: Buat password yang kuat
   - **Region**: Pilih yang terdekat (Singapore/Southeast Asia)
5. Klik **"Create new project"**
6. Tunggu beberapa menit sampai project siap

### 2. Dapatkan API Keys

1. Di dashboard Supabase, buka **Settings** > **API**
2. Copy:
   - **Project URL** (contoh: `https://xxxxx.supabase.co`)
   - **anon public** key

### 3. Update Konfigurasi di Aplikasi

Buka file `lib/config/supabase_config.dart` dan update:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://xxxxx.supabase.co'; // Ganti dengan URL Anda
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // Ganti dengan key Anda
  
  // ... rest of the code
}
```

## 🗄️ Setup Database

### 1. Buat Tabel `custom_models`

Di Supabase Dashboard, buka **SQL Editor** dan jalankan:

```sql
-- Create custom_models table
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

-- Add index for faster queries
CREATE INDEX idx_custom_models_uploaded_at ON custom_models(uploaded_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE custom_models ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations (untuk development)
-- PENTING: Untuk production, sesuaikan policy dengan kebutuhan auth
CREATE POLICY "Allow all operations" ON custom_models
  FOR ALL
  USING (true)
  WITH CHECK (true);
```

### 2. Buat Tabel `image_targets` (Opsional)

Jika ingin tabel terpisah untuk image targets:

```sql
-- Create image_targets table
CREATE TABLE image_targets (
  id TEXT PRIMARY KEY,
  model_id TEXT REFERENCES custom_models(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  image_path TEXT NOT NULL,
  supabase_url TEXT,
  width INTEGER,
  height INTEGER,
  uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add index
CREATE INDEX idx_image_targets_model_id ON image_targets(model_id);

-- Enable RLS
ALTER TABLE image_targets ENABLE ROW LEVEL SECURITY;

-- Create policy
CREATE POLICY "Allow all operations" ON image_targets
  FOR ALL
  USING (true)
  WITH CHECK (true);
```

## 📦 Setup Storage Buckets

### 1. Buat Bucket untuk Models

1. Di Supabase Dashboard, buka **Storage**
2. Klik **"New bucket"**
3. Isi detail:
   - **Name**: `models`
   - **Public bucket**: ✅ Centang (agar bisa diakses publik)
4. Klik **"Create bucket"**

### 2. Buat Bucket untuk Images

1. Klik **"New bucket"** lagi
2. Isi detail:
   - **Name**: `images`
   - **Public bucket**: ✅ Centang
3. Klik **"Create bucket"**

### 3. Setup Storage Policies

Untuk setiap bucket, setup policy:

```sql
-- Policy untuk bucket 'models'
CREATE POLICY "Allow public read access" ON storage.objects
  FOR SELECT
  USING (bucket_id = 'models');

CREATE POLICY "Allow authenticated upload" ON storage.objects
  FOR INSERT
  WITH CHECK (bucket_id = 'models');

CREATE POLICY "Allow authenticated delete" ON storage.objects
  FOR DELETE
  USING (bucket_id = 'models');

-- Policy untuk bucket 'images'
CREATE POLICY "Allow public read access" ON storage.objects
  FOR SELECT
  USING (bucket_id = 'images');

CREATE POLICY "Allow authenticated upload" ON storage.objects
  FOR INSERT
  WITH CHECK (bucket_id = 'images');

CREATE POLICY "Allow authenticated delete" ON storage.objects
  FOR DELETE
  USING (bucket_id = 'images');
```

## 🔧 Install Dependencies

Jalankan di terminal:

```bash
flutter pub get
```

Dependencies yang ditambahkan:
- `supabase_flutter: ^2.9.1`

## ✅ Testing

### 1. Test Connection

Jalankan aplikasi dan cek console:
```
Supabase initialized successfully
```

Jika ada error, cek:
- URL dan API key sudah benar
- Internet connection aktif

### 2. Test Upload Model

1. Buka aplikasi
2. Pilih **"Upload Model"**
3. Klik button **"Upload"** di header
4. Pilih format file (GLB/GLTF)
5. Pilih file dari device
6. Isi nama dan deskripsi
7. Pilih apakah ingin upload image target
8. Tunggu upload selesai

### 3. Verifikasi di Supabase

1. **Storage**: Buka **Storage** > **models** atau **images**
   - File harus muncul di sini
   
2. **Database**: Buka **Table Editor** > **custom_models**
   - Data model harus muncul di sini

## 📊 Struktur Data

### CustomModel

```dart
{
  "id": "1713862200000",
  "name": "Red Dress",
  "description": "Beautiful red evening dress",
  "file_path": "/data/.../custom_models/1713862200000_model.glb",
  "image_target_path": "/data/.../custom_models/1713862200000_image.jpg",
  "supabase_model_url": "https://xxxxx.supabase.co/storage/v1/object/public/models/...",
  "supabase_image_url": "https://xxxxx.supabase.co/storage/v1/object/public/images/...",
  "uploaded_at": "2026-04-23T10:30:00.000Z",
  "file_size": 5242880,
  "created_at": "2026-04-23T10:30:00.000Z"
}
```

## 🔐 Security Best Practices

### 1. Environment Variables

Untuk production, jangan hardcode API keys. Gunakan environment variables:

```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_DEFAULT_URL',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_DEFAULT_KEY',
  );
}
```

Build dengan:
```bash
flutter build apk --dart-define=SUPABASE_URL=https://xxxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=your_key
```

### 2. Row Level Security (RLS)

Untuk production, update RLS policies:

```sql
-- Hanya allow user yang authenticated
CREATE POLICY "Authenticated users can insert" ON custom_models
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- User hanya bisa delete model mereka sendiri
CREATE POLICY "Users can delete own models" ON custom_models
  FOR DELETE
  USING (auth.uid() = user_id); -- Tambahkan kolom user_id
```

### 3. File Size Limits

Di Supabase Dashboard > **Storage** > **Policies**, set max file size:

```sql
-- Max 50MB untuk models
CREATE POLICY "Limit file size" ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'models' AND
    (octet_length(decode(content, 'base64')) < 52428800) -- 50MB
  );
```

## 🚨 Troubleshooting

### Error: "Invalid API key"
- Cek API key sudah benar
- Pastikan tidak ada spasi di awal/akhir
- Gunakan **anon public** key, bukan service_role key

### Error: "Bucket not found"
- Cek nama bucket di `SupabaseConfig` sesuai dengan yang dibuat
- Pastikan bucket sudah dibuat di Supabase Dashboard

### Error: "Row Level Security policy violation"
- Cek RLS policies sudah dibuat
- Untuk development, gunakan policy "Allow all operations"
- Untuk production, sesuaikan dengan auth requirements

### Upload Lambat
- Compress model sebelum upload
- Gunakan GLB (binary) bukan GLTF (JSON)
- Cek koneksi internet

### Model Tidak Muncul di List
- Cek console untuk error messages
- Verifikasi data ada di Supabase Table Editor
- Cek query di `getCustomModels()` method

## 📱 Offline Support

Aplikasi tetap berfungsi offline:
- Model disimpan di local storage sebagai backup
- Saat online, data sync ke Supabase
- Saat offline, gunakan data local

## 🔄 Migration dari Local ke Supabase

Jika sudah ada data local, bisa di-migrate:

```dart
// Di CustomModelService, tambahkan method:
Future<void> migrateLocalToSupabase() async {
  final localModels = await _getLocalModels();
  
  for (final model in localModels) {
    try {
      // Upload file ke Supabase
      final file = File(model.filePath);
      if (await file.exists()) {
        final url = await uploadModelToSupabase(
          file,
          model.filePath.split('/').last,
        );
        
        // Update model dengan Supabase URL
        final updatedModel = CustomModel(
          id: model.id,
          name: model.name,
          filePath: model.filePath,
          supabaseModelUrl: url,
          uploadedAt: model.uploadedAt,
        );
        
        // Save ke Supabase
        await saveCustomModel(updatedModel);
      }
    } catch (e) {
      print('Error migrating model ${model.id}: $e');
    }
  }
}
```

## 📚 Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Storage Guide](https://supabase.com/docs/guides/storage)
- [Database Guide](https://supabase.com/docs/guides/database)

## 🆘 Support

Jika mengalami masalah:
1. Cek dokumentasi ini
2. Cek Supabase logs di Dashboard
3. Cek console output di aplikasi
4. Hubungi developer: Alvinda Shahrul

---

**Version**: 1.0.0  
**Last Updated**: April 23, 2026  
**Author**: Alvinda Shahrul
