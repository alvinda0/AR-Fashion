# FBX Models Folder

Folder ini berisi file FBX asli untuk fashion items.

## ⚠️ Important Note

File FBX **TIDAK BISA** langsung digunakan di Flutter. File ini perlu dikonversi ke format GLB terlebih dahulu.

## 📋 File List

- [x] dayana blue fbx.fbx (59.007 KB)
- [x] nayra black fbx.fbx (58.279 KB)
- [x] sabrina black fbx.fbx (60.221 KB)
- [x] sabrina white fbx.fbx (58.616 KB)
- [x] valerya pink fbx.fbx (58.362 KB)
- [x] xavia black fbx.fbx (57.018 KB)
- [x] xavia blue fbx.fbx (57.973 KB)
- [x] xavia blue old fbx.fbx (56.845 KB)
- [x] xavia purple fbx.fbx (28.363 KB)

## 🔄 Konversi ke GLB

### Quick Start

1. **Install Blender**
   - Download: https://www.blender.org/download/

2. **Run Conversion Script**
   - Windows: Double-click `convert_models.bat` di root project
   - Mac/Linux: Run `./convert_models.sh` di terminal

3. **Check Output**
   - File GLB akan tersimpan di `assets/glb/`

### Manual Conversion

Jika script tidak berfungsi, konversi manual:

1. Buka Blender
2. File → Import → FBX (.fbx)
3. Pilih file dari folder ini
4. File → Export → glTF 2.0 (.glb)
5. Pilih format: **glTF Binary (.glb)**
6. Simpan di `assets/glb/` dengan nama:
   - `dayana blue fbx.fbx` → `dayana_blue.glb`
   - `nayra black fbx.fbx` → `nayra_black.glb`
   - dst...

## 📚 Documentation

Lihat dokumentasi lengkap di root project:
- `CONVERT_FBX_TO_GLB.md` - Panduan konversi lengkap
- `QUICK_START_3D.md` - Quick start guide
- `3D_MODEL_USAGE.md` - Dokumentasi penggunaan

## 🎯 Target Output

Setelah konversi, file GLB harus ada di `assets/glb/`:
- dayana_blue.glb
- nayra_black.glb
- sabrina_black.glb
- sabrina_white.glb
- valerya_pink.glb
- xavia_black.glb
- xavia_blue.glb
- xavia_purple.glb

## 💡 Tips

1. **Backup File Asli**
   - Simpan file FBX asli sebagai backup
   - Jangan hapus setelah konversi

2. **Optimize Model**
   - Reduce polygon count jika perlu
   - Compress texture untuk performa lebih baik

3. **Test Model**
   - Test file GLB di https://gltf-viewer.donmccurdy.com/
   - Pastikan model ter-render dengan baik sebelum digunakan di app
