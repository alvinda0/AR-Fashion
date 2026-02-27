# Troubleshooting Image Detection

## Masalah: Model 3D Tidak Muncul Saat Scan Gambar

### Penyebab Umum:

1. **Pencahayaan Kurang**
   - Google ML Kit butuh pencahayaan yang cukup
   - Gambar terlalu gelap tidak terdeteksi

2. **Gambar Terlalu Kecil/Jauh**
   - Dekatkan kamera ke gambar
   - Pastikan gambar memenuhi minimal 50% layar

3. **Gambar Blur/Tidak Fokus**
   - Tunggu kamera fokus otomatis
   - Jangan gerakkan kamera terlalu cepat

4. **Confidence Threshold Terlalu Tinggi**
   - Sudah diturunkan ke 0.2 (20%)
   - Bisa diturunkan lagi jika perlu

### Solusi yang Sudah Diterapkan:

#### 1. Deteksi Lebih Agresif
```dart
// Threshold diturunkan dari 0.3 ke 0.2
if (label.confidence > 0.2) {
  // Process detection
}
```

#### 2. Keyword Matching Lebih Luas
Sekarang mendeteksi:
- Visual content: poster, picture, photo, image, paper, document, print, text, advertisement, flyer
- Colors: blue, azure, black, dark, white, light, pink, rose, purple, violet, lavender
- Clothing: dress, clothing, fashion, apparel, garment, textile, fabric, wear, outfit, attire
- Person: person, woman, model, human, face

#### 3. Scan Interval Lebih Cepat
```dart
// Dari 1500ms ke 1000ms
Timer.periodic(const Duration(milliseconds: 1000), ...)
```

#### 4. Manual Trigger Button
- Tombol hijau di kanan atas (icon touch_app)
- Untuk testing tanpa perlu scan gambar
- Klik untuk cycle through products

### Cara Testing:

#### A. Test dengan Manual Trigger
1. Buka AR Camera
2. Klik tombol hijau (touch_app icon) di kanan atas
3. Model 3D harus muncul
4. Klik lagi untuk ganti model

#### B. Test dengan Image Detection
1. Siapkan gambar produk (print atau di layar lain)
2. Pastikan pencahayaan cukup
3. Dekatkan kamera ke gambar (jarak 20-30cm)
4. Tunggu 1-2 detik
5. Lihat debug log di console

#### C. Lihat Debug Log
```bash
flutter run
```

Cari output seperti:
```
=== Text Detected ===
[detected text]

=== Image Labels Detected ===
Label: poster, Confidence: 0.85
Label: picture, Confidence: 0.72

✓✓✓ MATCHED: dayana for label: poster (confidence: 0.85)
```

### Tips Meningkatkan Deteksi:

#### 1. Gunakan Gambar yang Jelas
- Print gambar produk dengan kualitas tinggi
- Ukuran minimal A5 (148 x 210 mm)
- Hindari gambar glossy yang reflektif

#### 2. Pencahayaan Optimal
- Cahaya natural/lampu putih
- Hindari backlight
- Hindari bayangan pada gambar

#### 3. Jarak dan Angle
- Jarak optimal: 20-40cm
- Angle: tegak lurus (90°)
- Gambar memenuhi 50-80% layar

#### 4. Tambahkan Text pada Gambar
Karena ada text recognition, tambahkan text pada gambar:
- "DAYANA"
- "NAYRA"
- "SABRINA"
- "VALERYA"
- "XAVIA"

### Jika Masih Tidak Terdeteksi:

#### Option 1: Turunkan Threshold Lagi
```dart
// Di _processCurrentFrame()
if (label.confidence > 0.1) { // Dari 0.2 ke 0.1
```

#### Option 2: Force Detection untuk Semua Label
```dart
// Di _findMatchingItem()
// Tambahkan di akhir method:
debugPrint('✓ FORCE MATCH - showing default item');
return _fashionItems.first['id'];
```

#### Option 3: Gunakan QR Code
Alternatif: gunakan QR code untuk trigger model:
1. Generate QR code dengan text "DAYANA", "NAYRA", dll
2. Scan QR code akan trigger model

#### Option 4: Gunakan Image Marker
Gunakan library AR yang support image tracking:
- ARCore (Android)
- ARKit (iOS)
- Vuforia (cross-platform)

### Debug Checklist:

- [ ] Camera permission granted
- [ ] Camera initialized successfully
- [ ] Recognition timer running
- [ ] Image processing tidak error
- [ ] Labels terdeteksi (lihat console)
- [ ] Confidence > 0.2
- [ ] Keyword matching berhasil
- [ ] setState dipanggil
- [ ] Model URL valid
- [ ] Internet connection aktif

### Performance Monitoring:

Tambahkan di console untuk monitoring:
```dart
debugPrint('Processing: $_isProcessingImage');
debugPrint('Loading: $_isLoadingModel');
debugPrint('Selected: $_selectedItemId');
debugPrint('Labels count: ${labels.length}');
```

### Alternative Solutions:

Jika image detection tetap tidak reliable:

1. **Gunakan Manual Selection**
   - User pilih dari list di bawah
   - Lebih reliable, UX lebih jelas

2. **Gunakan QR Code**
   - Generate QR per produk
   - Scan QR = instant trigger
   - 100% reliable

3. **Gunakan NFC Tags**
   - Tempel NFC tag di poster
   - Tap phone = trigger model
   - Premium experience

4. **Gunakan AR Foundation**
   - Image tracking yang proper
   - Support marker-based AR
   - Lebih complex tapi lebih reliable

### Rekomendasi:

Untuk production app, kombinasikan:
1. **Image detection** (current) - untuk "wow" factor
2. **Manual selection** (sudah ada) - sebagai fallback
3. **QR code** (optional) - untuk reliability

User bisa pilih mana yang paling nyaman untuk mereka.
