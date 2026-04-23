# Image Target - Integrasi Model 3D dari Supabase

## Ringkasan Fitur

Halaman Image Target sekarang memungkinkan user untuk memilih **model 3D** dari bucket `ar-fashion-glb` di Supabase saat mengupload image target. Ketika image target di-scan di AR Camera, model 3D yang dipilih akan ditampilkan.

## Alur Kerja

```
1. User upload image target
   ↓
2. User pilih model 3D dari dropdown (opsional)
   ↓
3. Data disimpan ke Supabase (image_target table)
   ↓
4. AR Camera scan image target
   ↓
5. Model 3D yang dipilih ditampilkan
```

## Perubahan yang Dilakukan

### 1. **Image Target Screen**

#### a. State Management
```dart
List<String> _availableModels = [];  // List model dari bucket
String? _selectedModelUrl;            // Model yang dipilih
bool _isLoadingModels = false;        // Loading state
```

#### b. Load Models dari Bucket
```dart
Future<void> _loadAvailableModels() async {
  // Get list of files from ar-fashion-glb bucket
  final files = await SupabaseConfig.client.storage
      .from('ar-fashion-glb')
      .list();
  
  // Filter hanya file .glb
  final models = files
      .where((file) => file.name.endsWith('.glb'))
      .map((file) => getPublicUrl(file.name))
      .toList();
}
```

#### c. Upload Dialog dengan Dropdown
- **Nama Image Target**: TextField untuk input nama
- **Pilih Model 3D**: Dropdown untuk memilih model dari bucket
- **Pilih Gambar**: Button untuk upload gambar target

#### d. Indikator Visual
- **Icon 3D**: Muncul di card jika model sudah dipilih
- **Badge**: Menunjukkan status model 3D
- **Detail View**: Menampilkan informasi model yang dipilih

### 2. **Image Target Service**

Model `ImageTarget` sudah diupdate dengan field `modelUrl`:
```dart
class ImageTarget {
  final int? id;
  final String name;
  final String imageTarget;
  final String? modelUrl;      // ← Field baru
  final DateTime? createdAt;
}
```

### 3. **AR Camera Screen**

Helper function `_getModelUrl()` sudah diimplementasi untuk:
1. Cek model URL dari Supabase
2. Fallback ke data lokal jika tidak ada

## Struktur Database

### Tabel: `image_target`
```sql
CREATE TABLE image_target (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  image_target TEXT NOT NULL,
  model_url TEXT,              -- URL model 3D dari bucket
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Bucket: `ar-fashion-glb`
- Berisi file model 3D dalam format `.glb`
- Public access untuk dapat diakses oleh aplikasi
- URL format: `https://[project].supabase.co/storage/v1/object/public/ar-fashion-glb/[filename].glb`

## Cara Penggunaan

### 1. Upload Image Target dengan Model 3D

1. **Buka halaman "Image Target"**
2. **Klik tombol "Upload"** di header
3. **Masukkan nama** image target (contoh: "Dayana Blue")
4. **Pilih model 3D** dari dropdown:
   - Dropdown akan menampilkan semua model dari bucket `ar-fashion-glb`
   - Nama model ditampilkan dengan format yang lebih readable
   - Contoh: `dayana_blue.glb` → `Dayana Blue`
5. **Klik "Pilih Gambar"** untuk upload image target
6. **Tunggu proses upload** selesai
7. **Image target dengan model 3D** berhasil disimpan!

### 2. Melihat Detail Image Target

1. **Klik pada card** image target
2. **Dialog detail** akan muncul menampilkan:
   - Gambar target
   - ID dan tanggal upload
   - **Status model 3D**:
     - ✅ "Model 3D tersedia" (hijau) - jika model sudah dipilih
     - ⚠️ "Model 3D belum dipilih" (orange) - jika belum ada model
   - Nama file model (jika ada)

### 3. Scan dengan AR Camera

1. **Buka halaman "AR Camera"**
2. **Arahkan kamera** ke image target yang sudah diupload
3. **Aplikasi akan mendeteksi** image target
4. **Model 3D yang dipilih** akan ditampilkan secara otomatis
5. **Interaksi dengan model**:
   - Rotate: Drag untuk memutar
   - Zoom: Pinch untuk zoom in/out
   - Info: Tap tombol info untuk detail produk

## Fitur UI/UX

### 1. **Dropdown Model 3D**
- **Loading State**: Menampilkan "Loading models..." saat mengambil data
- **Empty State**: Menampilkan "Tidak ada model tersedia" jika bucket kosong
- **Display Name**: Nama file diformat menjadi lebih readable
  - `dayana_blue.glb` → `Dayana Blue`
  - `nayra_black.glb` → `Nayra Black`
- **Optional**: User bisa skip pemilihan model (tidak wajib)

### 2. **Visual Indicators**
- **Icon 3D** (🎲): Muncul di pojok kanan atas card jika model sudah dipilih
- **Badge Status**: 
  - Hijau dengan ✅ = Model tersedia
  - Orange dengan ⚠️ = Model belum dipilih

