# 🚨 URGENT: File GLB Terlalu Besar - Cara Compress

## ⚠️ **MASALAH KRITIS:**
File `tes.glb` berukuran **59.8 MB** - ini menyebabkan aplikasi crash!

**Ukuran maksimal untuk mobile: 5 MB**

## 🔧 **Solusi Langsung:**

### **Method 1: Online Compression**

#### **1. Upload ke glTF Compressor:**
- https://gltf.report/
- Upload file `tes.glb`
- Apply Draco compression
- Download hasil compress

#### **2. Babylon.js Sandbox:**
- https://sandbox.babylonjs.com/
- Drag & drop `tes.glb`
- Export dengan compression

### **Method 2: Command Line (Recommended)**

#### **Install gltf-pipeline:**
```bash
npm install -g gltf-pipeline
```

#### **Compress dengan Draco:**
```bash
# Navigate ke folder
cd assets/models/clothing/dresses/

# Backup original
copy tes.glb tes_original.glb

# Compress dengan maximum compression
gltf-pipeline -i tes_original.glb -o tes.glb --draco.compressionLevel=10 --draco.quantizePositionBits=11 --draco.quantizeNormalBits=8 --draco.quantizeTexcoordBits=10
```

### **Method 3: Blender Re-export**

#### **1. Open di Blender:**
```bash
# Import GLB
File → Import → glTF 2.0 (.glb/.gltf)
```

#### **2. Optimize Model:**
```bash
# Reduce polygon count
1. Select model
2. Modifier Properties → Add Modifier → Decimate
3. Set Ratio to 0.1 (reduce 90% polygons)
4. Apply modifier
```

#### **3. Optimize Textures:**
```bash
# Reduce texture resolution
1. Shading workspace
2. Select all texture nodes
3. Change image resolution to 512x512 or 256x256
```

#### **4. Re-export:**
```bash
File → Export → glTF 2.0 (.glb)
- Format: GLB
- Include: Selected Objects
- Transform: +Y Up
- Geometry: Apply Modifiers
- Compression: Enable
```

## 🎯 **Target Specifications:**

### **Mobile-Optimized GLB:**
- **File Size**: < 5 MB (ideal < 2 MB)
- **Polygons**: < 10,000 triangles
- **Textures**: Max 1024x1024 pixels
- **Materials**: Simplified PBR

### **Compression Settings:**
```bash
# Aggressive compression for mobile
gltf-pipeline -i input.glb -o output.glb \
  --draco.compressionLevel=10 \
  --draco.quantizePositionBits=11 \
  --draco.quantizeNormalBits=8 \
  --draco.quantizeTexcoordBits=10 \
  --draco.quantizeColorBits=8
```

## 🚀 **Quick Fix Steps:**

### **Step 1: Backup Original**
```bash
copy assets\models\clothing\dresses\tes.glb assets\models\clothing\dresses\tes_original.glb
```

### **Step 2: Compress Online**
1. Go to https://gltf.report/
2. Upload `tes_original.glb`
3. Apply maximum Draco compression
4. Download compressed version
5. Replace `tes.glb` with compressed version

### **Step 3: Test Size**
```bash
# Check new file size
dir assets\models\clothing\dresses\tes.glb
# Should be < 5 MB
```

### **Step 4: Test in App**
```bash
flutter clean
flutter pub get
flutter run
```

## 📊 **Expected Results:**

### **Before Compression:**
- File Size: 59.8 MB ❌
- App Status: Crashes ❌
- Loading Time: N/A (crashes) ❌

### **After Compression:**
- File Size: < 5 MB ✅
- App Status: Stable ✅
- Loading Time: < 3 seconds ✅

## 🔍 **Validation Tools:**

### **Check GLB Validity:**
```bash
# Install validator
npm install -g gltf-validator

# Validate compressed file
gltf_validator assets/models/clothing/dresses/tes.glb
```

### **Online Viewers:**
- https://gltf-viewer.donmccurdy.com/
- https://sandbox.babylonjs.com/

## ⚡ **Emergency Workaround:**

Jika tidak bisa compress sekarang, gunakan placeholder:

```dart
// Temporary disable 3D model untuk file besar
if (item.id == 'dress_tes') {
  _show3DModel = false;
  _showSnackBar('Model terlalu besar, sedang dioptimasi...');
}
```

## 🎯 **Action Plan:**

1. ✅ **Immediate**: Disable 3D model untuk `dress_tes` (sudah dilakukan)
2. 🔄 **Next**: Compress file GLB ke < 5 MB
3. ✅ **Final**: Test compressed model di aplikasi

**PRIORITAS TINGGI: Compress file GLB sebelum testing lebih lanjut! 🚨**