# AI Chat dengan Fashion Context

## Fitur Baru: AI Mengenal Produk di Gallery

AI chat sekarang bisa memberikan rekomendasi berdasarkan produk yang ada di gallery!

## Cara Kerja

1. **Fashion Context Service** mengambil data dari `GalleryScreen.fashionItems`
2. Data produk (nama, kategori, harga, bahan, warna) dikirim ke AI sebagai context
3. AI menggunakan informasi ini untuk menjawab pertanyaan customer

## Contoh Pertanyaan yang Bisa Dijawab

### 1. Tanya Produk Tersedia
```
User: "Ada dress apa aja?"
AI: "Kami punya beberapa koleksi dress cantik:
     1. Dayana Dress - Rp 140.000-170.000
     2. Nayra Dress - Rp 389.000
     3. Sabrina (Black/White) - Rp 149.000-169.000
     ..."
```

### 2. Tanya Detail Produk
```
User: "Info lengkap Xavia Black dong"
AI: "Xavia Black adalah dress dengan:
     - Bahan: Rayon Premium
     - Harga: Rp 189.900 (S-L)
     - Warna: Black, Cornflower, Glamour, Mulberry
     - Fitur: Busui friendly, Wudhu friendly
     ..."
```

### 3. Cari Berdasarkan Budget
```
User: "Ada dress di bawah 200rb?"
AI: "Ada beberapa pilihan:
     - Dayana Dress mulai Rp 140.000
     - Sabrina Dress mulai Rp 149.000
     - Xavia Series mulai Rp 189.900
     ..."
```

### 4. Cari Berdasarkan Warna
```
User: "Dress warna biru ada?"
AI: "Ada! Kami punya:
     - Dayana Dress warna Steel Blue
     - Xavia Cornflower (biru)
     ..."
```

### 5. Rekomendasi Berdasarkan Kebutuhan
```
User: "Rekomendasi dress untuk acara formal"
AI: "Untuk acara formal, saya rekomendasikan:
     - Nayra Dress (look elegant dengan Swarovski)
     - Valerya Series (mewah dengan detail tule)
     ..."
```

### 6. Tanya Bahan
```
User: "Dress yang bahannya adem apa?"
AI: "Semua dress kami menggunakan bahan premium yang adem:
     - Dayana: Shakilla Premium
     - Xavia: Rayon Premium
     - Valerya: Babydoll Premium
     ..."
```

## Implementasi Teknis

### Fashion Context Service

```dart
// lib/services/fashion_context_service.dart

class FashionContextService {
  // Generate context untuk AI
  static String getFashionContext() {
    // Mengambil data dari GalleryScreen.fashionItems
    // Format menjadi context yang mudah dipahami AI
  }
  
  // Get detail item tertentu
  static String getItemDetail(String itemName) {
    // Return deskripsi lengkap produk
  }
  
  // Search items
  static List<Map<String, String>> searchItems({
    String? keyword,
    String? category,
    String? color,
  }) {
    // Filter produk berdasarkan kriteria
  }
}
```

### Integration dengan AI Service

```dart
// System message dengan fashion context
final fashionContext = FashionContextService.getFashionContext();
messages.add({
  'role': 'system',
  'content': '''$fashionContext

Kamu adalah AI assistant untuk aplikasi AR Fashion.
- Gunakan informasi produk di atas untuk memberikan rekomendasi
- Sebutkan detail harga, bahan, warna, dan ukuran
...''',
});
```

## Data yang Tersedia untuk AI

Untuk setiap produk, AI mendapat informasi:
- ✅ Nama produk
- ✅ Kategori (Dress, dll)
- ✅ Harga (range harga berdasarkan size)
- ✅ Bahan/Material
- ✅ Warna yang tersedia
- ✅ Size chart
- ✅ Fitur khusus (Busui friendly, Wudhu friendly, dll)
- ✅ Deskripsi lengkap

## Keuntungan

1. **Personalized Recommendations** - AI bisa kasih saran sesuai budget dan preferensi
2. **Accurate Information** - Data langsung dari katalog, tidak halusinasi
3. **Up-to-date** - Kalau ada produk baru di gallery, AI langsung tahu
4. **Natural Conversation** - Customer bisa tanya dengan bahasa natural

## Cara Menambah Produk Baru

Cukup tambahkan di `lib/screens/gallery_screen.dart`:

```dart
static final List<Map<String, String>> fashionItems = [
  {
    'name': 'Nama Produk',
    'image': 'assets/images/produk.jpg',
    'category': 'Dress',
    'description': '''
    Detail lengkap produk...
    Harga: Rp xxx
    Bahan: xxx
    Warna: xxx
    ''',
  },
  // ... produk lainnya
];
```

AI akan otomatis mengenali produk baru!

## Limitasi

- Context size terbatas (~4000 tokens), jadi kalau produk terlalu banyak, mungkin perlu dioptimasi
- AI mungkin tidak selalu extract info dengan sempurna dari deskripsi yang panjang
- Untuk info yang sangat spesifik, lebih baik format deskripsi dengan struktur yang jelas

## Future Improvements

1. **Structured Data** - Pisahkan harga, bahan, warna ke field terpisah (bukan dalam deskripsi)
2. **Vector Search** - Gunakan embedding untuk search produk yang lebih akurat
3. **Image Analysis** - Combine dengan vision AI untuk analisis style
4. **User Preferences** - Simpan preferensi user untuk rekomendasi yang lebih personal
5. **Inventory Integration** - Real-time stock information

## Testing

Coba pertanyaan berikut untuk test fitur:

```
✅ "Ada dress apa aja?"
✅ "Berapa harga Dayana Dress?"
✅ "Dress yang bahannya Rayon apa?"
✅ "Rekomendasi dress warna hitam"
✅ "Ada yang di bawah 150rb?"
✅ "Info lengkap Xavia Black"
✅ "Dress untuk acara formal apa?"
✅ "Yang busui friendly apa aja?"
```

## Troubleshooting

### AI tidak menyebutkan produk spesifik
- Pastikan `FashionContextService` sudah di-import
- Cek apakah context ter-generate dengan benar
- Coba pertanyaan yang lebih spesifik

### Response terlalu panjang/terpotong
- Increase `max_tokens` di `huggingface_service.dart`
- Atau minta AI untuk jawab lebih ringkas

### AI salah info harga/detail
- Pastikan format deskripsi di `gallery_screen.dart` konsisten
- Gunakan format yang jelas: "Harga: Rp xxx"
