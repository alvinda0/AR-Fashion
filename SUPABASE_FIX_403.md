# Fix Error 403: Signature Verification Failed

## ❌ Error Message:
```
Error uploading to Supabase: StorageException
message: signature verification failed
status code: 403
error: unauthorized
```

## 🔍 Penyebab:

1. **Anon Key Salah/Tidak Lengkap**
2. **Storage Policies Tidak Configured**
3. **Bucket Tidak Public**

## ✅ Solusi:

### 1. Dapatkan Anon Key yang Benar

#### Step by Step:

1. **Login ke Supabase Dashboard**
   - https://supabase.com/dashboard

2. **Pilih Project**
   - Project: `ar-fashion-glb`
   - URL: `https://qerzhadqtgkckrejxcqg.supabase.co`

3. **Buka Settings → API**
   - Klik menu **Settings** (⚙️) di sidebar kiri
   - Klik **API**

4. **Copy "anon public" Key**
   - Scroll ke section **Project API keys**
   - Cari key dengan label **"anon public"**
   - Klik icon copy (📋)
   - Key akan terlihat seperti:
     ```
     eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFlcnpoYWRxdGdrY2tyZWp4Y3FnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0MDI0NzksImV4cCI6MjA2MDk3ODQ3OX0.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
     ```

5. **Update Config**
   
   File: `lib/config/supabase_config.dart`
   
   ```dart
   static const String supabaseAnonKey = 'PASTE_YOUR_FULL_KEY_HERE';
   ```

⚠️ **PENTING**: 
- Jangan gunakan `service_role` key (berbahaya!)
- Pastikan key lengkap (biasanya 200+ karakter)
- Tidak ada spasi di awal/akhir

### 2. Setup Storage Policies

#### Buka SQL Editor:

Supabase Dashboard → **SQL Editor** → **New query**

#### Jalankan SQL ini:

```sql
-- 1. Pastikan bucket 'images' ada dan public
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Hapus semua policies lama (jika ada)
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;
DROP POLICY IF EXISTS "Allow public upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow public delete" ON storage.objects;
DROP POLICY IF EXISTS "Allow all operations" ON storage.objects;

-- 3. Create policy untuk READ (public)
CREATE POLICY "Public can read images"
ON storage.objects FOR SELECT
USING (bucket_id = 'images');

-- 4. Create policy untuk INSERT (upload)
CREATE POLICY "Anyone can upload images"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'images');

-- 5. Create policy untuk DELETE
CREATE POLICY "Anyone can delete images"
ON storage.objects FOR DELETE
USING (bucket_id = 'images');

-- 6. Create policy untuk UPDATE
CREATE POLICY "Anyone can update images"
ON storage.objects FOR UPDATE
USING (bucket_id = 'images')
WITH CHECK (bucket_id = 'images');
```

Klik **Run** atau tekan `Ctrl+Enter`

### 3. Verify Bucket Settings

#### Check Bucket:

1. **Buka Storage** → **Buckets**
2. **Klik bucket "images"**
3. **Verify settings**:
   - ✅ Public bucket: **ON**
   - ✅ File size limit: 50MB (atau sesuai kebutuhan)
   - ✅ Allowed MIME types: `image/*`

#### Jika bucket belum ada:

1. Klik **"New bucket"**
2. Name: `images`
3. Public bucket: ✅ **Centang**
4. Klik **"Create bucket"**

### 4. Test Upload Manual

#### Test di Supabase Dashboard:

1. **Buka Storage** → **images**
2. **Klik "Upload file"**
3. **Pilih gambar test**
4. **Upload**

Jika berhasil → Policy sudah benar ✅
Jika gagal → Cek policies lagi ❌

### 5. Restart Aplikasi

```bash
# Stop app
flutter run --stop

# Clean
flutter clean

# Get dependencies
flutter pub get

# Run
flutter run
```

## 🧪 Test di Aplikasi

1. **Buka app** → **Image Target**
2. **Klik "Upload"**
3. **Pilih gambar**
4. **Masukkan nama**
5. **Upload**

### Expected Result:

```
✅ Supabase initialized successfully
🔄 Uploading to Supabase...
✅ Image target "nama" berhasil diupload!
```

## 🔍 Debug Mode

### Enable Verbose Logging:

File: `lib/services/image_target_service.dart`

```dart
Future<String> uploadImageToSupabase(File file, String fileName) async {
  try {
    print('📤 Starting upload...');
    print('📁 File: $fileName');
    print('📦 Bucket: images');
    
    final bytes = await file.readAsBytes();
    print('📊 File size: ${bytes.length} bytes');
    
    final filePath = 'image_targets/$fileName';
    print('📍 Path: $filePath');
    
    await _supabase.storage
        .from('images')
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
          ),
        );
    
    print('✅ Upload successful!');
    
    final publicUrl = _supabase.storage
        .from('images')
        .getPublicUrl(filePath);
    
    print('🔗 Public URL: $publicUrl');
    
    return publicUrl;
  } catch (e) {
    print('❌ Upload error: $e');
    rethrow;
  }
}
```

## 📋 Checklist

- [ ] Anon key sudah benar (format JWT, 200+ karakter)
- [ ] Bucket `images` sudah dibuat
- [ ] Bucket `images` set sebagai public
- [ ] Storage policies sudah dibuat
- [ ] Test upload manual di dashboard berhasil
- [ ] App sudah di-restart
- [ ] Test upload di app

## 🆘 Masih Error?

### Check Console Logs:

Cari log ini:
```
✅ Supabase initialized with URL: https://qerzhadqtgkckrejxcqg.supabase.co
```

### Verify Anon Key:

Decode JWT di https://jwt.io

Paste anon key Anda, harus terlihat:
```json
{
  "iss": "supabase",
  "ref": "qerzhadqtgkckrejxcqg",
  "role": "anon",
  "iat": 1745402479,
  "exp": 2060978479
}
```

### Check Supabase Logs:

Dashboard → **Logs** → **Storage**

Cari error messages

## 📞 Alternative: Disable RLS Temporarily

⚠️ **HANYA UNTUK TESTING!**

```sql
-- Disable RLS on storage.objects (NOT RECOMMENDED FOR PRODUCTION)
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
```

Jika ini berhasil, berarti masalah di policies.

**Jangan lupa enable kembali:**
```sql
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
```

---

**Last Updated**: April 23, 2026

## 📸 Screenshot Guide

Kirim screenshot ini jika masih error:
1. Supabase Dashboard → Settings → API (anon key section)
2. Supabase Dashboard → Storage → images (bucket settings)
3. Console logs saat upload
4. Error message lengkap
