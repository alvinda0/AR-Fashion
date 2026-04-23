# Panduan Upload Model 3D Custom

## Fitur Upload Model

Aplikasi AR Fashion sekarang mendukung upload model 3D custom yang memungkinkan pengguna untuk menambahkan model mereka sendiri ke dalam aplikasi.

## Cara Menggunakan

### 1. Akses Menu Upload Model
- Buka aplikasi AR Fashion
- Pada halaman utama, pilih menu **"Upload Model"**
- Anda akan diarahkan ke halaman upload model

### 2. Upload Model 3D
- Klik tombol **"Pilih File"**
- Pilih file model 3D dari perangkat Anda
- Format yang didukung: **GLB** dan **GLTF**
- Masukkan nama untuk model Anda
- Klik **"Simpan"**

### 3. Kelola Model
- Lihat daftar semua model yang telah diupload
- Klik ikon **info** untuk melihat detail model
- Klik ikon **hapus** untuk menghapus model

## Format File yang Didukung

### GLB (GL Transmission Format Binary)
- Format binary yang lebih efisien
- Semua asset (texture, material) dalam satu file
- **Direkomendasikan** untuk performa terbaik

### GLTF (GL Transmission Format)
- Format JSON yang lebih mudah dibaca
- Asset terpisah dalam file berbeda
- Cocok untuk debugging dan editing

## Persiapan Model 3D

### Rekomendasi Model
1. **Ukuran File**: Maksimal 50MB untuk performa optimal
2. **Polygon Count**: 10,000 - 50,000 triangles
3. **Texture**: Maksimal 2048x2048 pixels
4. **Format**: GLB lebih direkomendasikan

### Optimasi Model
```bash
# Menggunakan gltf-pipeline untuk optimasi
npm install -g gltf-pipeline

# Optimasi GLB
gltf-pipeline -i input.glb -o output.glb -d
```

### Konversi dari Format Lain

#### Dari FBX ke GLB
```bash
# Menggunakan FBX2glTF
fbx2gltf input.fbx

# Atau menggunakan Blender
blender --background --python convert_fbx_to_glb.py -- input.fbx output.glb
```

#### Dari OBJ ke GLB
```bash
# Menggunakan obj2gltf
npm install -g obj2gltf
obj2gltf -i input.obj -o output.glb
```

## Struktur Penyimpanan

Model yang diupload disimpan di:
```
/data/user/0/com.example.ar/app_flutter/custom_models/
```

Metadata model disimpan menggunakan SharedPreferences dengan struktur:
```json
{
  "id": "timestamp_id",
  "name": "Nama Model",
  "filePath": "/path/to/model.glb",
  "imagePath": "/path/to/thumbnail.jpg",
  "uploadedAt": "2026-04-23T10:30:00.000Z"
}
```

## Fitur yang Tersedia

### ✅ Sudah Tersedia
- Upload file GLB/GLTF
- Simpan model ke storage lokal
- Lihat daftar model yang diupload
- Hapus model
- Lihat detail model (nama, tanggal upload, path)

### 🚧 Akan Datang
- Preview model 3D sebelum upload
- Edit nama model
- Tambah thumbnail custom
- Kategori model
- Share model antar pengguna
- Cloud storage integration

## Troubleshooting

### Model Tidak Muncul
1. Pastikan format file adalah GLB atau GLTF
2. Cek ukuran file tidak terlalu besar (>100MB)
3. Restart aplikasi

### Error Saat Upload
1. Pastikan ada ruang penyimpanan yang cukup
2. Cek permission storage sudah diberikan
3. Pastikan file tidak corrupt

### Model Tidak Ter-render dengan Baik
1. Cek model di viewer 3D lain (Blender, 3D Viewer)
2. Optimasi polygon count
3. Compress texture
4. Pastikan material compatible dengan PBR

## Tips & Best Practices

### 1. Optimasi Performa
- Gunakan format GLB untuk file size lebih kecil
- Compress texture menggunakan tools seperti Squoosh
- Reduce polygon count jika model terlalu berat

### 2. Kualitas Visual
- Gunakan PBR materials untuk hasil realistis
- Tambahkan normal maps untuk detail
- Pastikan UV mapping sudah benar

### 3. Kompatibilitas
- Test model di berbagai device
- Pastikan scale model sesuai
- Cek orientation model (up axis)

## Contoh Workflow

### Upload Model Fashion Custom
```
1. Buat/download model 3D fashion (dress, shoes, etc.)
2. Export ke format GLB dari Blender/3D software
3. Optimasi file size jika perlu
4. Buka aplikasi AR Fashion
5. Pilih "Upload Model"
6. Pilih file GLB
7. Beri nama model (contoh: "Red Evening Dress")
8. Klik Simpan
9. Model siap digunakan!
```

## Resources

### Tools untuk 3D Modeling
- **Blender**: Free, open-source 3D software
- **SketchUp**: Easy to use, good for beginners
- **Maya/3ds Max**: Professional tools

### Online Converters
- **Sketchfab**: Upload dan convert berbagai format
- **Blackthread GLB Viewer**: Preview GLB online
- **gltf.report**: Analyze dan optimasi GLTF/GLB

### Free 3D Models
- **Sketchfab**: Ribuan model gratis
- **TurboSquid**: Model berkualitas tinggi
- **CGTrader**: Marketplace 3D models
- **Free3D**: Koleksi model gratis

## API Reference

### CustomModelService

```dart
// Get all custom models
List<CustomModel> models = await CustomModelService().getCustomModels();

// Save new model
await CustomModelService().saveCustomModel(customModel);

// Delete model
await CustomModelService().deleteCustomModel(modelId);

// Copy file to app directory
String newPath = await CustomModelService().copyFileToAppDirectory(file, fileName);
```

### CustomModel Class

```dart
class CustomModel {
  final String id;
  final String name;
  final String filePath;
  final String? imagePath;
  final DateTime uploadedAt;
}
```

## Support

Jika mengalami masalah atau memiliki pertanyaan:
1. Cek dokumentasi ini terlebih dahulu
2. Lihat contoh di folder `assets/glb/`
3. Hubungi developer: Alvinda Shahrul

---

**Version**: 1.0.0  
**Last Updated**: April 23, 2026  
**Author**: Alvinda Shahrul
