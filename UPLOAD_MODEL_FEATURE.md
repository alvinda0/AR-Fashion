# Fitur Upload Model 3D - AR Fashion

## 📋 Overview

Fitur upload model memungkinkan pengguna untuk menambahkan model 3D custom mereka sendiri ke dalam aplikasi AR Fashion. Pengguna dapat mengupload file GLB/GLTF, mengelola koleksi model, dan menggunakannya dalam aplikasi.

## ✨ Fitur yang Ditambahkan

### 1. **Upload Model Screen** (`lib/screens/upload_model_screen.dart`)
- Interface untuk upload model 3D
- Daftar model yang sudah diupload
- Fitur hapus dan lihat detail model
- Responsive design untuk tablet dan landscape

### 2. **Custom Model Service** (`lib/services/custom_model_service.dart`)
- Service untuk mengelola model custom
- Menyimpan metadata model menggunakan SharedPreferences
- Copy file ke app directory
- CRUD operations untuk model

### 3. **Menu di Home Screen**
- Tombol "Upload Model" ditambahkan di halaman utama
- Icon cloud_upload untuk identifikasi mudah
- Navigasi langsung ke upload screen

## 🎯 Cara Menggunakan

### Untuk Pengguna

1. **Buka Aplikasi**
   - Launch aplikasi AR Fashion
   - Pilih menu "Upload Model" dari home screen

2. **Upload Model**
   - Klik tombol "Pilih File"
   - Pilih file GLB atau GLTF dari perangkat
   - Masukkan nama untuk model
   - Klik "Simpan"

3. **Kelola Model**
   - Lihat semua model yang diupload
   - Klik icon info untuk detail
   - Klik icon hapus untuk menghapus model

### Untuk Developer

```dart
// Import service
import 'package:ar/services/custom_model_service.dart';

// Get all models
final service = CustomModelService();
List<CustomModel> models = await service.getCustomModels();

// Upload new model
final model = CustomModel(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'My Model',
  filePath: '/path/to/model.glb',
  uploadedAt: DateTime.now(),
);
await service.saveCustomModel(model);

// Delete model
await service.deleteCustomModel(modelId);
```

## 📦 Dependencies Baru

Ditambahkan ke `pubspec.yaml`:

```yaml
dependencies:
  # File picker for uploading models
  file_picker: ^8.1.6
  
  # Shared preferences for storing model paths
  shared_preferences: ^2.3.4
```

## 🏗️ Struktur File

```
lib/
├── screens/
│   └── upload_model_screen.dart    # UI untuk upload model
├── services/
│   └── custom_model_service.dart   # Service untuk manage model
└── main.dart                        # Updated dengan menu baru

docs/
├── UPLOAD_MODEL_GUIDE.md           # Panduan lengkap
└── UPLOAD_MODEL_FEATURE.md         # Dokumentasi fitur (file ini)
```

## 💾 Data Storage

### Lokasi File
Model disimpan di:
```
/data/user/0/com.example.ar/app_flutter/custom_models/
```

### Metadata
Disimpan di SharedPreferences dengan key `custom_models`:
```json
[
  {
    "id": "1713862200000",
    "name": "Red Dress",
    "filePath": "/data/.../custom_models/1713862200000_model.glb",
    "imagePath": null,
    "uploadedAt": "2026-04-23T10:30:00.000Z"
  }
]
```

## 🎨 UI/UX Features

### Responsive Design
- ✅ Support untuk tablet (width > 600px)
- ✅ Support untuk landscape mode
- ✅ Adaptive padding dan font sizes

### User Feedback
- ✅ Loading indicator saat upload
- ✅ Success/error messages dengan SnackBar
- ✅ Confirmation dialog untuk delete
- ✅ Empty state dengan icon dan text

### Visual Design
- Gradient background (teal theme)
- Card-based layout untuk model list
- Icon-based actions (info, delete)
- Consistent dengan design aplikasi

## 🔧 Technical Details

### File Picker Configuration
```dart
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['glb', 'gltf'],
);
```

### File Management
- File di-copy ke app directory untuk persistence
- Unique filename menggunakan timestamp
- Automatic cleanup saat delete

### Error Handling
- Try-catch untuk semua async operations
- User-friendly error messages
- Graceful fallback untuk missing files

## 🚀 Future Enhancements

### Planned Features
1. **Preview Model**
   - 3D preview sebelum upload
   - Rotate dan zoom model

2. **Thumbnail Generation**
   - Auto-generate thumbnail dari model
   - Custom thumbnail upload

3. **Model Categories**
   - Kategorisasi model (dress, shoes, accessories)
   - Filter berdasarkan kategori

4. **Cloud Storage**
   - Sync model ke cloud
   - Share model antar pengguna

5. **Model Editor**
   - Edit nama dan metadata
   - Adjust scale dan rotation

6. **Batch Upload**
   - Upload multiple models sekaligus
   - Progress indicator untuk batch

## 📱 Platform Support

### Android
- ✅ Fully supported
- File picker menggunakan native Android picker
- Storage di app-specific directory

### iOS
- ✅ Should work (not tested)
- Requires permission untuk photo library
- Storage di app documents directory

### Web
- ⚠️ Limited support
- File picker works
- Storage menggunakan IndexedDB

## 🐛 Known Issues

1. **Large Files**
   - File >100MB mungkin lambat saat upload
   - Solusi: Compress model sebelum upload

2. **Memory Usage**
   - Multiple large models bisa consume memory
   - Solusi: Implement pagination atau lazy loading

3. **File Validation**
   - Belum ada validasi struktur GLB/GLTF
   - Solusi: Add file validation sebelum save

## 📝 Testing Checklist

- [x] Upload GLB file
- [x] Upload GLTF file
- [x] View model list
- [x] Delete model
- [x] View model info
- [x] Empty state display
- [x] Loading state display
- [x] Error handling
- [x] Responsive layout (tablet)
- [x] Responsive layout (landscape)
- [ ] Preview model (future)
- [ ] Edit model name (future)

## 🔗 Related Files

- `lib/screens/upload_model_screen.dart` - Main UI
- `lib/services/custom_model_service.dart` - Business logic
- `lib/main.dart` - Navigation setup
- `pubspec.yaml` - Dependencies
- `UPLOAD_MODEL_GUIDE.md` - User guide

## 👨‍💻 Developer Notes

### Adding New Features

1. **Add Preview**
```dart
// In upload_model_screen.dart
void _previewModel(CustomModel model) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ModelViewerScreen(
        modelPath: model.filePath,
      ),
    ),
  );
}
```

2. **Add Categories**
```dart
// In custom_model_service.dart
class CustomModel {
  final String category; // Add this field
  // ... other fields
}
```

3. **Add Search**
```dart
// In upload_model_screen.dart
List<CustomModel> _filteredModels = [];

void _searchModels(String query) {
  setState(() {
    _filteredModels = _customModels
        .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  });
}
```

## 📞 Support

Untuk pertanyaan atau issue:
- Developer: Alvinda Shahrul
- NIM: 191011450055
- Email: [your-email]

## 📄 License

Part of AR Fashion App - Tugas Akhir Project

---

**Version**: 1.0.0  
**Created**: April 23, 2026  
**Last Updated**: April 23, 2026  
**Status**: ✅ Production Ready
