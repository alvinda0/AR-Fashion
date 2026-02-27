# Optimasi Performa Model 3D GLB

## Masalah
File GLB terlalu besar (43MB+) menyebabkan:
- Loading lambat
- Aplikasi lemot saat menampilkan model
- Konsumsi memory tinggi

## Ukuran File Saat Ini
```
dayana_blue.glb: 43.6 MB
nayra_black.glb: 43.2 MB
```

## Solusi: Compress GLB Files

### Opsi 1: Online Tools (Paling Mudah)

1. **glTF-Transform** (Recommended)
   - Website: https://gltf.report/
   - Upload file GLB
   - Pilih optimizations:
     - ✓ Draco compression
     - ✓ Texture compression
     - ✓ Remove unused data
   - Download hasil compress
   - Target: < 5MB per file

2. **gltf.report**
   - Upload GLB file
   - Automatic optimization
   - Download optimized version

### Opsi 2: Command Line Tools

**Install gltf-pipeline:**
```bash
npm install -g gltf-pipeline
```

**Compress GLB:**
```bash
gltf-pipeline -i input.glb -o output.glb -d
```

**Dengan Draco compression:**
```bash
gltf-pipeline -i input.glb -o output.glb --draco.compressionLevel 10
```

### Opsi 3: Blender (Manual)

1. Open GLB in Blender
2. Reduce polygon count:
   - Select model → Modifiers → Decimate
   - Ratio: 0.5 (reduce 50%)
3. Optimize textures:
   - Reduce texture resolution (2K → 1K)
   - Use JPEG instead of PNG for color maps
4. Export as GLB with compression

## Optimasi Tambahan di Code

Sudah diterapkan:
- ✓ Pause camera saat model muncul
- ✓ Stop image recognition saat model aktif
- ✓ Disable auto-rotate
- ✓ Disable shadows
- ✓ Eager loading

## Target Performa

- File size: < 5MB per model
- Loading time: < 2 detik
- Smooth rotation dan zoom

## Langkah Selanjutnya

1. Compress semua file GLB di `assets/glb/`
2. Replace file lama dengan yang sudah di-compress
3. Test performa di device
4. Adjust compression level jika perlu

## Tips

- Jangan compress terlalu agresif (kualitas visual turun)
- Test di device real, bukan emulator
- Gunakan Draco compression untuk hasil terbaik
- Backup file original sebelum compress
