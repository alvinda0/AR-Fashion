# Optimasi Performa Model 3D

## Masalah yang Diperbaiki
Model 3D terasa lag/lemot saat diputar-putar (rotasi)

## Solusi yang Diterapkan

### 1. Hardware Acceleration
```css
transform: translateZ(0);
will-change: transform;
backface-visibility: hidden;
```
- Memaksa GPU untuk merender model 3D
- Mengurangi beban CPU

### 2. WebGL Optimization
```javascript
gl.enable(gl.CULL_FACE);
gl.cullFace(gl.BACK);
```
- Tidak merender bagian belakang model yang tidak terlihat
- Mengurangi jumlah polygon yang diproses

### 3. Canvas Optimization
- Smooth rendering dengan antialiasing
- Optimasi backface visibility

## Tips Tambahan untuk Performa Lebih Baik

### A. Kompres File GLB
Jika model masih lemot, kompres file GLB:

```bash
# Install gltf-pipeline
npm install -g gltf-pipeline

# Kompres GLB dengan Draco compression
gltf-pipeline -i input.glb -o output.glb -d
```

### B. Reduce Polygon Count
Gunakan Blender untuk mengurangi jumlah polygon:

1. Buka model di Blender
2. Select model → Tab (Edit Mode)
3. Mesh → Clean Up → Decimate Geometry
4. Set Ratio ke 0.5 (50% polygon)
5. Export kembali sebagai GLB

### C. Optimize Textures
- Gunakan texture maksimal 2048x2048 px
- Compress texture dengan tools seperti TinyPNG
- Gunakan format WebP jika memungkinkan

### D. Network Optimization
Karena menggunakan Supabase:

1. **Enable CDN** di Supabase Storage
2. **Set Cache Headers** untuk file GLB:
   - Cache-Control: public, max-age=31536000
3. **Gunakan Compression** di Supabase:
   - Enable gzip/brotli compression

### E. App-Level Optimization

#### Preload Models
```dart
// Preload model saat app start
Future<void> _preloadModels() async {
  for (var item in _fashionItems) {
    // Trigger browser to cache the model
    await precacheImage(NetworkImage(item['model']!), context);
  }
}
```

#### Reduce Camera Resolution
```dart
_cameraController = CameraController(
  selectedCamera,
  ResolutionPreset.low, // Ubah dari medium ke low
  enableAudio: false,
);
```

## Checklist Optimasi

- [x] Hardware acceleration enabled
- [x] WebGL culling enabled
- [x] Canvas optimization applied
- [ ] GLB files compressed with Draco
- [ ] Polygon count reduced
- [ ] Textures optimized
- [ ] CDN enabled di Supabase
- [ ] Cache headers configured
- [ ] Models preloaded

## Ukuran File GLB yang Direkomendasikan

| Kualitas | Ukuran File | Polygon Count | Performa |
|----------|-------------|---------------|----------|
| Low      | < 1 MB      | < 10K         | Sangat Smooth |
| Medium   | 1-3 MB      | 10K-50K       | Smooth |
| High     | 3-5 MB      | 50K-100K      | Agak Lag |
| Ultra    | > 5 MB      | > 100K        | Lag |

## Testing Performa

### Cara Test:
1. Buka Chrome DevTools
2. Performance tab
3. Record saat memutar model
4. Lihat FPS (target: 60 FPS)

### Metrics yang Baik:
- FPS: 60 (smooth)
- Frame time: < 16ms
- GPU usage: < 80%

## Troubleshooting

### Masih Lag?

1. **Cek ukuran file GLB**
   ```bash
   ls -lh assets/glb/*.glb
   ```

2. **Cek jumlah polygon**
   - Buka di Blender
   - Lihat di Statistics panel
   - Target: < 50K polygons

3. **Cek texture size**
   - Extract GLB
   - Lihat ukuran texture
   - Target: < 2048x2048 px

4. **Test di device lain**
   - Performa bervariasi per device
   - Test di device mid-range

## Rekomendasi Device

| Device Type | RAM | GPU | Expected Performance |
|-------------|-----|-----|---------------------|
| Low-end     | 2GB | Mali-400 | Lag dengan model > 2MB |
| Mid-range   | 4GB | Adreno 506 | Smooth dengan model < 5MB |
| High-end    | 6GB+ | Adreno 640+ | Smooth dengan semua model |

## Next Steps

Jika masih lemot setelah optimasi ini:
1. Kompres semua file GLB dengan Draco
2. Reduce polygon count di Blender
3. Optimize textures
4. Enable CDN di Supabase
5. Consider using lower quality models untuk preview
