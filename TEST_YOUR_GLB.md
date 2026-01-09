# Testing File GLB: tes.glb

## ✅ **Status: File GLB Anda Sudah Terintegrasi!**

File GLB Anda `tes.glb` sudah berhasil ditambahkan ke aplikasi Fashion AR dengan konfigurasi berikut:

### 📁 **Lokasi File:**
```
assets/models/clothing/dresses/tes.glb
```

### 🎯 **Konfigurasi di Aplikasi:**
```dart
FashionItem(
  id: 'dress_tes',
  name: 'Dress Tes Custom',
  category: 'dresses',
  modelPath: 'assets/models/clothing/dresses/tes.glb',
  thumbnailPath: 'assets/images/dress_tes_thumb.jpg',
  description: 'Dress custom untuk testing AR Fashion',
  colors: ['Default', 'Putih', 'Hitam'],
  sizes: ['XS', 'S', 'M', 'L'],
  price: 200000,
),
```

## 🚀 **Cara Test File GLB Anda:**

### **Step 1: Run Aplikasi**
```bash
flutter run
```

### **Step 2: Navigate ke AR Camera**
1. Buka aplikasi Fashion AR
2. Tap tombol "Mulai AR Try-On"
3. Berikan permission kamera jika diminta

### **Step 3: Pilih File GLB Anda**
1. Tap tombol fashion selector (👔) di bagian bawah
2. Pilih tab "Dress" 
3. Cari item "Dress Tes Custom"
4. Tap untuk memilih

### **Step 4: Test AR Display**
1. File GLB akan muncul sebagai 3D overlay
2. Test controls:
   - ✅ Auto-rotate
   - ✅ Camera controls (drag to rotate)
   - ✅ Zoom in/out
3. Toggle visibility dengan tombol mata (👁️)
4. Lihat info detail dengan tombol info (ℹ️)

## 🔍 **Troubleshooting File GLB**

### **Jika Model Tidak Muncul:**

#### **1. Check File Path**
Pastikan file benar-benar ada di:
```
assets/models/clothing/dresses/tes.glb
```

#### **2. Validate GLB File**
Test file GLB di online viewer:
- https://gltf-viewer.donmccurdy.com/
- https://sandbox.babylonjs.com/
- Drag & drop file tes.glb untuk test

#### **3. Check File Size**
```bash
# Check ukuran file
dir assets\models\clothing\dresses\tes.glb
```
Recommended: < 5MB untuk performance optimal

#### **4. Flutter Clean & Rebuild**
```bash
flutter clean
flutter pub get
flutter run
```

### **Jika Model Terlalu Besar/Kecil:**

#### **Adjust Scale di Code**
Edit `ar_camera_screen.dart`:
```dart
// Cari bagian _build3DModelOverlay dan adjust scale
ModelViewer(
  // ... other properties
  scale: "0.5 0.5 0.5",  // Adjust nilai ini (smaller = lebih kecil)
),
```

#### **Atau Edit di Blender:**
1. Open file GLB di Blender
2. Scale model (S key, lalu ketik angka)
3. Export ulang ke GLB

### **Jika Model Tidak Berorientasi dengan Benar:**

#### **Rotate di Code:**
```dart
ModelViewer(
  // ... other properties
  orientation: "0deg 180deg 0deg",  // Adjust rotation
),
```

#### **Atau Fix di Blender:**
1. Rotate model ke orientasi yang benar
2. Apply transformation (Ctrl+A)
3. Export ulang

## 📊 **Informasi File GLB Anda**

### **Current Configuration:**
- **ID**: `dress_tes`
- **Name**: `Dress Tes Custom`
- **Category**: `dresses`
- **Path**: `assets/models/clothing/dresses/tes.glb`
- **Price**: `Rp 200,000`

### **Customization Options:**

#### **Ubah Nama Display:**
```dart
name: 'Nama Baru Untuk Dress',
```

#### **Ubah Deskripsi:**
```dart
description: 'Deskripsi baru yang lebih menarik',
```

#### **Ubah Warna Options:**
```dart
colors: ['Merah', 'Biru', 'Hijau', 'Kuning'],
```

#### **Ubah Size Options:**
```dart
sizes: ['XS', 'S', 'M', 'L', 'XL'],
```

#### **Ubah Harga:**
```dart
price: 300000, // Rp 300,000
```

## 🎨 **Menambah Thumbnail Image**

### **Buat/Dapatkan Thumbnail:**
1. Screenshot dari 3D viewer
2. Render dari Blender
3. Photo dari model asli
4. Generate dari AI

### **Spesifikasi Thumbnail:**
- **Format**: JPG atau PNG
- **Size**: 300x400 pixels (recommended)
- **Nama**: `dress_tes_thumb.jpg`
- **Lokasi**: `assets/images/`

### **Tanpa Thumbnail:**
Aplikasi akan menampilkan placeholder otomatis dengan icon baju.

## 🔄 **Update File GLB**

### **Jika Ingin Ganti File GLB:**
1. Replace file `tes.glb` dengan file baru
2. Keep nama file sama, atau update `modelPath` di code
3. Run `flutter clean` dan `flutter pub get`
4. Test ulang di aplikasi

### **Jika Ingin Tambah File GLB Lain:**
1. Copy file GLB baru ke folder kategori yang sesuai
2. Tambah entry baru di `fashion_data_service.dart`
3. Test di aplikasi

## ✅ **Checklist Testing**

### **Basic Functionality:**
- [ ] File GLB muncul di fashion selector
- [ ] Bisa select item "Dress Tes Custom"
- [ ] Model 3D tampil di AR overlay
- [ ] Bisa rotate dan zoom model
- [ ] Toggle visibility berfungsi
- [ ] Info dialog menampilkan data yang benar

### **Performance:**
- [ ] Loading time < 3 detik
- [ ] Smooth rotation dan zoom
- [ ] Tidak ada lag saat switch visibility
- [ ] Memory usage normal

### **Visual Quality:**
- [ ] Model tampil dengan jelas
- [ ] Materials/textures terlihat baik
- [ ] Tidak ada missing parts
- [ ] Scale/size sesuai
- [ ] Orientasi benar

## 🎉 **Selamat!**

File GLB `tes.glb` Anda sudah siap digunakan dalam aplikasi Fashion AR!

### **Next Steps:**
1. ✅ Test di aplikasi
2. ✅ Adjust scale/orientation jika perlu
3. ✅ Tambah thumbnail image (opsional)
4. ✅ Customize nama, deskripsi, harga
5. ✅ Tambah file GLB lain jika ada

**Happy AR Fashion Testing! 👗📱✨**