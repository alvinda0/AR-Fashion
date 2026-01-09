# Fashion AR - Model Conversion Scripts

## 📁 Scripts Overview

Folder ini berisi script untuk mengkonversi model 3D dari format FBX dan OBJ ke GLB yang didukung oleh aplikasi Flutter.

## 🔧 Available Scripts

### 1. **convert_models.py** (Python)
Script utama untuk konversi model dengan fitur lengkap:
- ✅ Batch conversion FBX → GLB
- ✅ Batch conversion OBJ → GLB  
- ✅ Automatic optimization dengan Draco compression
- ✅ GLB validation
- ✅ Auto-generate Flutter data entries
- ✅ Cross-platform (Windows, Linux, macOS)

### 2. **convert_models.bat** (Windows)
Batch script untuk Windows:
- ✅ Dependency checking dan installation
- ✅ Directory structure creation
- ✅ Calls Python script
- ✅ User-friendly interface

### 3. **convert_models.sh** (Linux/macOS)
Shell script untuk Unix systems:
- ✅ Dependency checking dan installation
- ✅ Directory structure creation
- ✅ Calls Python script
- ✅ Executable permissions handling

## 🚀 Quick Start

### Windows
```bash
# Run the batch script
scripts\convert_models.bat
```

### Linux/macOS
```bash
# Make executable and run
chmod +x scripts/convert_models.sh
./scripts/convert_models.sh
```

### Python (Any OS)
```bash
# Check dependencies
python scripts/convert_models.py --check

# Run conversion
python scripts/convert_models.py
```

## 📋 Prerequisites

### Required Software
1. **Python 3.6+** - https://python.org
2. **Node.js 14+** - https://nodejs.org

### Required NPM Packages (Auto-installed)
- `fbx2gltf` - Facebook's FBX to glTF converter
- `obj2gltf` - Cesium's OBJ to glTF converter
- `gltf-pipeline` - glTF optimization tool
- `gltf-validator` - glTF validation tool

## 📂 Directory Structure

### Before Running Scripts
```
assets/models/
├── source/              # Place your source files here
│   ├── fbx/            # FBX files
│   │   ├── shirt.fbx
│   │   └── jacket.fbx
│   └── obj/            # OBJ files
│       ├── dress.obj
│       ├── dress.mtl
│       └── textures/
└── clothing/           # Will be created automatically
```

### After Running Scripts
```
assets/models/
├── source/             # Your original files (preserved)
├── converted/          # Temporary files (auto-cleaned)
├── clothing/           # Final GLB files for app
│   ├── shirts/
│   │   └── shirt.glb
│   ├── jackets/
│   │   └── jacket.glb
│   └── dresses/
│       └── dress.glb
└── generated_fashion_items.dart  # Flutter data entries
```

## ⚙️ Script Features

### Automatic Category Detection
Files are automatically categorized based on filename:
- `*shirt*`, `*tshirt*`, `*blouse*` → `shirts/`
- `*jacket*`, `*coat*`, `*blazer*` → `jackets/`
- `*dress*`, `*gown*` → `dresses/`
- `*pants*`, `*trousers*`, `*jeans*` → `pants/`
- `*hat*`, `*glasses*`, `*necklace*` → `accessories/`

### Optimization Settings
```bash
# Draco compression settings
--draco.compressionLevel=7
--draco.quantizePositionBits=11
--draco.quantizeNormalBits=8
--draco.quantizeTexcoordBits=10
```

### Validation Checks
- ✅ File format validation
- ✅ Polygon count check
- ✅ Texture resolution verification
- ✅ Material validation
- ✅ File size optimization

## 📊 Output Information

### Conversion Report
```
🔄 Processing shirt_casual.fbx...
✅ Converted shirt_casual.fbx → shirt_casual.glb
✅ Optimized shirt_casual.glb
   Size: 2,456,789 → 1,234,567 bytes (49.7% reduction)
✅ shirt_casual.glb is valid

✅ Conversion complete!
   Successfully converted: 5/5 files
   Output location: assets/models/clothing
```

### Generated Flutter Entries
```dart
// Generated Fashion Items
// Add these to your fashion_data_service.dart

FashionItem(
  id: 'shirt_casual',
  name: 'Shirt Casual',
  category: 'shirts',
  modelPath: 'assets/models/clothing/shirts/shirt_casual.glb',
  thumbnailPath: 'assets/images/shirt_casual_thumb.jpg',
  description: 'Converted from source model',
  colors: ['Default'],
  sizes: ['S', 'M', 'L'],
  price: 100000,
),
```

## 🔍 Troubleshooting

### Common Issues

#### 1. **Dependencies Not Found**
```bash
# Check what's missing
python scripts/convert_models.py --check

# Install manually
npm install -g fbx2gltf obj2gltf gltf-pipeline gltf-validator
```

#### 2. **Conversion Fails**
```bash
# Try manual conversion with verbose output
fbx2gltf input.fbx -o output.glb --verbose
```

#### 3. **Large File Sizes**
```bash
# Increase compression
gltf-pipeline -i input.glb -o output.glb --draco.compressionLevel=10
```

#### 4. **Missing Materials (OBJ)**
- Ensure .mtl file is in same directory
- Check texture paths in .mtl file
- Use relative paths for textures

#### 5. **Permission Errors (Linux/macOS)**
```bash
# Make scripts executable
chmod +x scripts/convert_models.sh
chmod +x scripts/convert_models.py
```

### Debug Mode
```bash
# Run with debug information
python scripts/convert_models.py --debug
```

## 📈 Performance Tips

### Source File Optimization
1. **Reduce Polygon Count** - Use decimation in Blender
2. **Optimize Textures** - Resize to 1024x1024 max
3. **Clean Geometry** - Remove hidden faces
4. **Merge Materials** - Reduce material count

### Batch Processing
```bash
# Process specific file types only
python scripts/convert_models.py --fbx-only
python scripts/convert_models.py --obj-only
```

## 🔄 Integration Workflow

### Step 1: Prepare Source Files
```bash
# Organize your files
mkdir -p assets/models/source/{fbx,obj}
# Copy your FBX/OBJ files to respective folders
```

### Step 2: Run Conversion
```bash
# Windows
scripts\convert_models.bat

# Linux/macOS  
./scripts/convert_models.sh
```

### Step 3: Update Flutter App
```bash
# 1. Copy generated entries to fashion_data_service.dart
# 2. Add thumbnail images to assets/images/
# 3. Update pubspec.yaml if needed
# 4. Run flutter pub get
# 5. Test the app
```

## 📝 Customization

### Modify Conversion Settings
Edit `convert_models.py`:
```python
# Change compression level
'--draco.compressionLevel=10'  # Higher = smaller files

# Change quantization
'--draco.quantizePositionBits=14'  # Higher = better quality
```

### Add Custom Categories
```python
def get_category_from_filename(self, filename):
    # Add your custom categories here
    if 'shoes' in filename.lower():
        return 'footwear'
    # ... existing code
```

### Custom Output Paths
```python
def __init__(self):
    self.output_dir = Path("custom/output/path")
    # ... existing code
```

## 🆘 Support

### Getting Help
1. Check this README first
2. Run dependency check: `python scripts/convert_models.py --check`
3. Try manual conversion for problematic files
4. Check file formats and sizes
5. Validate source files in Blender

### Reporting Issues
Include this information:
- Operating system
- Python version
- Node.js version
- Source file format and size
- Error messages
- Conversion command used

---

**Happy Converting! 🔄✨**