### 3. **Success Message**
- **Dengan model**: "Image target [nama] dengan model 3D berhasil diupload!"
- **Tanpa model**: "Image target [nama] berhasil diupload!"

## Contoh Skenario

### Skenario 1: Upload dengan Model 3D
```
1. User: Upload image target "Dayana Blue"
2. User: Pilih model "dayana_blue.glb" dari dropdown
3. User: Upload gambar poster Dayana
4. System: Simpan ke database dengan model_url
5. AR Camera: Scan poster Dayana
6. System: Tampilkan model 3D dayana_blue.glb
```

### Skenario 2: Upload tanpa Model 3D
```
1. User: Upload image target "Product X"
2. User: Skip pemilihan model (tidak pilih)
3. User: Upload gambar poster Product X
4. System: Simpan ke database tanpa model_url
5. AR Camera: Scan poster Product X
6. System: Gunakan fallback model atau tidak tampilkan model
```

## Troubleshooting

### Model tidak muncul di dropdown
**Penyebab:**
- Bucket `ar-fashion-glb` kosong
- Tidak ada file `.glb` di bucket
- Koneksi internet bermasalah

**Solusi:**
1. Cek bucket di Supabase Dashboard
2. Upload file `.glb` ke bucket
3. Pastikan file berformat `.glb` (bukan `.gltf`)
4. Refresh aplikasi

### Model 3D tidak muncul di AR Camera
**Penyebab:**
- Model URL tidak valid
- File model corrupt atau terlalu besar
- Koneksi internet lambat

**Solusi:**
1. Cek URL model di database
2. Verifikasi file model dapat diakses
3. Compress model jika terlalu besar (< 10MB recommended)
4. Gunakan format GLB (lebih optimal dari GLTF)

### Dropdown loading terus
**Penyebab:**
- Supabase tidak terinisialisasi
- Bucket tidak accessible
- Network timeout

**Solusi:**
1. Restart aplikasi
2. Cek Supabase credentials
3. Verifikasi bucket policy (harus public)
4. Cek koneksi internet

## Best Practices

### 1. **Naming Convention**
Gunakan naming yang konsisten untuk model:
```
✅ Good:
- dayana_blue.glb
- nayra_black.glb
- xavia_purple.glb

❌ Bad:
- model1.glb
- test.glb
- untitled.glb
```

### 2. **File Size**
- **Optimal**: < 5MB
- **Maximum**: < 10MB
- **Compress**: Gunakan tools seperti gltf-pipeline atau Blender

### 3. **Model Quality**
- **Polygons**: 10k - 50k triangles
- **Textures**: 1024x1024 atau 2048x2048
- **Format**: GLB (binary) lebih baik dari GLTF (JSON)

### 4. **Testing**
Sebelum upload ke production:
1. Test model di model viewer online
2. Verifikasi ukuran file
3. Cek texture dan material
4. Test di berbagai device

## Database Schema

### Query untuk membuat tabel
```sql
-- Tabel image_target dengan model_url
CREATE TABLE image_target (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  image_target TEXT NOT NULL,
  model_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Index untuk performa
CREATE INDEX idx_image_target_name ON image_target(name);
CREATE INDEX idx_image_target_created_at ON image_target(created_at DESC);
```

### Query untuk update existing data
```sql
-- Tambah kolom model_url jika belum ada
ALTER TABLE image_target 
ADD COLUMN IF NOT EXISTS model_url TEXT;

-- Update model_url untuk data existing
UPDATE image_target 
SET model_url = 'https://[project].supabase.co/storage/v1/object/public/ar-fashion-glb/dayana_blue.glb'
WHERE name = 'Dayana';
```

## Future Improvements

1. **Preview Model**: Preview model 3D sebelum upload
2. **Edit Model**: Edit/ganti model setelah upload
3. **Upload Model**: Upload model langsung dari aplikasi
4. **Model Library**: Library model yang bisa digunakan ulang
5. **Model Variants**: Multiple model untuk satu image target
6. **Animation**: Support animated models
7. **AR Placement**: Place model di real world dengan ARCore/ARKit

## Catatan Penting

1. **Model URL bersifat opsional** - image target bisa diupload tanpa model
2. **Fallback system** - jika model tidak ada, gunakan data lokal
3. **Public bucket** - bucket `ar-fashion-glb` harus public untuk diakses
4. **Format GLB** - hanya file `.glb` yang ditampilkan di dropdown
5. **Performance** - model besar akan mempengaruhi loading time

## Kesimpulan

Fitur ini memungkinkan **koneksi langsung** antara image target dan model 3D di Supabase, memberikan fleksibilitas untuk:
- ✅ Manage produk secara dinamis
- ✅ Update model tanpa rebuild aplikasi
- ✅ Skalabilitas untuk banyak produk
- ✅ User experience yang lebih baik
