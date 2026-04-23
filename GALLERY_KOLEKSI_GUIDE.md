# Gallery Koleksi - Panduan Penggunaan

Gallery Koleksi menampilkan semua item yang ada di tabel `image_target` dari Supabase. Fitur ini menggunakan data yang sama dengan fitur Image Target, sehingga tidak perlu setup tabel baru.

## Fitur

- ✅ Menampilkan semua image target dalam bentuk grid gallery
- ✅ Menampilkan detail item dengan modal bottom sheet
- ✅ Menampilkan badge 3D Model jika item memiliki model 3D
- ✅ Menampilkan deskripsi lengkap item
- ✅ Refresh data dari Supabase
- ✅ Loading state dan error handling
- ✅ Responsive design (tablet & mobile)

## Struktur Data

Gallery Koleksi menggunakan tabel `image_target` yang sudah ada dengan struktur:

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key (auto increment) |
| name | TEXT | Nama item/produk |
| image_target | TEXT | URL gambar dari Supabase Storage |
| model_url | TEXT | URL model 3D (opsional) |
| description | TEXT | Deskripsi item (opsional) |
| created_at | TIMESTAMPTZ | Timestamp pembuatan |

## Cara Menggunakan

### 1. Menambah Item ke Gallery

Ada 2 cara untuk menambah item ke Gallery Koleksi:

#### Cara 1: Via Image Target Screen (Recommended)

1. Buka menu **Image Target** dari home screen
2. Klik tombol **Upload** di kanan atas
3. Isi form:
   - **Nama Image Target**: Nama produk/item
   - **Deskripsi**: Deskripsi lengkap produk (opsional)
   - **Pilih Model 3D**: Pilih model 3D jika ada (opsional)
4. Klik **Pilih Gambar**
5. Pilih gambar dari galeri
6. Item akan otomatis muncul di Gallery Koleksi

#### Cara 2: Via Supabase Dashboard

1. Buka Supabase Dashboard
2. Upload gambar ke bucket `image_target`
3. Insert data ke tabel `image_target`:

```sql
INSERT INTO image_target (name, image_target, description, model_url) 
VALUES (
  'Nama Produk',
  'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/image_target/image_targets/nama_file.jpg',
  'Deskripsi lengkap produk...',
  'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/ar-fashion-glb/model.glb'
);
```

### 2. Melihat Gallery Koleksi

1. Buka aplikasi
2. Dari home screen, tap **Gallery Koleksi**
3. Semua item akan ditampilkan dalam grid
4. Tap item untuk melihat detail lengkap

### 3. Melihat Detail Item

1. Tap salah satu item di gallery
2. Modal bottom sheet akan muncul dengan:
   - Gambar besar
   - Nama item
   - Tanggal ditambahkan
   - Deskripsi lengkap (jika ada)
   - Badge "3D Model" jika item memiliki model 3D
3. Swipe down atau tap tombol close untuk menutup

## Integrasi dengan Fitur Lain

### Image Target Screen

Gallery Koleksi dan Image Target Screen menggunakan data yang sama:
- Item yang diupload di Image Target akan muncul di Gallery
- Item yang dihapus di Image Target akan hilang dari Gallery
- Sinkronisasi otomatis karena menggunakan tabel yang sama

### AR Camera

Item yang memiliki `model_url` bisa digunakan untuk AR:
- Badge 3D Model menandakan item memiliki model 3D
- Model 3D bisa digunakan di AR Camera Screen
- Image target bisa digunakan untuk trigger AR

## Troubleshooting

### Gallery kosong padahal sudah upload

**Solusi:**
1. Pastikan internet connection aktif
2. Tap tombol refresh (icon refresh di kanan atas)
3. Cek apakah data ada di Supabase Dashboard
4. Restart aplikasi

### Error: "Could not find the table 'public.image_target'"

**Solusi:**
1. Pastikan tabel `image_target` sudah dibuat di Supabase
2. Cek nama tabel harus exact: `image_target` (bukan `image_targets`)
3. Lihat dokumentasi setup di `AR_CAMERA_SUPABASE_INTEGRATION.md`

### Gambar tidak muncul

