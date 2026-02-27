# Panduan Penggunaan 3D Model di AR Camera

## Overview

Aplikasi Fashion AR sekarang mendukung tampilan 3D model ketika user mengklik item fashion di AR Camera screen. Model 3D ditampilkan menggunakan `model_viewer_plus` yang mendukung:

- ✅ Rotasi 3D interaktif (drag untuk rotate)
- ✅ Zoom in/out (pinch gesture)
- ✅ Auto-rotate mode
- ✅ AR mode (view in your space)
- ✅ Cross-platform (Android & iOS)

## Cara Kerja

1. User membuka AR Camera screen
2. Camera preview ditampilkan dengan overlay item fashion di bagian bawah
3. User mengklik salah satu item fashion
4. Model 3D muncul di tengah layar dengan background semi-transparent
5. User bisa:
   - Rotate model dengan drag
   - Zoom dengan pinch
   - Close dengan tombol X di kanan atas
   - View in AR mode (jika device support)

## Struktur Kode

### File yang Dimodifikasi

1. **lib/screens/ar_camera_screen.dart**
   - Menambahkan import `model_viewer_plus`
   - Menambahkan field `model` di setiap fashion item
   - Menambahkan overlay untuk menampilkan 3D model
   - Menambahkan tombol close untuk menutup 3D viewer

2. **pubspec.yaml**
   - Menambahkan `assets/fbx/` dan `assets/glb/` ke assets

### Komponen UI

```
Stack
├── CameraPreview (Full screen)
├── 3D Model Overlay (when item selected)
│   └── ModelViewer widget
├── Back Button (top left)
├── Close Button (top right, when model shown)
└── Fashion Items List (bottom)
```

## Format File 3D

### Supported Format: GLB (GL Transmission Format Binary)

- ✅ GLB: Binary format, single file, includes textures
- ❌ FBX: Not supported by Flutter/model_viewer_plus
- ❌ OBJ: Supported but requires separate texture files

### Konversi FBX ke GLB

Lihat panduan lengkap di: `CONVERT_FBX_TO_GLB.md`

Quick command dengan Blender:
```bash
# Install Blender first, then use Python script
blender --background --python convert_fbx_to_glb.py
```

## Konfigurasi Model Viewer

### Current Settings

```dart
ModelViewer(
  src: 'assets/glb/model_name.glb',
  alt: 'Fashion 3D Model',
  ar: true,                    // Enable AR mode
  autoRotate: true,            // Auto rotate model
  cameraControls: true,        // Enable user interaction
  backgroundColor: Color(0xFFEEEEEE),
)
```

### Customization Options

Anda bisa customize ModelViewer dengan parameter:

```dart
ModelViewer(
  src: 'path/to/model.glb',
  
  // AR Settings
  ar: true,                           // Enable AR button
  arModes: ['scene-viewer', 'webxr'], // AR modes
  arScale: 'auto',                    // Scale in AR
  
  // Camera Settings
  cameraControls: true,               // Enable drag/zoom
  autoRotate: true,                   // Auto rotation
  autoRotateDelay: 3000,              // Delay before auto-rotate (ms)
  rotationPerSecond: '30deg',         // Rotation speed
  
  // Camera Position
  cameraOrbit: '0deg 75deg 105%',     // Initial camera position
  minCameraOrbit: 'auto auto 105%',   // Min zoom
  maxCameraOrbit: 'auto auto 500%',   // Max zoom
  
  // Lighting
  environmentImage: 'neutral',        // Lighting environment
  exposure: 1.0,                      // Exposure level
  shadowIntensity: 0.5,               // Shadow strength
  shadowSoftness: 1.0,                // Shadow softness
  
  // Interaction
  interactionPrompt: 'auto',          // Show interaction hint
  interactionPromptThreshold: 3000,   // Show hint after 3s
  
  // Loading
  loading: 'eager',                   // Load immediately
  reveal: 'auto',                     // Show when loaded
  
  // Background
  backgroundColor: Color(0xFFEEEEEE),
  
  // Alt text for accessibility
  alt: 'Fashion 3D Model',
)
```

## Optimasi Performa

### 1. Ukuran File Model

Target ukuran file GLB:
- ✅ Optimal: < 2MB per model
- ⚠️ Acceptable: 2-5MB per model
- ❌ Too large: > 5MB per model

### 2. Polygon Count

Target polygon count:
- ✅ Mobile optimal: < 50K triangles
- ⚠️ Acceptable: 50K-100K triangles
- ❌ Too high: > 100K triangles

### 3. Texture Resolution

Target texture size:
- ✅ Optimal: 1024x1024 atau 512x512
- ⚠️ Acceptable: 2048x2048
- ❌ Too large: > 2048x2048

### 4. Compression

Gunakan gltf-pipeline untuk compress:

```bash
npm install -g gltf-pipeline
gltf-pipeline -i input.glb -o output.glb -d
```

## Testing

### Test di Emulator

```bash
flutter run
```

Note: AR mode tidak akan berfungsi di emulator, tapi 3D viewer tetap bisa ditest.

### Test di Device

```bash
flutter run -d <device-id>
```

Untuk AR mode, pastikan device support ARCore (Android) atau ARKit (iOS).

## Troubleshooting

### Model tidak muncul

1. **Cek path file**
   ```dart
   // Pastikan path benar
   'model': 'assets/glb/dayana_blue.glb',
   ```

2. **Cek pubspec.yaml**
   ```yaml
   assets:
     - assets/glb/
   ```

3. **Run flutter pub get**
   ```bash
   flutter pub get
   ```

4. **Cek console untuk error**
   ```bash
   flutter run --verbose
   ```

### Model terlalu besar/kecil

Adjust camera orbit:
```dart
ModelViewer(
  cameraOrbit: '0deg 75deg 200%', // Increase percentage to zoom out
)
```

### Model tidak ter-render dengan baik

1. **Cek format file**
   - Pastikan format GLB 2.0 (bukan 1.0)
   - Export ulang dari Blender dengan settings yang benar

2. **Cek material**
   - Pastikan material compatible dengan glTF
   - Gunakan Principled BSDF di Blender

3. **Cek texture**
   - Pastikan texture ter-embed di GLB
   - Atau gunakan separate texture files

### Performance issues

1. **Reduce polygon count**
   - Gunakan Decimate modifier di Blender
   - Target < 50K triangles

2. **Compress textures**
   - Resize ke 1024x1024 atau lebih kecil
   - Gunakan JPEG untuk color maps

3. **Optimize GLB**
   - Gunakan gltf-pipeline untuk compress
   - Remove unused data

## Next Steps

### Fitur yang Bisa Ditambahkan

1. **Loading Indicator**
   ```dart
   ModelViewer(
     loading: 'eager',
     onLoad: () {
       // Hide loading indicator
     },
   )
   ```

2. **Error Handling**
   ```dart
   ModelViewer(
     onError: (error) {
       // Show error message
     },
   )
   ```

3. **Multiple Views**
   - Front view
   - Side view
   - Back view

4. **Animation Support**
   - Play/pause animations
   - Animation speed control

5. **Screenshot/Share**
   - Capture current view
   - Share to social media

## Referensi

- model_viewer_plus: https://pub.dev/packages/model_viewer_plus
- glTF Specification: https://www.khronos.org/gltf/
- Blender glTF Export: https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html
- ARCore (Android): https://developers.google.com/ar
- ARKit (iOS): https://developer.apple.com/augmented-reality/
