# Fashion AR - Panduan Penempatan File GLB

## 📁 **Lokasi File GLB Anda**

Karena Anda sudah memiliki file GLB (format yang tepat!), berikut adalah lokasi yang tepat untuk menempatkannya:

### **Struktur Folder Lengkap:**
```
assets/models/clothing/
├── shirts/              # ← Kemeja, Kaos, Blouse
│   ├── your_shirt.glb
│   ├── casual_shirt.glb
│   └── t_shirt.glb
├── jackets/             # ← Jaket, Blazer, Coat
│   ├── your_jacket.glb
│   ├── denim_jacket.glb
│   └── leather_jacket.glb
├── dresses/             # ← Dress, Gaun
│   ├── your_dress.glb
│   ├── summer_dress.glb
│   └── evening_dress.glb
├── pants/               # ← Celana, Jeans
│   ├── your_pants.glb
│   └── casual_pants.glb
└── accessories/         # ← Topi, Kacamata, Kalung
    ├── your_hat.glb
    ├── glasses.glb
    └── necklace.glb
```

## 🎯 **Cara Menentukan Folder yang Tepat**

### **Berdasarkan Jenis Pakaian:**

#### **📂 shirts/** - Untuk:
- Kemeja (shirt, blouse)
- Kaos (t-shirt, polo)
- Tank top
- Sweater ringan

#### **📂 jackets/** - Untuk:
- Jaket (jacket, coat)
- Blazer
- Hoodie
- Cardigan
- Sweater tebal

#### **📂 dresses/** - Untuk:
- Dress pendek/panjang
- Gaun
- Jumpsuit
- Overall dress

#### **📂 pants/** - Untuk:
- Celana panjang
- Celana pendek
- Jeans
- Legging
- Rok (skirt)

#### **📂 accessories/** - Untuk:
- Topi (hat, cap)
- Kacamata (glasses)
- Kalung (necklace)
- Anting (earrings)
- Jam tangan (watch)

## 🚀 **Langkah-langkah Lengkap**

### **Step 1: Copy File GLB ke Folder yang Tepat**

**Contoh untuk Kemeja:**
```bash
# Copy file GLB kemeja Anda
copy "C:\path\to\your\shirt.glb" "assets\models\clothing\shirts\my_shirt.glb"
```

**Contoh untuk Jaket:**
```bash
# Copy file GLB jaket Anda
copy "C:\path\to\your\jacket.glb" "assets\models\clothing\jackets\my_jacket.glb"
```

**Contoh untuk Dress:**
```bash
# Copy file GLB dress Anda
copy "C:\path\to\your\dress.glb" "assets\models\clothing\dresses\my_dress.glb"
```

### **Step 2: Update Data Service**

Setelah menempatkan file GLB, tambahkan entry di `lib/services/fashion_data_service.dart`:

```dart
// Tambahkan di dalam list _fashionItems
FashionItem(
  id: 'my_custom_shirt',                    // ID unik
  name: 'Kemeja Custom Saya',               // Nama yang ditampilkan
  category: 'shirts',                       // Kategori folder
  modelPath: 'assets/models/clothing/shirts/my_shirt.glb',  // Path file GLB
  thumbnailPath: 'assets/images/my_shirt_thumb.jpg',        // Thumbnail
  description: 'Kemeja custom yang saya buat',
  colors: ['Putih', 'Biru', 'Hitam'],
  sizes: ['S', 'M', 'L', 'XL'],
  price: 250000,
),
```

### **Step 3: Tambahkan Thumbnail (Opsional)**

Buat atau tambahkan gambar thumbnail di `assets/images/`:
```
assets/images/
├── my_shirt_thumb.jpg      # Thumbnail untuk kemeja
├── my_jacket_thumb.jpg     # Thumbnail untuk jaket
└── my_dress_thumb.jpg      # Thumbnail untuk dress
```

### **Step 4: Update pubspec.yaml (Jika Perlu)**

Pastikan assets sudah terdaftar di `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/models/
    - assets/textures/
    - assets/images/
```

## 📝 **Template untuk Berbagai Jenis**

### **Untuk Kemeja/Kaos:**
```dart
FashionItem(
  id: 'my_shirt_001',
  name: 'Kemeja Saya',
  category: 'shirts',
  modelPath: 'assets/models/clothing/shirts/my_shirt.glb',
  thumbnailPath: 'assets/images/my_shirt_thumb.jpg',
  description: 'Kemeja custom dengan desain unik',
  colors: ['Putih', 'Biru', 'Hitam'],
  sizes: ['S', 'M', 'L', 'XL'],
  price: 200000,
),
```