**Solusi:**
1. Pastikan bucket `image_target` bersifat public
2. Cek URL gambar valid di browser
3. Pastikan file sudah terupload ke storage
4. Cek format gambar (jpg, png, webp)

### Error loading koleksi

**Solusi:**
1. Cek koneksi internet
2. Pastikan Supabase credentials benar di `supabase_config.dart`
3. Cek RLS policies di Supabase (harus allow public read)
4. Lihat error message detail untuk troubleshooting

## Tips & Best Practices

### 1. Optimasi Gambar

- Compress gambar sebelum upload (max 500KB)
- Gunakan format WebP untuk ukuran lebih kecil
- Resolusi recommended: 1024x1024 atau 800x800

### 2. Deskripsi yang Baik

- Tulis deskripsi yang informatif dan lengkap
- Sertakan detail produk (bahan, ukuran, warna, harga)
- Format dengan line breaks untuk readability
- Gunakan emoji untuk highlight poin penting

### 3. Naming Convention

- Gunakan nama yang descriptive
- Hindari nama terlalu panjang (max 50 karakter)
- Gunakan title case (contoh: "Dayana Dress Blue")

### 4. Model 3D

- Upload model 3D untuk pengalaman AR yang lebih baik
- Pastikan model sudah dioptimasi (max 10MB)
- Test model di AR Camera sebelum publish

### 5. Kategori

- Gunakan deskripsi untuk mengelompokkan item
- Contoh: "Kategori: Dress" di awal deskripsi
- Bisa digunakan untuk filter di masa depan

## Contoh Data

### Item dengan Model 3D

```sql
INSERT INTO image_target (name, image_target, description, model_url) 
VALUES (
  'Xavia Black Dress',
  'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/image_target/image_targets/xavia_black.jpg',
  'Berbahan rayon premium yang sangat nyaman, adem. Modelnya simple namun looknya super mewah!

✔️ Detail lengan semi puffy dengan kopel karet (Wudhu friendly)
✔️ Detail kerah shanghai dengan zipper bagian depan (Busui friendly)
✔️ Cutting A-line super lebar

Size Chart:
S: LD 92 // PB 135
M: LD 96 // PB 138
L: LD 100 // PB 140

Harga: IDR 189.900,-',
  'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/ar-fashion-glb/xavia_black.glb'
);
```

### Item tanpa Model 3D

```sql
INSERT INTO image_target (name, image_target, description) 
VALUES (
  'Dayana Dress Blue',
  'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/image_target/image_targets/dayana_blue.jpg',
  'Dayana Dress di design simple dengan kombinasi Babydoll yang memadukan nuansa feminim dan modis.

Material: Shakilla Premium
- Lembut dan flowy
- Tidak mudah kusut
- Busui friendly dengan resleting depan
- Free tali lepas pasang

Varian Warna: Dusty Choco, Mauve Lilac, Steel Blue, White, Black

Harga mulai dari Rp 140.000,-'
);
```

## Update & Maintenance

### Menambah Koleksi Baru

1. Upload via Image Target Screen (paling mudah)
2. Atau insert manual via Supabase Dashboard
3. Data akan langsung muncul di Gallery setelah refresh

### Mengedit Item

```sql
UPDATE image_target 
SET 
  name = 'Nama Baru',
  description = 'Deskripsi baru...',
  model_url = 'https://...'
WHERE id = 1;
```

### Menghapus Item

1. Via Image Target Screen (klik icon delete)
2. Atau via Supabase Dashboard:

```sql
DELETE FROM image_target WHERE id = 1;
```

## Roadmap Fitur

Fitur yang akan ditambahkan di masa depan:

- [ ] Filter berdasarkan kategori
- [ ] Search/pencarian item
- [ ] Sort by name, date, dll
- [ ] Favorite/wishlist
- [ ] Share item ke social media
- [ ] Pagination untuk performa lebih baik
- [ ] Offline caching

## Kesimpulan

Gallery Koleksi adalah cara mudah untuk menampilkan semua produk/item yang ada di aplikasi AR Fashion. Dengan menggunakan tabel `image_target` yang sudah ada, tidak perlu setup tambahan dan data tetap sinkron dengan fitur Image Target dan AR Camera.

Untuk pertanyaan atau issue, silakan buka issue di repository atau hubungi developer.
