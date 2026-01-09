# Fashion AR Try-On App - Panduan Lengkap

## 🎯 Deskripsi Aplikasi

Aplikasi Fashion AR Try-On adalah aplikasi Flutter yang memungkinkan pengguna untuk mencoba pakaian secara virtual menggunakan teknologi Augmented Reality (AR). Aplikasi ini menggunakan kamera untuk mendeteksi tubuh manusia dan menampilkan model 3D pakaian yang dapat disesuaikan dengan posisi tubuh.

## 🏗️ Arsitektur Aplikasi

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/
│   └── fashion_item.dart     # Model data untuk item fashion
├── screens/
│   └── ar_camera_screen.dart # Screen utama AR camera
├── services/
│   ├── ar_service.dart       # Service untuk AR functionality
│   └── fashion_data_service.dart # Service untuk data fashion items
└── widgets/
    └── fashion_selector.dart # Widget untuk memilih fashion items

assets/
├── models/
│   └── clothing/
│       ├── shirts/           # Model 3D kemeja & kaos
│       ├── jackets/          # Model 3D jaket
│       └── dresses/          # Model 3D dress
├── textures/                 # Texture files untuk 3D models
└── images/                   # Thumbnail images
```

## 🚀 Fitur Utama

### 1. **AR Camera View**
- Live camera preview
- Real-time 3D model overlay
- Body tracking simulation

### 2. **Fashion Item Selection**
- Kategori: Kemeja & Kaos, Jaket, Dress
- Preview thumbnail
- Detail informasi (harga, warna, ukuran)

### 3. **3D Model Display**
- Model Viewer untuk menampilkan 3D objects
- Auto-rotate dan camera controls
- Transparent background untuk AR effect

### 4. **User Interface**
- Intuitive floating action buttons
- Fashion selector bottom sheet
- Item information dialog

## 📱 Cara Menggunakan Aplikasi

### 1. **Memulai Aplikasi**
1. Buka aplikasi Fashion AR
2. Tap tombol "Mulai AR Try-On"
3. Berikan permission kamera

### 2. **Memilih Fashion Item**
1. Tap tombol baju (👔) di bagian bawah
2. Pilih kategori yang diinginkan
3. Tap pada item fashion yang ingin dicoba

### 3. **Melihat AR Try-On**
1. Arahkan kamera ke tubuh Anda
2. Model 3D akan muncul sebagai overlay
3. Gunakan tombol visibility untuk show/hide model

### 4. **Melihat Detail Item**
1. Tap tombol info (ℹ️) 
2. Lihat detail harga, warna, dan ukuran
3. Close dialog untuk kembali ke AR view

## 🎨 Menambahkan Model 3D Baju

### Lokasi File 3D Models

Model 3D baju disimpan di folder:
```
assets/models/clothing/
├── shirts/
│   ├── casual_shirt.glb
│   ├── formal_shirt.glb
│   └── t_shirt.glb
├── jackets/
│   ├── denim_jacket.glb
│   ├── leather_jacket.glb
│   └── blazer.glb
└── dresses/
    ├── summer_dress.glb
    ├── evening_dress.glb
    └── casual_dress.glb
```

### Format yang Didukung

#### ✅ **Format Utama (Native Support)**
- **GLB** (Binary glTF) - ⭐ **RECOMMENDED**
- **GLTF** (Text glTF) - ⭐ **RECOMMENDED**

#### ⚠️ **Format yang Perlu Konversi**
- **FBX** - Perlu dikonversi ke GLB/GLTF
- **OBJ** - Perlu dikonversi ke GLB/GLTF
- **DAE** (Collada) - Perlu dikonversi ke GLB/GLTF

### Mengapa GLB/GLTF?

**Keunggulan GLB/GLTF:**
- ✅ Native support di Flutter ModelViewer
- ✅ Optimized untuk web dan mobile
- ✅ File size lebih kecil dan loading lebih cepat
- ✅ Mendukung PBR materials dan animations

**Masalah dengan FBX/OBJ:**
- ❌ Tidak didukung langsung oleh ModelViewer
- ❌ File size lebih besar dan loading lambat
- ❌ Compatibility issues dan limited material support

### Cara Konversi Format

#### **Otomatis dengan Script**
```bash
# Windows
scripts\convert_models.bat

# Linux/macOS
chmod +x scripts/convert_models.sh
./scripts/convert_models.sh
```

#### **Manual dengan Blender**
1. Install Blender dari https://www.blender.org/
2. File → Import → FBX (.fbx) atau Wavefront (.obj)
3. File → Export → glTF 2.0 (.glb)
4. Pilih GLB format untuk single file

#### **Command Line Tools**
```bash
# Install tools
npm install -g fbx2gltf obj2gltf gltf-pipeline

# Convert FBX to GLB
fbx2gltf input.fbx -o output.glb

# Convert OBJ to GLB
obj2gltf -i input.obj -o output.glb

# Optimize GLB
gltf-pipeline -i input.glb -o optimized.glb --draco.compressionLevel=7
```

### Workflow Lengkap

#### **Step 1: Siapkan File Sumber**
```
assets/models/source/
├── fbx/
│   ├── shirt_casual.fbx
│   └── jacket_denim.fbx
└── obj/
    ├── dress_summer.obj
    ├── dress_summer.mtl
    └── textures/
