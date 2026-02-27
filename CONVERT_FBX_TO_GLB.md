# Panduan Konversi FBX ke GLB

## Mengapa Perlu Konversi?

Flutter tidak mendukung format FBX secara native. File FBX perlu dikonversi ke format GLB (GL Transmission Format Binary) yang didukung oleh `model_viewer_plus`.

## Cara Konversi FBX ke GLB

### Opsi 1: Menggunakan Blender (Gratis & Recommended)

1. **Download dan Install Blender**
   - Download dari: https://www.blender.org/download/
   - Install Blender di komputer Anda

2. **Import FBX File**
   - Buka Blender
   - File → Import → FBX (.fbx)
   - Pilih file FBX Anda (contoh: `dayana blue fbx.fbx`)

3. **Export ke GLB**
   - File → Export → glTF 2.0 (.glb/.gltf)
   - Pilih format: **glTF Binary (.glb)**
   - Atur settings:
     - Include: Selected Objects (atau All)
     - Transform: Apply Transform
     - Geometry: Apply Modifiers
   - Simpan dengan nama yang sesuai (contoh: `dayana_blue.glb`)

4. **Ulangi untuk semua file FBX**

### Opsi 2: Menggunakan Online Converter

1. **FBX2glTF (Facebook Tool)**
   - Download: https://github.com/facebookincubator/FBX2glTF
   - Command line tool yang powerful

2. **Online Converter**
   - https://products.aspose.app/3d/conversion/fbx-to-glb
   - https://anyconv.com/fbx-to-glb-converter/
   - Upload FBX, download GLB

### Opsi 3: Menggunakan Python Script

```python
# Install: pip install trimesh[easy]
import trimesh

# Load FBX
mesh = trimesh.load('dayana blue fbx.fbx')

# Export to GLB
mesh.export('dayana_blue.glb')
```

## Struktur File yang Diharapkan

Setelah konversi, letakkan file GLB di folder `assets/glb/`:

```
assets/
├── fbx/                          # File FBX asli (opsional, bisa dihapus)
│   ├── dayana blue fbx.fbx
│   ├── nayra black fbx.fbx
│   └── ...
└── glb/                          # File GLB hasil konversi
    ├── dayana_blue.glb
    ├── nayra_black.glb
    ├── sabrina_black.glb
    ├── sabrina_white.glb
    ├── valerya_pink.glb
    ├── xavia_black.glb
    ├── xavia_blue.glb
    └── xavia_purple.glb
```

## Mapping File FBX ke GLB

| File FBX Asli              | File GLB Hasil          |
|----------------------------|-------------------------|
| dayana blue fbx.fbx        | dayana_blue.glb         |
| nayra black fbx.fbx        | nayra_black.glb         |
| sabrina black fbx.fbx      | sabrina_black.glb       |
| sabrina white fbx.fbx      | sabrina_white.glb       |
| valerya pink fbx.fbx       | valerya_pink.glb        |
| xavia black fbx.fbx        | xavia_black.glb         |
| xavia blue fbx.fbx         | xavia_blue.glb          |
| xavia blue old fbx.fbx     | xavia_blue_old.glb      |
| xavia purple fbx.fbx       | xavia_purple.glb        |

## Tips Optimasi

1. **Kompres Model**
   - Gunakan gltf-pipeline untuk kompres: `npm install -g gltf-pipeline`
   - Compress: `gltf-pipeline -i input.glb -o output.glb -d`

2. **Reduce Polygon Count**
   - Di Blender, gunakan Decimate Modifier untuk mengurangi polygon
   - Target: < 50K triangles untuk performa mobile yang baik

3. **Optimize Textures**
   - Resize texture ke max 2048x2048 atau 1024x1024
   - Gunakan format compressed (JPEG untuk color, PNG untuk alpha)

## Setelah Konversi

1. Buat folder `assets/glb/` di root project
2. Copy semua file GLB ke folder tersebut
3. Run: `flutter pub get`
4. Run: `flutter run`

## Troubleshooting

### Model tidak muncul
- Pastikan path file GLB benar di `ar_camera_screen.dart`
- Cek console untuk error loading model
- Pastikan file GLB tidak corrupt (buka di Blender untuk test)

### Model terlalu besar/kecil
- Edit scale di Blender sebelum export
- Atau adjust camera distance di ModelViewer

### Model tidak ter-render dengan baik
- Pastikan material dan texture ter-export dengan benar
- Gunakan format glTF 2.0 (bukan glTF 1.0)
- Include textures saat export

## Referensi

- Blender Manual: https://docs.blender.org/manual/en/latest/
- glTF Specification: https://www.khronos.org/gltf/
- model_viewer_plus: https://pub.dev/packages/model_viewer_plus
