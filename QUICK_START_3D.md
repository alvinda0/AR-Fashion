# Quick Start: Menampilkan 3D Model di AR Camera

## 🎯 Tujuan

Menampilkan model 3D fashion ketika user mengklik item di AR Camera screen.

## ✅ Yang Sudah Dikerjakan

1. ✅ Update `ar_camera_screen.dart` dengan ModelViewer
2. ✅ Tambahkan import `model_viewer_plus`
3. ✅ Tambahkan field `model` di setiap fashion item
4. ✅ Tambahkan overlay untuk menampilkan 3D model
5. ✅ Tambahkan tombol close untuk menutup viewer
6. ✅ Update `pubspec.yaml` untuk include assets GLB

## 📋 Yang Perlu Dilakukan

### Step 1: Konversi FBX ke GLB

File FBX tidak bisa langsung digunakan di Flutter. Anda perlu konversi ke GLB terlebih dahulu.

#### Opsi A: Menggunakan Blender (Recommended)

1. **Install Blender**
   - Download: https://www.blender.org/download/
   - Install di komputer Anda

2. **Konversi Manual (Satu per Satu)**
   - Buka Blender
   - File → Import → FBX (.fbx)
   - Pilih file dari `assets/fbx/` (contoh: `dayana blue fbx.fbx`)
   - File → Export → glTF 2.0 (.glb)
   - Pilih format: **glTF Binary (.glb)**
   - Simpan di `assets/glb/` dengan nama: `dayana_blue.glb`
   - Ulangi untuk semua file

3. **Konversi Batch (Semua Sekaligus)**
   - Buka Command Prompt/Terminal di folder project
   - Jalankan: `convert_models.bat` (Windows)
   - Atau: `blender --background --python convert_fbx_to_glb.py`

#### Opsi B: Menggunakan Online Converter

1. Buka: https://products.aspose.app/3d/conversion/fbx-to-glb
2. Upload file FBX dari `assets/fbx/`
3. Download hasil GLB
4. Rename sesuai mapping di bawah
5. Simpan di `assets/glb/`

### Step 2: Mapping Nama File

Pastikan nama file GLB sesuai dengan yang ada di kode:

| File FBX                   | File GLB yang Dibutuhkan |
|----------------------------|--------------------------|
| dayana blue fbx.fbx        | dayana_blue.glb          |
| nayra black fbx.fbx        | nayra_black.glb          |
| sabrina black fbx.fbx      | sabrina_black.glb        |
| sabrina white fbx.fbx      | sabrina_white.glb        |
| valerya pink fbx.fbx       | valerya_pink.glb         |
| xavia black fbx.fbx        | xavia_black.glb          |
| xavia blue fbx.fbx         | xavia_blue.glb           |
| xavia purple fbx.fbx       | xavia_purple.glb         |

### Step 3: Letakkan File GLB

Setelah konversi, struktur folder harus seperti ini:

```
assets/
├── fbx/                          # File asli (opsional)
│   ├── dayana blue fbx.fbx
│   └── ...
├── glb/                          # File hasil konversi (REQUIRED)
│   ├── dayana_blue.glb          ← Harus ada
│   ├── nayra_black.glb          ← Harus ada
│   ├── sabrina_black.glb        ← Harus ada
│   ├── sabrina_white.glb        ← Harus ada
│   ├── valerya_pink.glb         ← Harus ada
│   ├── xavia_black.glb          ← Harus ada
│   ├── xavia_blue.glb           ← Harus ada
│   └── xavia_purple.glb         ← Harus ada
└── images/
    └── ...
```

### Step 4: Run Flutter App

```bash
# Get dependencies
flutter pub get

# Run app
flutter run
```

## 🎮 Cara Menggunakan

1. Buka aplikasi
2. Tap tombol "AR Camera" atau "Try On"
3. Camera akan terbuka dengan list item fashion di bawah
4. **Tap salah satu item fashion**
5. Model 3D akan muncul di tengah layar
6. Interaksi:
   - **Drag** untuk rotate model
   - **Pinch** untuk zoom in/out
   - **Tap tombol X** di kanan atas untuk close
   - **Tap tombol AR** (jika ada) untuk view in AR mode

## 🔧 Troubleshooting

### Model tidak muncul

1. **Cek apakah file GLB ada**
   ```bash
   ls assets/glb/
   ```
   Harus ada 8 file GLB

2. **Cek nama file**
   - Pastikan nama file exact match dengan yang di kode
   - Case sensitive! `dayana_blue.glb` ≠ `Dayana_Blue.glb`

3. **Run flutter pub get**
   ```bash
   flutter pub get
   ```

4. **Clean dan rebuild**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Error saat konversi FBX

1. **Blender not found**
   - Install Blender dari https://www.blender.org/download/
   - Add Blender ke system PATH

2. **File FBX corrupt**
   - Coba buka file FBX di Blender manual
   - Jika tidak bisa dibuka, file mungkin corrupt

3. **Export error**
   - Pastikan Blender versi terbaru (4.0+)
   - Coba export manual satu per satu

### Model terlalu besar/kecil

Edit di `ar_camera_screen.dart`:

```dart
ModelViewer(
  // ... other params
  cameraOrbit: '0deg 75deg 200%', // Adjust percentage
  // 105% = close
  // 200% = medium
  // 500% = far
)
```

### Performance lambat

1. **Compress model**
   ```bash
   npm install -g gltf-pipeline
   gltf-pipeline -i input.glb -o output.glb -d
   ```

2. **Reduce polygon count di Blender**
   - Add Decimate modifier
   - Set ratio to 0.5 (50% polygons)

## 📚 Dokumentasi Lengkap

- **Konversi FBX ke GLB**: `CONVERT_FBX_TO_GLB.md`
- **Penggunaan 3D Model**: `3D_MODEL_USAGE.md`
- **Customization**: Edit `lib/screens/ar_camera_screen.dart`

## 🆘 Butuh Bantuan?

1. Cek console untuk error messages:
   ```bash
   flutter run --verbose
   ```

2. Cek file log di:
   - Android: `adb logcat`
   - iOS: Xcode console

3. Test model di browser:
   - Buka: https://gltf-viewer.donmccurdy.com/
   - Upload file GLB untuk test

## ✨ Next Steps

Setelah 3D model berfungsi, Anda bisa:

1. **Tambahkan loading indicator**
2. **Tambahkan animation** (jika model punya animation)
3. **Tambahkan multiple camera angles**
4. **Tambahkan screenshot/share feature**
5. **Optimize performa** dengan compression

## 📝 Checklist

- [ ] Install Blender
- [ ] Konversi semua FBX ke GLB
- [ ] Letakkan file GLB di `assets/glb/`
- [ ] Cek nama file sesuai mapping
- [ ] Run `flutter pub get`
- [ ] Run `flutter run`
- [ ] Test tap item fashion
- [ ] Test rotate/zoom model
- [ ] Test close button

Selamat mencoba! 🚀
