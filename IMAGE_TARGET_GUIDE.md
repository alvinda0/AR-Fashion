# Panduan Image Target - AR Fashion

## 📋 Overview

Fitur **Image Target** memungkinkan Anda untuk upload gambar yang akan digunakan sebagai marker untuk AR detection. Ketika kamera mendeteksi image target ini, model 3D akan ditampilkan.

## ✨ Fitur

- ✅ Upload image target ke Supabase Storage
- ✅ Simpan metadata ke Supabase Database
- ✅ Grid view dengan preview gambar
- ✅ Full screen preview
- ✅ Delete image target
- ✅ Responsive design (tablet & phone)

## 🎯 Cara Menggunakan

### 1. Akses Menu Image Target

Dari home screen, pilih **"Image Target"**

### 2. Upload Image Target

1. Klik button **"Upload"** di header
2. Pilih gambar dari device (JPG, PNG, GIF)
3. Masukkan nama untuk image target
4. Klik **"Simpan"**
5. Tunggu upload selesai

### 3. View Image Target

- Klik pada card image untuk melihat preview full screen
- Lihat detail: nama, ID, tanggal upload

### 4. Delete Image Target

- Klik icon delete (🗑️) pada card
- Konfirmasi penghapusan
- Image akan dihapus dari storage dan database

## 📊 Struktur Database

### Tabel: `image_target`

```sql
CREATE TABLE image_target (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  image_target TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Fields:

- **id**: Auto-increment ID
- **name**: Nama image target
- **image_target**: URL gambar di Supabase Storage
- **created_at**: Timestamp upload

## 📦 Storage

### Bucket: `images`

Path format: `image_targets/{timestamp}_{filename}.jpg`

Contoh:
```
images/image_targets/1713862200000_product1.jpg
```

## 🎨 UI Features

### Grid Layout

- **Phone**: 2 kolom
- **Tablet**: 3 kolom
- Responsive spacing dan sizing

### Image Card

- Preview gambar
- Nama image target
- Tanggal upload
- Delete button

### Empty State

- Icon placeholder
- Informative message
- Call to action

## 🔧 Technical Details

### ImageTarget Model

```dart
class ImageTarget {
  final int? id;
  final String name;
  final String imageTarget;  // URL
  final DateTime? createdAt;
}
```

### ImageTargetService

```dart
// Get all image targets
List<ImageTarget> targets = await service.getImageTargets();

// Upload image
String url = await service.uploadImageToSupabase(file, fileName);

// Save to database
await service.saveImageTarget(imageTarget);

// Delete
await service.deleteImageTarget(id, imageUrl);
```

## 📱 Rekomendasi Image Target

### Format

- **JPG/JPEG**: Recommended (smaller size)
- **PNG**: Good (supports transparency)
- **GIF**: Supported

### Ukuran

- **Minimum**: 640x480 pixels
- **Recommended**: 1024x768 pixels
- **Maximum**: 2048x2048 pixels

### Karakteristik Gambar yang Baik

✅ **Good Image Targets:**
- High contrast
- Rich in detail
- Unique patterns
- Clear edges
- Non-repetitive

❌ **Bad Image Targets:**
- Low contrast
- Blurry
- Repetitive patterns
- Solid colors
- Too simple

### Contoh

**Good:**
- Product photos dengan detail
- Logos dengan banyak elemen
- Poster dengan text dan gambar
- Packaging dengan design unik

**Bad:**
- Plain white/black background
- Blurry photos
- Repetitive patterns (polka dots, stripes)
- Very small images

## 🔄 Integration dengan AR Camera

### Flow:

```
1. User upload image target
   ↓
2. Image disimpan di Supabase
   ↓
3. AR Camera download image targets
   ↓
4. Camera detect image target
   ↓
5. Display 3D model di atas image target
```

### Implementation (Future):

```dart
// Di AR Camera Screen
final imageTargets = await ImageTargetService().getImageTargets();

for (final target in imageTargets) {
  // Download image
  final imageData = await downloadImage(target.imageTarget);
  
  // Register sebagai AR marker
  arController.addImageTarget(
    name: target.name,
    imageData: imageData,
  );
}
```

## 🚀 Setup Supabase

### 1. Pastikan Bucket `images` Sudah Ada

Di Supabase Dashboard → **Storage**:
- Bucket name: `images`
- Public: ✅

### 2. Pastikan Tabel `image_target` Sudah Ada

Di Supabase Dashboard → **SQL Editor**:

```sql
-- Create table if not exists
CREATE TABLE IF NOT EXISTS image_target (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  image_target TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE image_target ENABLE ROW LEVEL SECURITY;

-- Allow all operations (development)
CREATE POLICY "Allow all operations" ON image_target
  FOR ALL
  USING (true)
  WITH CHECK (true);
```

## 🐛 Troubleshooting

### Image Tidak Muncul

1. Cek URL di database valid
2. Cek bucket `images` public
3. Cek internet connection
4. Refresh list

### Upload Gagal

1. Cek file format (JPG/PNG/GIF)
2. Cek file size tidak terlalu besar (< 10MB)
3. Cek Supabase credentials
4. Cek console logs untuk error detail

### Delete Gagal

1. Cek ID valid
2. Cek permission di Supabase
3. Cek RLS policies

## 📊 Performance Tips

### Optimize Images

```bash
# Compress JPG
convert input.jpg -quality 85 output.jpg

# Resize
convert input.jpg -resize 1024x768 output.jpg

# Convert PNG to JPG
convert input.png -quality 85 output.jpg
```

### Lazy Loading

Grid view menggunakan lazy loading otomatis untuk performa optimal.

## 🔐 Security

### Development

- Public bucket
- Allow all RLS policy

### Production (Recommended)

```sql
-- Only authenticated users can upload
CREATE POLICY "Authenticated users can insert" ON image_target
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Users can only delete their own images
CREATE POLICY "Users can delete own images" ON image_target
  FOR DELETE
  USING (auth.uid() = user_id); -- Add user_id column
```

## 📚 Resources

- [AR Image Tracking Guide](https://developers.google.com/ar/develop/c/augmented-images)
- [Best Practices for Image Targets](https://library.vuforia.com/articles/Solution/Optimizing-Target-Detection-and-Tracking-Stability)
- [Supabase Storage Docs](https://supabase.com/docs/guides/storage)

## 🆘 Support

Jika ada masalah:
1. Cek dokumentasi ini
2. Cek console logs
3. Cek Supabase Dashboard
4. Hubungi developer: Alvinda Shahrul

---

**Version**: 1.0.0  
**Last Updated**: April 23, 2026  
**Author**: Alvinda Shahrul
