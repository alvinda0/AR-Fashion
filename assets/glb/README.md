# GLB Models Folder

Letakkan file GLB hasil konversi dari FBX di folder ini.

## File yang Dibutuhkan:

- [ ] dayana_blue.glb
- [ ] nayra_black.glb
- [ ] sabrina_black.glb
- [ ] sabrina_white.glb
- [ ] valerya_pink.glb
- [ ] xavia_black.glb
- [ ] xavia_blue.glb
- [ ] xavia_purple.glb

## Cara Konversi:

Lihat panduan lengkap di: `CONVERT_FBX_TO_GLB.md` di root project.

### Quick Start dengan Blender:

1. Buka Blender
2. File → Import → FBX → Pilih file dari `assets/fbx/`
3. File → Export → glTF 2.0 (.glb)
4. Pilih format: **glTF Binary (.glb)**
5. Simpan di folder ini dengan nama yang sesuai

## Catatan:

- Format GLB adalah format binary dari glTF yang lebih efisien
- Pastikan nama file sesuai dengan yang ada di `ar_camera_screen.dart`
- Ukuran file sebaiknya < 5MB per model untuk performa optimal