### **Untuk Jaket:**
```dart
FashionItem(
  id: 'my_jacket_001',
  name: 'Jaket Saya',
  category: 'jackets',
  modelPath: 'assets/models/clothing/jackets/my_jacket.glb',
  thumbnailPath: 'assets/images/my_jacket_thumb.jpg',
  description: 'Jaket stylish untuk cuaca dingin',
  colors: ['Hitam', 'Navy', 'Coklat'],
  sizes: ['S', 'M', 'L', 'XL'],
  price: 350000,
),
```

### **Untuk Dress:**
```dart
FashionItem(
  id: 'my_dress_001',
  name: 'Dress Saya',
  category: 'dresses',
  modelPath: 'assets/models/clothing/dresses/my_dress.glb',
  thumbnailPath: 'assets/images/my_dress_thumb.jpg',
  description: 'Dress elegan untuk acara special',
  colors: ['Merah', 'Biru', 'Hitam'],
  sizes: ['XS', 'S', 'M', 'L'],
  price: 400000,
),
```

### **Untuk Celana:**
```dart
FashionItem(
  id: 'my_pants_001',
  name: 'Celana Saya',
  category: 'pants',
  modelPath: 'assets/models/clothing/pants/my_pants.glb',
  thumbnailPath: 'assets/images/my_pants_thumb.jpg',
  description: 'Celana casual yang nyaman',
  colors: ['Biru', 'Hitam', 'Khaki'],
  sizes: ['28', '30', '32', '34', '36'],
  price: 300000,
),
```

### **Untuk Aksesoris:**
```dart
FashionItem(
  id: 'my_accessory_001',
  name: 'Aksesoris Saya',
  category: 'accessories',
  modelPath: 'assets/models/clothing/accessories/my_accessory.glb',
  thumbnailPath: 'assets/images/my_accessory_thumb.jpg',
  description: 'Aksesoris unik untuk melengkapi outfit',
  colors: ['Gold', 'Silver', 'Rose Gold'],
  sizes: ['One Size'],
  price: 150000,
),
```

## ✅ **Checklist Penambahan File GLB**

### **Sebelum Menambahkan:**
- [ ] File GLB sudah siap dan valid
- [ ] Tentukan kategori yang tepat (shirts/jackets/dresses/pants/accessories)
- [ ] Siapkan nama file yang deskriptif
- [ ] (Opsional) Siapkan gambar thumbnail

### **Proses Penambahan:**
- [ ] Copy file GLB ke folder kategori yang tepat
- [ ] Buat entry baru di `fashion_data_service.dart`
- [ ] (Opsional) Tambahkan thumbnail image
- [ ] Test di aplikasi

### **Setelah Menambahkan:**
- [ ] Run `flutter pub get`
- [ ] Test aplikasi di emulator/device
- [ ] Pastikan model muncul di fashion selector
- [ ] Test AR display functionality

## 🔍 **Troubleshooting**

### **File GLB Tidak Muncul:**
1. ✅ Pastikan path di `modelPath` benar
2. ✅ Check apakah file GLB valid
3. ✅ Pastikan assets terdaftar di `pubspec.yaml`
4. ✅ Run `flutter clean` dan `flutter pub get`

### **Model Tidak Tampil dengan Benar:**
1. ✅ Check ukuran file GLB (< 5MB recommended)
2. ✅ Validate GLB dengan online validator
3. ✅ Pastikan model memiliki materials
4. ✅ Check polygon count (< 10k triangles)

### **Performance Issues:**
1. ✅ Compress GLB dengan gltf-pipeline
2. ✅ Reduce texture resolution
3. ✅ Optimize polygon count
4. ✅ Use Draco compression

## 📱 **Test di Aplikasi**

Setelah menambahkan file GLB:

1. **Run aplikasi:**
   ```bash
   flutter run
   ```

2. **Test workflow:**
   - Buka aplikasi
   - Tap "Mulai AR Try-On"
   - Tap tombol fashion selector (👔)
   - Pilih kategori yang sesuai
   - Cari item yang baru ditambahkan
   - Tap untuk select
   - Test AR display

3. **Verify functionality:**
   - Model muncul di AR overlay
   - 3D controls berfungsi (rotate, zoom)
   - Info dialog menampilkan data yang benar

## 🎉 **Selesai!**

File GLB Anda sekarang siap digunakan dalam aplikasi Fashion AR! 

**Lokasi file GLB Anda:**
```
assets/models/clothing/[kategori]/your_file.glb
```

**Next steps:**
1. Copy file GLB ke folder kategori yang tepat
2. Update `fashion_data_service.dart`
3. Test di aplikasi
4. Enjoy your custom 3D fashion items! ✨