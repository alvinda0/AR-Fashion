# 3D Models untuk Fashion AR

## Format yang Didukung

### ✅ **Format Utama (Native Support)**
- **GLB** (Binary glTF) - ⭐ **RECOMMENDED**
- **GLTF** (Text glTF) - ⭐ **RECOMMENDED**

### ⚠️ **Format yang Perlu Konversi**
- **FBX** - Perlu dikonversi ke GLB/GLTF
- **OBJ** - Perlu dikonversi ke GLB/GLTF
- **DAE** (Collada) - Perlu dikonversi ke GLB/GLTF
- **3DS** - Perlu dikonversi ke GLB/GLTF

## Mengapa GLB/GLTF?

### **Keunggulan GLB/GLTF:**
- ✅ Native support di Flutter ModelViewer
- ✅ Optimized untuk web dan mobile
- ✅ Mendukung PBR materials
- ✅ File size lebih kecil
- ✅ Loading time lebih cepat
- ✅ Mendukung animations dan rigging

### **Masalah dengan FBX/OBJ:**
- ❌ Tidak didukung langsung oleh ModelViewer
- ❌ File size lebih besar
- ❌ Loading time lebih lambat
- ❌ Compatibility issues
- ❌ Limited material support

## Cara Konversi Format

### 1. **FBX → GLB/GLTF**

#### **Menggunakan Blender (Gratis)**
```bash
# Install Blender dari https://www.blender.org/
# 1. Open Blender
# 2. File → Import → FBX (.fbx)
# 3. Select your FBX file
# 4. File → Export → glTF 2.0 (.glb/.gltf)
# 5. Choose GLB format untuk single file
```

#### **Menggunakan Online Converter**
- **Sketchfab Converter**: https://sketchfab.com/
- **Babylon.js Sandbox**: https://sandbox.babylonjs.com/
- **glTF Viewer**: https://gltf-viewer.donmccurdy.com/

#### **Menggunakan Command Line Tools**
```bash
# Install FBX2glTF
npm install -g fbx2gltf

# Convert FBX to GLB
fbx2gltf input.fbx -o output.glb

# Convert FBX to GLTF
fbx2gltf input.fbx -o output.gltf
```

### 2. **OBJ → GLB/GLTF**

#### **Menggunakan Blender**
```bash
# 1. Open Blender
# 2. File → Import → Wavefront (.obj)
# 3. Import both .obj and .mtl files
# 4. File → Export → glTF 2.0 (.glb/.gltf)
```

#### **Menggunakan Online Tools**
- **obj2gltf**: https://github.com/CesiumGS/obj2gltf
- **Three.js Editor**: https://threejs.org/editor/

#### **Command Line Conversion**
```bash
# Install obj2gltf
npm install -g obj2gltf

# Convert OBJ to GLB
obj2gltf -i input.obj -o output.glb

# Convert with materials
obj2gltf -i input.obj -o output.glb --materialsCommon
```

## Struktur Folder untuk Berbagai Format

```
assets/models/
├── source/                    # Format asli (FBX, OBJ, dll)
│   ├── fbx/
│   │   ├── shirt_casual.fbx
│   │   ├── jacket_denim.fbx
│   │   └── dress_summer.fbx
│   ├── obj/
│   │   ├── shirt_formal.obj
│   │   ├── shirt_formal.mtl
│   │   └── textures/
│   └── blend/                 # Blender files
│       ├── shirt_casual.blend
│       └── jacket_leather.blend
├── converted/                 # Hasil konversi
│   ├── temp_gltf/
│   └── temp_glb/
└── clothing/                  # Final GLB files untuk app
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

## Workflow Konversi

### **Step 1: Persiapan File Sumber**
```bash
# Organize source files
mkdir -p assets/models/source/{fbx,obj,blend}
mkdir -p assets/models/converted/{temp_gltf,temp_glb}
```

### **Step 2: Batch Conversion Script**
```bash
#!/bin/bash
# convert_models.sh

# Convert all FBX files
for file in assets/models/source/fbx/*.fbx; do
    filename=$(basename "$file" .fbx)
    fbx2gltf "$file" -o "assets/models/converted/temp_glb/${filename}.glb"
done

# Convert all OBJ files
for file in assets/models/source/obj/*.obj; do
    filename=$(basename "$file" .obj)
    obj2gltf -i "$file" -o "assets/models/converted/temp_glb/${filename}.glb"
done
```

### **Step 3: Optimasi dan Validasi**
```bash
# Install gltf-pipeline untuk optimasi
npm install -g gltf-pipeline

# Optimize GLB files
for file in assets/models/converted/temp_glb/*.glb; do
    filename=$(basename "$file")
    gltf-pipeline -i "$file" -o "assets/models/clothing/optimized_${filename}"
done
```

## Tools dan Software

### **Free Tools**
1. **Blender** - https://www.blender.org/
   - Full 3D modeling suite
   - Excellent import/export support
   - Built-in glTF exporter

2. **FBX2glTF** - https://github.com/facebookincubator/FBX2glTF
   - Command line converter
   - Facebook's official tool

3. **obj2gltf** - https://github.com/CesiumGS/obj2gltf
   - Cesium's OBJ converter
   - Good material support

### **Online Converters**
1. **Sketchfab** - Upload dan convert online
2. **Babylon.js Sandbox** - Drag & drop converter
3. **glTF Viewer** - View dan validate

### **Paid Tools**
1. **Autodesk Maya** - Professional 3D software
2. **3ds Max** - Industry standard
3. **Cinema 4D** - Motion graphics focused

## Optimasi untuk Mobile AR

### **Best Practices**
```bash
# 1. Reduce polygon count
# Target: < 10,000 triangles

# 2. Optimize textures
# Max resolution: 1024x1024
# Use compressed formats: JPG for diffuse, PNG for alpha

# 3. Simplify materials
# Use PBR workflow
# Minimize texture maps

# 4. Remove unnecessary data
# Delete unused vertices
# Clean up UV maps
# Remove hidden geometry
```

### **Validation Tools**
```bash
# Validate glTF files
npm install -g gltf-validator

# Validate file
gltf_validator assets/models/clothing/shirts/casual_shirt.glb

# Check file size and complexity
ls -lh assets/models/clothing/shirts/casual_shirt.glb
```

## Troubleshooting

### **Common Issues**

#### **1. FBX Import Errors**
```bash
# Solution: Update Blender to latest version
# Or use FBX2glTF command line tool
```

#### **2. Missing Materials**
```bash
# For OBJ files, ensure .mtl file is present
# For FBX, check embedded materials
```

#### **3. Large File Sizes**
```bash
# Use gltf-pipeline to compress
gltf-pipeline -i input.glb -o output.glb --draco.compressionLevel=7
```

#### **4. Animation Issues**
```bash
# Ensure bones are properly named
# Check animation keyframes
# Validate rigging in source file
```

## Integration dengan Flutter App

Setelah konversi, file GLB dapat langsung digunakan:

```dart
// Update fashion_data_service.dart
FashionItem(
  id: 'shirt_converted_from_fbx',
  name: 'Kemeja dari FBX',
  category: 'shirts',
  modelPath: 'assets/models/clothing/shirts/converted_shirt.glb',
  // ... other properties
),
```

---

**Kesimpulan: FBX dan OBJ bisa digunakan, tapi harus dikonversi ke GLB/GLTF terlebih dahulu untuk compatibility terbaik! 🔄✨**