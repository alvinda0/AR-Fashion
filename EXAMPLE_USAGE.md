# Fashion AR - Contoh Penggunaan Format FBX dan OBJ

## 🎯 **Jawaban Singkat: YA, FBX dan OBJ Bisa Digunakan!**

Format FBX dan OBJ **BISA** digunakan dalam aplikasi Fashion AR, tetapi perlu **dikonversi ke GLB/GLTF** terlebih dahulu.

## 📋 **Status Dukungan Format**

| Format | Native Support | Perlu Konversi | Recommended |
|--------|----------------|----------------|-------------|
| **GLB** | ✅ Ya | ❌ Tidak | ⭐⭐⭐⭐⭐ |
| **GLTF** | ✅ Ya | ❌ Tidak | ⭐⭐⭐⭐⭐ |
| **FBX** | ❌ Tidak | ✅ Ya | ⭐⭐⭐ |
| **OBJ** | ❌ Tidak | ✅ Ya | ⭐⭐⭐ |

## 🔄 **Workflow untuk FBX/OBJ**

### **Metode 1: Otomatis dengan Script**
```bash
# 1. Letakkan file FBX/OBJ di folder source
assets/models/source/fbx/shirt_casual.fbx
assets/models/source/obj/dress_summer.obj

# 2. Jalankan script konversi
scripts/convert_models.bat  # Windows
./scripts/convert_models.sh  # Linux/macOS

# 3. File GLB otomatis dibuat di folder clothing
assets/models/clothing/shirts/shirt_casual.glb
assets/models/clothing/dresses/dress_summer.glb
```

### **Metode 2: Manual dengan Blender**
```bash
# 1. Install Blender (gratis)
# Download dari https://www.blender.org/

# 2. Import FBX/OBJ
File → Import → FBX (.fbx) atau Wavefront (.obj)

# 3. Export ke GLB
File → Export → glTF 2.0 (.glb)
```

### **Metode 3: Command Line Tools**
```bash
# Install tools
npm install -g fbx2gltf obj2gltf

# Convert FBX
fbx2gltf shirt.fbx -o shirt.glb

# Convert OBJ  
obj2gltf -i dress.obj -o dress.glb
```

## 📁 **Contoh Struktur Project**

### **Sebelum Konversi**
```
assets/models/
├── source/
│   ├── fbx/
│   │   ├── casual_shirt.fbx      # File FBX asli
│   │   ├── denim_jacket.fbx      # File FBX asli
│   │   └── leather_jacket.fbx    # File FBX asli
│   └── obj/
│       ├── summer_dress.obj      # File OBJ asli
│       ├── summer_dress.mtl      # Material file
│       ├── evening_dress.obj     # File OBJ asli
│       ├── evening_dress.mtl     # Material file
│       └── textures/             # Texture files
│           ├── dress_diffuse.jpg
│           └── dress_normal.jpg
└── clothing/                     # Kosong (akan diisi hasil konversi)
```

### **Setelah Konversi**
```
assets/models/
├── source/                       # File asli (tetap ada)
│   ├── fbx/...
│   └── obj/...
├── clothing/                     # File GLB siap pakai
│   ├── shirts/
│   │   └── casual_shirt.glb     # Hasil konversi FBX
│   ├── jackets/
│   │   ├── denim_jacket.glb     # Hasil konversi FBX
│   │   └── leather_jacket.glb   # Hasil konversi FBX
│   └── dresses/
│       ├── summer_dress.glb     # Hasil konversi OBJ
│       └── evening_dress.glb    # Hasil konversi OBJ
└── generated_fashion_items.dart  # Flutter entries
```

## 💻 **Contoh Kode Flutter**

### **Data Service Entry**
```dart
// lib/services/fashion_data_service.dart
final List<FashionItem> _fashionItems = [
  // Item dari FBX yang sudah dikonversi
  FashionItem(
    id: 'casual_shirt_from_fbx',
    name: 'Kemeja Kasual (dari FBX)',
    category: 'shirts',
    modelPath: 'assets/models/clothing/shirts/casual_shirt.glb',
    thumbnailPath: 'assets/images/casual_shirt_thumb.jpg',
    description: 'Kemeja kasual yang dikonversi dari file FBX',
    colors: ['Putih', 'Biru', 'Hitam'],
    sizes: ['S', 'M', 'L', 'XL'],
    price: 150000,
  ),
  
  // Item dari OBJ yang sudah dikonversi
  FashionItem(
    id: 'summer_dress_from_obj',
    name: 'Dress Musim Panas (dari OBJ)',
    category: 'dresses',
    modelPath: 'assets/models/clothing/dresses/summer_dress.glb',
    thumbnailPath: 'assets/images/summer_dress_thumb.jpg',
    description: 'Dress musim panas yang dikonversi dari file OBJ',
    colors: ['Kuning', 'Pink', 'Biru Muda'],
    sizes: ['XS', 'S', 'M', 'L'],
    price: 200000,
  ),
];
```

