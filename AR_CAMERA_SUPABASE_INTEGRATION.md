# AR Camera - Integrasi Supabase untuk Image Target

## Ringkasan Perubahan

Halaman AR Camera telah dimodifikasi untuk mengambil data produk dari Supabase berdasarkan image target yang telah diupload melalui halaman Image Target.

## Fitur Utama

### 1. **Pengambilan Data dari Supabase**
- AR Camera sekarang mengambil data image target dari tabel `image_target` di Supabase
- Data yang diambil meliputi:
  - `id`: ID unik dari image target
  - `name`: Nama produk
  - `image_target`: URL gambar target
  - `model_url`: URL model 3D (opsional)
  - `description`: Deskripsi produk (opsional) ✨ **NEW**
  - `created_at`: Tanggal pembuatan

### 2. **Product Detail dari Supabase** ✨ **NEW**
- Detail produk sekarang diambil langsung dari Supabase
- Menampilkan:
  - **Nama produk** dari field `name`
  - **Deskripsi lengkap** dari field `description`
  - **Gambar produk** dari field `image_target`
  - **3D model indicator** jika `model_url` tersedia
  - **Tanggal upload** dari field `created_at`
  - **Badge sumber data** ("From Supabase" atau "Fallback Data")
- Fallback ke data hardcoded jika Supabase tidak tersedia

### 3. **Deteksi Image Target**
AR Camera menggunakan dua metode untuk mendeteksi produk:

#### a. Text Recognition (OCR)
- Membaca teks dari gambar yang ditangkap kamera
- Mencocokkan nama produk yang terdeteksi dengan data di Supabase
- Mendukung pencocokan parsial (minimal 3 karakter)

#### b. Image Labeling
- Menggunakan Google ML Kit untuk mendeteksi objek dalam gambar
- Mencocokkan label dengan kategori produk
- Mendukung deteksi:
  - Visual content (poster, picture, photo, dll)
  - Clothing items (dress, fashion, apparel, dll)
  - Person/model

### 4. **Fallback ke Data Lokal**
Jika Supabase tidak tersedia atau tidak ada data:
- Aplikasi akan menggunakan data fashion items yang sudah ada (hardcoded)
- Memastikan aplikasi tetap berfungsi meskipun offline

### 4. **Tampilan 3D Model**
- Menampilkan model 3D berdasarkan `model_url` dari Supabase
- Jika `model_url` tidak tersedia, menggunakan URL dari data fallback
- Loading indicator dengan progress bar
- Kontrol kamera 3D (rotate, zoom, pan)

### 5. **List Produk**
- Menampilkan semua image target dari Supabase di bagian bawah layar
- Mendukung gambar dari URL (network) dan asset lokal
- Highlight produk yang sedang dipilih
- Tap untuk memilih dan menampilkan model 3D

## Struktur Data

### ImageTarget Model
```dart
class ImageTarget {
  final int? id;
  final String name;
  final String imageTarget;
  final String? modelUrl;
  final DateTime? createdAt;
}
```

### Tabel Supabase: `image_target`
```sql
CREATE TABLE image_target (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  image_target TEXT NOT NULL,
  model_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Cara Kerja

### 1. Inisialisasi
```dart
@override
void initState() {
  super.initState();
  _loadImageTargetsFromSupabase();  // Load data dari Supabase
  _initializeCamera();               // Inisialisasi kamera
}
```

### 2. Load Data dari Supabase
```dart
Future<void> _loadImageTargetsFromSupabase() async {
  try {
    if (!SupabaseConfig.isInitialized) {
      // Gunakan fallback data
      return;
    }
    
    final targets = await _imageTargetService.getImageTargets();
    setState(() {
      _imageTargets = targets;
    });
  } catch (e) {
    debugPrint('Error loading image targets: $e');
  }
}
```

### 3. Deteksi dan Matching
```dart
// Text recognition
final recognizedText = await _textRecognizer.processImage(inputImage);
String? matchedFromText = _findMatchingItemFromText(recognizedText.text);

// Image labeling
final labels = await _imageLabeler.processImage(inputImage);
String? matchedFromLabel = _findMatchingItem(labels.first.label);
```

### 4. Tampilkan Model 3D
```dart
ModelViewer(
  src: _getModelUrl(_selectedItemId),  // Ambil URL dari Supabase atau fallback
  ar: true,
  cameraControls: true,
  // ... konfigurasi lainnya
)
```

## Helper Functions

### `_getModelUrl(String? itemId)`
Mengambil URL model 3D:
1. Cari di data Supabase (`_imageTargets`)
2. Jika tidak ada, gunakan data fallback (`_fashionItems`)

### `_getAllItems()`
Menggabungkan data dari Supabase dan fallback:
1. Prioritas: data dari Supabase
2. Jika kosong: gunakan data fallback

### `_findMatchingItemFromText(String text)`
Mencocokkan teks yang terdeteksi dengan nama produk di Supabase:
- Case insensitive
- Mendukung partial matching
- Minimal 3 karakter untuk matching

### `_findMatchingItem(String label)`
Mencocokkan label ML Kit dengan produk:
- Deteksi visual content
- Deteksi clothing items
- Deteksi person/model

## Penggunaan

### 1. Upload Image Target
- Buka halaman "Image Target"
- Klik tombol "Upload"
- Masukkan nama produk
- Pilih gambar target
- (Opsional) Tambahkan URL model 3D di database

### 2. Scan dengan AR Camera
- Buka halaman "AR Camera"
- Arahkan kamera ke image target yang sudah diupload
- Aplikasi akan mendeteksi dan menampilkan model 3D
- Atau pilih produk dari list di bagian bawah

### 3. Interaksi dengan Model 3D
- **Rotate**: Drag untuk memutar model
- **Zoom**: Pinch untuk zoom in/out
- **Info**: Tap tombol info untuk melihat detail produk
- **Close**: Tap tombol X untuk menutup model
- **Scan Again**: Tap tombol refresh untuk scan ulang

## Troubleshooting

### Model 3D tidak muncul
1. Pastikan `model_url` di database valid
2. Cek koneksi internet
3. Verifikasi URL model dapat diakses

### Image target tidak terdeteksi
1. Pastikan pencahayaan cukup
2. Gambar target harus jelas dan tidak blur
3. Coba scan dari jarak yang berbeda

### Data tidak muncul dari Supabase
1. Cek koneksi internet
2. Verifikasi Supabase credentials di `supabase_config.dart`
3. Pastikan tabel `image_target` ada dan berisi data

## Catatan Penting

1. **Performance**: 
   - Image recognition berjalan setiap 1 detik
   - Pause saat model sedang loading atau ditampilkan

2. **Fallback Data**:
   - Selalu tersedia untuk memastikan aplikasi berfungsi
   - Digunakan jika Supabase tidak tersedia

3. **Model URL**:
   - Harus berupa URL publik yang dapat diakses
   - Format: GLB (recommended) atau GLTF
   - Ukuran file sebaiknya < 10MB untuk performa optimal

4. **Image Target**:
   - Gunakan gambar dengan kontras tinggi
   - Hindari gambar yang terlalu gelap atau terang
   - Ukuran minimal 512x512 pixels

## Future Improvements

1. **Caching**: Cache model 3D untuk akses offline
2. **Search**: Tambah fitur search produk
3. **Filter**: Filter berdasarkan kategori
4. **Analytics**: Track produk yang paling sering dilihat
5. **AR Placement**: Tambah fitur untuk menempatkan model di ruang nyata