```

#### **Step 2: Jalankan Konversi**
```bash
# Otomatis convert semua file
scripts/convert_models.bat  # Windows
# atau
./scripts/convert_models.sh  # Linux/macOS
```

#### **Step 3: Update Data Service**
```dart
// File generated_fashion_items.dart akan dibuat otomatis
// Copy entries ke lib/services/fashion_data_service.dart
```

### Cara Mendapatkan Model 3D

#### 1. **Download dari Website**
- **Sketchfab**: https://sketchfab.com/3d-models/clothing
- **TurboSquid**: https://www.turbosquid.com/3d-models/clothing
- **CGTrader**: https://www.cgtrader.com/3d-models/clothing
- **Free3D**: https://free3d.com/3d-models/clothing

#### 2. **Buat Sendiri dengan Software 3D**
- **Blender** (Gratis): https://www.blender.org/
- **Maya** (Berbayar)
- **3ds Max** (Berbayar)
- **Cinema 4D** (Berbayar)

#### 3. **Gunakan AI Generator**
- **Meshy**: https://www.meshy.ai/
- **Luma AI**: https://lumalabs.ai/
- **Spline AI**: https://spline.design/ai

### Spesifikasi Model 3D

#### **Optimasi Performance**
- **Polygon Count**: < 10,000 triangles
- **Texture Resolution**: Maksimal 1024x1024 pixels
- **File Size**: < 5MB per model

#### **Rigging Requirements**
- Model harus memiliki bone structure
- Bone names harus konsisten dengan body tracking
- Support untuk deformasi saat fitting

#### **Material Properties**
- Gunakan PBR (Physically Based Rendering) materials
- Include diffuse, normal, dan roughness maps
- Transparent materials untuk fabric simulation

### Langkah Menambah Model Baru

#### **Untuk File GLB (Siap Pakai)**
1. Copy file GLB ke folder kategori yang sesuai
2. Update `fashion_data_service.dart`
3. Tambahkan thumbnail image

#### **Untuk File FBX/OBJ (Perlu Konversi)**
1. Copy file ke `assets/models/source/fbx/` atau `assets/models/source/obj/`
2. Jalankan script konversi
3. File GLB akan otomatis dibuat di folder yang sesuai
4. Update data service dengan entries yang di-generate

### Troubleshooting

#### **Conversion Errors**
```bash
# Check dependencies
python scripts/convert_models.py --check

# Manual conversion
fbx2gltf problematic_file.fbx -o output.glb --verbose
```

#### **Large File Sizes**
```bash
# Compress with Draco
gltf-pipeline -i input.glb -o compressed.glb --draco.compressionLevel=10
```

#### **Missing Materials**
- Untuk OBJ: Pastikan file .mtl ada
- Untuk FBX: Check embedded materials
- Re-export dengan materials included

### Validation Tools
```bash
# Validate GLB files
gltf_validator assets/models/clothing/shirts/shirt.glb

# Check file info
gltf-pipeline -i model.glb --stats
```

## 🔧 Konfigurasi Teknis

### Dependencies Utama

```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+9              # Camera functionality
  model_viewer_plus: ^1.7.2      # 3D model display
  permission_handler: ^11.3.1    # Camera permissions
  vector_math: ^2.1.4            # 3D calculations
```

### Android Permissions

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
```

### iOS Permissions

```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for AR try-on feature</string>
```

## 🎯 Pengembangan Lanjutan

### 1. **Real AR Integration**
- Implementasi ARCore (Android) / ARKit (iOS)
- Real-time body tracking
- Occlusion handling

### 2. **Advanced Body Tracking**
- MediaPipe integration
- Pose estimation
- Body segmentation

### 3. **Enhanced 3D Features**
- Physics simulation untuk fabric
- Lighting adaptation
- Shadow rendering

### 4. **Social Features**
- Photo capture
- Share to social media
- Virtual wardrobe

### 5. **E-commerce Integration**
- Shopping cart
- Payment gateway
- Order management

## 🐛 Troubleshooting

### Common Issues

#### 1. **Camera Permission Denied**
```dart
// Solution: Request permission properly
final status = await Permission.camera.request();
if (status.isDenied) {
  // Show permission dialog
}
```

#### 2. **3D Model Not Loading**
```dart
// Check file path and format
// Ensure GLB file is properly formatted
// Verify assets are included in pubspec.yaml
```

#### 3. **Performance Issues**
```dart
// Reduce model complexity
// Optimize textures
// Use lower camera resolution
```

## 📚 Resources

### Learning Materials
- [Flutter AR Development](https://flutter.dev/docs)
- [3D Modeling for AR](https://www.blender.org/support/tutorials/)
- [glTF Format Specification](https://www.khronos.org/gltf/)

### Tools & Software
- **Blender**: Free 3D modeling software
- **glTF Validator**: Validate 3D models
- **Model Viewer**: Test 3D models online

### Communities
- [Flutter Community](https://flutter.dev/community)
- [AR/VR Developers](https://www.reddit.com/r/augmentedreality/)
- [3D Modeling Communities](https://blenderartists.org/)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Happy AR Fashion Development! 👗📱✨**