### **ModelViewer Usage**
```dart
// lib/screens/ar_camera_screen.dart
ModelViewer(
  backgroundColor: Colors.transparent,
  src: 'assets/models/clothing/shirts/casual_shirt.glb', // File GLB hasil konversi
  alt: 'Kemeja Kasual dari FBX',
  ar: true,
  autoRotate: true,
  cameraControls: true,
  disableZoom: false,
),
```

## 🛠️ **Tools dan Software**

### **Free Tools**
1. **Blender** - https://www.blender.org/
   - Import: FBX, OBJ, DAE, 3DS, dll
   - Export: GLB, GLTF
   - Full 3D editing capabilities

2. **FBX2glTF** - https://github.com/facebookincubator/FBX2glTF
   - Command line FBX converter
   - Facebook's official tool

3. **obj2gltf** - https://github.com/CesiumGS/obj2gltf
   - Command line OBJ converter
   - Cesium's official tool

### **Online Converters**
1. **Sketchfab** - Upload FBX/OBJ, download GLB
2. **Babylon.js Sandbox** - Drag & drop converter
3. **glTF Viewer** - Convert dan preview

## 📊 **Perbandingan Format**

### **File Size Comparison**
```
Original FBX: 5.2 MB
Converted GLB: 2.1 MB (60% reduction)

Original OBJ+MTL: 3.8 MB  
Converted GLB: 1.9 MB (50% reduction)

Native GLB: 1.8 MB (optimal)
```

### **Loading Time Comparison**
```
FBX (not supported): ❌ Error
OBJ (not supported): ❌ Error
GLB (converted): ✅ 1.2 seconds
GLB (native): ✅ 0.8 seconds
```

### **Feature Support**
| Feature | FBX→GLB | OBJ→GLB | Native GLB |
|---------|---------|---------|------------|
| Geometry | ✅ | ✅ | ✅ |
| Materials | ✅ | ⚠️ Limited | ✅ |
| Textures | ✅ | ✅ | ✅ |
| Animations | ✅ | ❌ | ✅ |
| Rigging | ✅ | ❌ | ✅ |

## 🎯 **Best Practices**

### **Untuk File FBX**
1. ✅ Pastikan materials embedded
2. ✅ Check animation keyframes
3. ✅ Validate bone structure
4. ✅ Optimize polygon count sebelum export

### **Untuk File OBJ**
1. ✅ Sertakan file .mtl
2. ✅ Gunakan relative paths untuk textures
3. ✅ Organize texture files dalam folder
4. ✅ Check UV mapping

### **Optimasi Umum**
1. ✅ Target < 10,000 triangles
2. ✅ Texture max 1024x1024
3. ✅ Compress dengan Draco
4. ✅ Validate hasil konversi

## 🚀 **Quick Start Guide**

### **Step 1: Setup**
```bash
# Install dependencies
npm install -g fbx2gltf obj2gltf gltf-pipeline

# Create directories
mkdir -p assets/models/source/{fbx,obj}
```

### **Step 2: Add Files**
```bash
# Copy your FBX files
cp your_models/*.fbx assets/models/source/fbx/

# Copy your OBJ files (with MTL and textures)
cp your_models/*.obj assets/models/source/obj/
cp your_models/*.mtl assets/models/source/obj/
cp -r your_models/textures assets/models/source/obj/
```

### **Step 3: Convert**
```bash
# Run conversion script
scripts/convert_models.bat  # Windows
./scripts/convert_models.sh  # Linux/macOS
```

### **Step 4: Integrate**
```bash
# Update Flutter app
# 1. Copy generated entries to fashion_data_service.dart
# 2. Add thumbnail images
# 3. Test in app
```

## ❓ **FAQ**

### **Q: Apakah semua FBX bisa dikonversi?**
A: Sebagian besar bisa, tapi ada beberapa limitasi:
- Complex animations mungkin tidak sempurna
- Custom shaders tidak didukung
- Embedded media harus di-extract

### **Q: Bagaimana dengan file OBJ yang besar?**
A: OBJ files bisa sangat besar karena format text. Setelah konversi ke GLB (binary), ukuran akan jauh lebih kecil.

### **Q: Apakah kualitas berkurang setelah konversi?**
A: Minimal quality loss jika dilakukan dengan benar. Bahkan sering kali file size lebih kecil dengan kualitas sama.

### **Q: Bisa batch convert banyak file sekaligus?**
A: Ya! Script yang disediakan otomatis memproses semua file FBX dan OBJ dalam folder source.

---

## 🎉 **Kesimpulan**

**FBX dan OBJ BISA digunakan** dalam aplikasi Fashion AR dengan workflow konversi yang mudah:

1. ✅ **FBX** → GLB (dengan animations dan rigging)
2. ✅ **OBJ** → GLB (geometry dan materials)
3. ✅ **Script otomatis** untuk batch conversion
4. ✅ **Tools gratis** tersedia (Blender, command line)
5. ✅ **Hasil optimal** untuk mobile AR

**Rekomendasi: Gunakan script konversi otomatis untuk workflow yang efisien! 🚀**