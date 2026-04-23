# Panduan Field Deskripsi Image Target

## 📋 Overview

Field `description` telah ditambahkan ke tabel `image_targets` untuk memberikan informasi tambahan tentang setiap image target.

## 🗄️ Database Schema

### Tabel: `image_targets`

```sql
CREATE TABLE image_targets (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  image_target TEXT NOT NULL,
  model_url TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Field Baru

- **description** (TEXT, nullable)
  - Deskripsi opsional untuk image target
  - Dapat berisi informasi detail tentang produk/objek
  - Contoh: "Sepatu olahraga warna hitam dengan sol putih"

## 🎨 UI Implementation

### 1. Upload Dialog

Field deskripsi ditambahkan di dialog upload dengan:
- Label: "Deskripsi (Opsional)"
- Placeholder: "Contoh: Sepatu olahraga warna hitam"
- Multi-line input (3 baris)
- Icon: `Icons.description`

```dart
TextField(
  controller: _descriptionController,
  decoration: InputDecoration(
    labelText: 'Deskripsi (Opsional)',
    hintText: 'Contoh: Sepatu olahraga warna hitam',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    prefixIcon: const Icon(Icons.description),
  ),
  maxLines: 3,
  textCapitalization: TextCapitalization.sentences,
)
```

### 2. Image Target Card

Deskripsi ditampilkan di card list dengan:
- Font size: 10-11 (responsive)
- Color: `Colors.grey[600]`
- Max lines: 2
- Overflow: ellipsis

### 3. Image Preview Dialog

Deskripsi ditampilkan di preview dengan:
- Label "Deskripsi:" (bold)
- Text deskripsi lengkap
- Muncul setelah ID dan sebelum tanggal upload

## 📝 Cara Penggunaan

### Upload Image Target dengan Deskripsi

1. Klik tombol **"Upload"** di header
2. Isi **Nama Image Target** (wajib)
3. Isi **Deskripsi** (opsional)
4. Pilih **Model 3D** (opsional)
5. Klik **"Pilih Gambar"**
6. Pilih file gambar
7. Upload selesai

### Contoh Deskripsi yang Baik

✅ **Good Examples:**
- "Sepatu olahraga Nike Air Max warna hitam dengan sol putih"
- "Tas kulit coklat dengan tali panjang dan resleting emas"
- "Jam tangan digital dengan layar LED dan tali silikon"

❌ **Bad Examples:**
- "Bagus" (terlalu singkat)
- "..." (tidak informatif)
- Deskripsi yang terlalu panjang (lebih dari 200 karakter)

## 🔄 Data Flow

```
User Input (Dialog)
    ↓
_descriptionController.text
    ↓
_pickAndUploadImage(name, modelUrl, description)
    ↓
ImageTarget(
  name: name,
  imageTarget: imageUrl,
  modelUrl: modelUrl,
  description: description,  ← Field baru
  createdAt: DateTime.now(),
)
    ↓
saveImageTarget() → Supabase
```

## 🎯 Features

### ✅ Implemented

- [x] Field `description` di model `ImageTarget`
- [x] Input field deskripsi di upload dialog
- [x] Tampilan deskripsi di card list
- [x] Tampilan deskripsi di preview dialog
- [x] Validasi opsional (boleh kosong)
- [x] Multi-line input (3 baris)
- [x] Text capitalization otomatis

### 📊 Display Logic

```dart
// Di Card List
if (target.description != null && target.description!.isNotEmpty) {
  Text(
    target.description!,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  )
}

// Di Preview Dialog
if (target.description != null && target.description!.isNotEmpty) {
  Column(
    children: [
      Text('Deskripsi:', style: bold),
      Text(target.description!),
    ],
  )
}
```

## 🔧 Technical Details

### Model Class

```dart
class ImageTarget {
  final int? id;
  final String name;
  final String imageTarget;
  final String? modelUrl;
  final String? description;  // ← Field baru
  final DateTime? createdAt;

  ImageTarget({
    this.id,
    required this.name,
    required this.imageTarget,
    this.modelUrl,
    this.description,  // ← Opsional
    this.createdAt,
  });
}
```

### JSON Serialization

```dart
Map<String, dynamic> toJson() {
  return {
    if (id != null) 'id': id,
    'name': name,
    'image_target': imageTarget,
    if (modelUrl != null) 'model_url': modelUrl,
    if (description != null) 'description': description,  // ← Conditional
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

factory ImageTarget.fromJson(Map<String, dynamic> json) {
  return ImageTarget(
    id: json['id'],
    name: json['name'],
    imageTarget: json['image_target'],
    modelUrl: json['model_url'],
    description: json['description'],  // ← Nullable
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
  );
}
```

## 📱 Responsive Design

### Tablet (width > 600)
- Font size deskripsi: 11
- Padding: 12
- Spacing: 4

### Mobile (width ≤ 600)
- Font size deskripsi: 10
- Padding: 8
- Spacing: 2

## 🎨 Styling

```dart
// Card List Description
Text(
  target.description!,
  style: TextStyle(
    fontSize: isTablet ? 11 : 10,
    color: Colors.grey[600],
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)

// Preview Dialog Description
Text(
  target.description!,
  style: const TextStyle(
    fontSize: 12,
    color: Colors.grey,
  ),
)
```

## 🚀 Benefits

1. **Informasi Lebih Lengkap**: User dapat menambahkan detail produk
2. **Pencarian Lebih Mudah**: Deskripsi membantu identifikasi image target
3. **User Experience**: UI lebih informatif dan profesional
4. **Fleksibilitas**: Field opsional, tidak wajib diisi

## 📝 Notes

- Field deskripsi bersifat **opsional**
- Tidak ada validasi panjang maksimum di UI (handled by database)
- Deskripsi ditampilkan dengan ellipsis jika terlalu panjang di card
- Deskripsi lengkap ditampilkan di preview dialog
- Controller di-clear setelah upload berhasil

## 🔗 Related Files

- `lib/screens/image_target_screen.dart` - UI implementation
- `lib/services/image_target_service.dart` - Model & service
- `lib/config/supabase_config.dart` - Database config

---

**Last Updated**: 2026-04-23
**Version**: 1.0.0
