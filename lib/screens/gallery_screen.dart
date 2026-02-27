import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  static final List<Map<String, String>> fashionItems = [
    {
      'name': 'Dayana',
      'image': 'assets/images/dayana.jpg',
      'category': 'Dress',
      'description': '''Bismillah…Open Katalog Seragaman💐

Dayana Dress by @aerahijab.official💐

Dayana Dress di design simple dengan kombinasi Babydoll yang memadukan nuansa feminim dan modis. Menggunakan bahan utama Shakilla Premium yang lembut, serta sifatnya yang flowy dan tidak mudah kusut, sehingga sangat praktis untuk dirawat.

Dayana Dress memberikan sentuhan mewah dan modern untuk penampilan sehari-hari Anda✨

🖊Detail :
⁃ Matt : Shakilla Premium
⁃ Terdapat kombinasi layer dengan material Babydoll Premium yang membuat dressnya terlihat lebih menawan
⁃ Terdapat aksen manik permata pada bagian depan yang membuat looknya elegan
⁃ Terdapat kancing pada layer Babydoll Premium
⁃ Terdapat resleting pada bagian depan dressnya sehingga busui friendly
⁃ Menggunakan desain kerah kemeja yang membuat looknya simpel namun tetap menawan
⁃ Terdapat saku pada bagian kanan sehingga memudahkan untuk membawa barang-barang kecil
⁃ Desain lengan dari kombinasi Babydoll Premium yang mempercantik tampilannya
⁃ Free tali lepas pasang untuk styling dressnya, sehingga bisa dijadikan beberapa macam style

🌈Varian Warna :
⁃ Dusty Choco
⁃ Mauve Lilac
⁃ Steel Blue 
⁃ White
⁃ Black

Pashmina :
⁃ Dusty Choco
⁃ Mauve Lilac 
⁃ Steel Blue
⁃ White
⁃ Black

📐 Sizechart :
* XS : LD 84 cm // PB 125 cm
* S : LD 90 cm // PB 131 cm
* M : LD 96 cm // PB 135 cm
* L : LD 100 cm // PB 137 cm
* XL : LD 110 cm // PB 140 cm
* XXL : LD 120 cm // PB 142 cm

Pashmina : 180 cm x 70 cm

⚖️ Estimasi Berat : 400 gram

💵Pricelist 
* XS : Rp 140.000 ,-
* S : Rp 150.000 ,-
* M : Rp 155.000 ,-
* L : Rp 160.000 ,-
* XL : Rp 165.000 ,-
* XXL : Rp 170.000 ,-

Pashmina : Rp 55.000 ,-

⛔️Lebih atau Kurang 1-3 Cm dikarenakan Proses Produksi
⛔️ Kemiripan warna 90%, Karena setiap layar HP/PC mempunyai karakteristik yang berbeda. Selain itu efek pencahayaan saat Photoshot bisa saja mempengaruhi tampilan warna pada hasil foto''',
    },
    {
      'name': 'Nayra',
      'image': 'assets/images/nayra.jpg',
      'category': 'Dress',
      'description': '''NAYRA Dress AFAS X SITA
(Open PO 19-26 Jan 2026)

Detail Dress

🌸 Material Ceruty Babydoll premium memiliki karakteristik bahan yang jatuh, lembut, tidak mudah kusut, dan sangat adem
🌸 Menggunakan resleting belakang
🌸 Kerah Shanghai untuk tampilan rapi namun tetap santai
🌸 Terdapat variasi lis kombinasi vertikal di bagian depan untuk membuat ilusi tubuh menjadi lebih slim dan jenjang
🌸 Variasi Swarovski pada bagian depan membuat look lebih elegant
🌸 Menggunakan lengan manset untuk memberikan keseimbangan antara ringan dan rapi yang modern (Wudhu Friendly)
🌸 Cutting A-line, melebar kebawah dengan anggun, memberikan kesan feminim dan sopan
🌸 Terdapat Plat Ekslusif di bagian lengan

Warna
🌸 Coffee
🌸 Jade
🌸 Steel

Size
Dress : XS-XXL

Harga
XS-XL : ~429.000~ 389.000
XXL : +30.000

Nayra Dress by @sita.id.official @afas_id 

NOTE :
⚘️ Perbedaan warna 10-20% karena efek cahaya dalam photoshoot
⚘️ Perbedaan ukuran bisa lebih atau kurang karena proses produksi
⚘️ Estimasi Ready 3-4 minggu setelah close PO
⚘️ Full Payment
⚘️ Produk Ready akan diinfokan 1 minggu sebelumnya untuk diteruskan di tim masing-masing''',
    },
    {
      'name': 'Sabrina Black',
      'image': 'assets/images/sabrina black.jpg',
      'category': 'Dress',
      'description': '''Bismillah…

Aruni kembali menghadirkan dress cantik berbahan Shakila dan Rayon premium yang membuat penampilan semakin cantik maksimal. 

✨ ALUNA DRESS BATCH 2 ✨

Perpaduan cantik antara bahan polosan Shakillah yang jatuh & adem dengan motif rayon salur yang lembut dan ringan. Aluna Dress hadir dengan tampilan casual yang manis, sopan, dan tetap stylish untuk dipakai kapan saja!

✨ Keunggulan Aluna Dress
• Bahan polosan Shakillah: jatuh, halus, adem
• Bahan motif rayon salur: lembut, ringan, adem
• Perpaduan warna & motif yang harmonis
• Potongan rapi, sopan, dan nyaman untuk daily

✨ Detail Tambahan
📎 3 kancing hidup pada bagian dada (Busui Friendly)
📎 Saku di bagian kanan, praktis untuk aktivitas harian
📎 Lengan karet (Wudhu Friendly)
📎 Kerah bulat simpel & rapi
📎 Model casual dengan perpaduan tangan polos yang disambung motif rayon salur, bikin penampilan makin kece dan modern. 

✨ Pilihan warna:
- Black
- Mocha

✨ Size Chart
XS = LD 90 // PB 130
S   = LD 95 // PB 135
M   = LD 100 // PB 138
L   = LD 104 // PB 140
XL  = LD 110 // PB 140
XXL = LD 120 // PB 140

✨ Pricelist
XS – S : 149K
M – L : 159K
XL – XXL : 169K

Harga scraft 69Rb
Ukuran 110 x 110''',
    },
    {
      'name': 'Sabrina White',
      'image': 'assets/images/sabrina white.jpg',
      'category': 'Dress',
      'description': '''Bismillah…

Aruni kembali menghadirkan dress cantik berbahan Shakila dan Rayon premium yang membuat penampilan semakin cantik maksimal. 

✨ ALUNA DRESS BATCH 2 ✨

Perpaduan cantik antara bahan polosan Shakillah yang jatuh & adem dengan motif rayon salur yang lembut dan ringan. Aluna Dress hadir dengan tampilan casual yang manis, sopan, dan tetap stylish untuk dipakai kapan saja!

✨ Keunggulan Aluna Dress
• Bahan polosan Shakillah: jatuh, halus, adem
• Bahan motif rayon salur: lembut, ringan, adem
• Perpaduan warna & motif yang harmonis
• Potongan rapi, sopan, dan nyaman untuk daily

✨ Detail Tambahan
📎 3 kancing hidup pada bagian dada (Busui Friendly)
📎 Saku di bagian kanan, praktis untuk aktivitas harian
📎 Lengan karet (Wudhu Friendly)
📎 Kerah bulat simpel & rapi
📎 Model casual dengan perpaduan tangan polos yang disambung motif rayon salur, bikin penampilan makin kece dan modern. 

✨ Pilihan warna:
- Black
- Mocha

✨ Size Chart
XS = LD 90 // PB 130
S   = LD 95 // PB 135
M   = LD 100 // PB 138
L   = LD 104 // PB 140
XL  = LD 110 // PB 140
XXL = LD 120 // PB 140

✨ Pricelist
XS – S : 149K
M – L : 159K
XL – XXL : 169K

Harga scraft 69Rb
Ukuran 110 x 110''',
    },
    {
      'name': 'Valerya Dusty',
      'image': 'assets/images/valerya pink.jpg',
      'category': 'Dress',
      'description': '''Bismillahirrahmanirrahim..
Sebelum menyimak lebih lanjut, jangan lupa shalawatan dulu yuk! Semoga jualan kita laris manis dan berkah untuk kita semua. Aamiin.. 🤲🏻

VALERYA SERIES NEW - Dusty
On model pakai size M

Berbahan babydoll premium X rayon premium X tule premium yang sangat nyaman, adem. Modelnya simple namun looknya super mewah! Cocok banget untuk outfit daily, outfit hangout atau semi formal My Nadheera! 😍

DETAIL DRESS & MIDI DRESS :
✔️ model simpel looknya mewah dan so slimmy
✔️ detail lengan puffy dengan kopel karet smoke dipadukan dengan tule premium ( Wudlu friendly )
✔️ detail kerah shanghai dengan detail zipper bagian depan dan tali adjustable
✔️ detail Cutting super lebar dengan floi 
✔️ berlabel ORI Nadheera Luxury

Size Chart Midi Dress :
LD : 92/96/100/104
PB : 130
P. Lengan : 57

Size Chart Dress :
LD : 92/96/100/104
PB : 135/138/140/140
P. Lengan : 57

HARGA NORMAL DRESS & MIDI DRESS :
IDR 379.900,- (S)
IDR 389.900,- (M)
IDR 399.900,- (L)
IDR 409.900,- (XL)

HARGA SP DRESS & MIDI DRESS S-M :
Retail : IDR 299.900,-
Reseller : IDR 284.900,-
Sub Agen : IDR 269.900,-
Agen : IDR 249.900,-

HARGA SP DRESS & MIDI DRESS L-XL :
Retail : IDR 309.900,-
Reseller : IDR 294.900,-
Sub Agen : IDR 279.900,-
Agen : IDR 259.900,-

NOTE : 
Retail - Sub Agen : Jika order dibawah minimal +7.500,-/item
Agen - Distributor : Jika order dibawah minimal +10.000,-/item

Available Colour :
• bamboo
• blue caroline
• dusty
• olive

OPEN LIST H+1 SETELAH LAUNCHING S/D RABU, 21 JANUARI PUKUL 08.30 WIB ‼️
INSYALLAH LANGSUNG PEMBAGIAN''',
    },
    {
      'name': 'Xavia Black',
      'image': 'assets/images/xavia black.jpg',
      'category': 'Dress',
      'description': '''Bismillahirrahmanirrahim..
Sebelum menyimak lebih lanjut, jangan lupa shalawatan dulu yuk! Semoga jualan kita laris manis dan berkah untuk kita semua. Aamiin.. 🤲🏻

XAVIA SERIES
On model pakai size M

Berbahan rayon premium yang sangat nyaman, adem. Modelnya simple namun looknya super mewah! Cocok banget untuk outfit daily, outfit hangout atau semi formal My Nadheera! 😍

DETAIL DRESS & MIDI DRESS :
✔️ model simpel looknya mewah dan so slimmy
✔️ detail lengan semi puffy dengan kopel karet ( Wudlu friendly )
✔️ detail kerah shanghai dengan detail zipper bagian depan ( Busui friendly ) 
✔️ detail Cutting Aline super lebar 
✔️ berlabel ORI Nadheera Luxury

Size Chart Midi Dress :
LD : 92/96/100/104/110/120
PB : 130
P. Lengan : 57

Size Chart Dress :
LD : 92/96/100/104/110/120
PB : 135/138/140/140/140/140
P. Lengan : 57

HARGA NORMAL DRESS & MIDI DRESS :
IDR 239.900,- (S)
IDR 244.900,- (M)
IDR 249.900,- (L)
IDR 254.900,- (XL)
IDR 259.900,- (XXL)
IDR 264.900,- (XXXL)

HARGA SP DRESS & MIDI DRESS S-L :
Retail : IDR 189.900,-
Reseller : IDR 179.900,-
Sub Agen : IDR 169.900,-
Agen : IDR 154.900,-

HARGA SP DRESS & MIDI DRESS XL-XXXL :
Retail : IDR 194.900,-
Reseller : IDR 184.900,-
Sub Agen : IDR 174.900,-
Agen : IDR 159.900,-

NOTE :
Retail-Sub Agen : Jika order dibawah minimal +5.000,-/item
Agen-Distributor : Jika order dibawah minimal +7.500,-/item

Available Colour :
• black
• cornflower
• glamour
• mulberry

OPEN LIST H+1 SETELAH LAUNCHING S/D RABU, 21 JANUARI 2026 PUKUL 08.30 WIB ‼️
INSYALLAH LANGSUNG PEMBAGIAN📌''',
    },
    {
      'name': 'Xavia Blue',
      'image': 'assets/images/xavia blue.jpg',
      'category': 'Dress',
      'description': '''Bismillahirrahmanirrahim..
Sebelum menyimak lebih lanjut, jangan lupa shalawatan dulu yuk! Semoga jualan kita laris manis dan berkah untuk kita semua. Aamiin.. 🤲🏻

XAVIA SERIES - Cornflower Blue
On model pakai size M

Berbahan rayon premium yang sangat nyaman, adem. Modelnya simple namun looknya super mewah! Cocok banget untuk outfit daily, outfit hangout atau semi formal My Nadheera! 😍

DETAIL DRESS & MIDI DRESS :
✔️ model simpel looknya mewah dan so slimmy
✔️ detail lengan semi puffy dengan kopel karet ( Wudlu friendly )
✔️ detail kerah shanghai dengan detail zipper bagian depan ( Busui friendly ) 
✔️ detail Cutting Aline super lebar 
✔️ berlabel ORI Nadheera Luxury

Size Chart Midi Dress :
LD : 92/96/100/104/110/120
PB : 130
P. Lengan : 57

Size Chart Dress :
LD : 92/96/100/104/110/120
PB : 135/138/140/140/140/140
P. Lengan : 57

HARGA NORMAL DRESS & MIDI DRESS :
IDR 239.900,- (S)
IDR 244.900,- (M)
IDR 249.900,- (L)
IDR 254.900,- (XL)
IDR 259.900,- (XXL)
IDR 264.900,- (XXXL)

HARGA SP DRESS & MIDI DRESS S-L :
Retail : IDR 189.900,-
Reseller : IDR 179.900,-
Sub Agen : IDR 169.900,-
Agen : IDR 154.900,-

HARGA SP DRESS & MIDI DRESS XL-XXXL :
Retail : IDR 194.900,-
Reseller : IDR 184.900,-
Sub Agen : IDR 174.900,-
Agen : IDR 159.900,-

NOTE :
Retail-Sub Agen : Jika order dibawah minimal +5.000,-/item
Agen-Distributor : Jika order dibawah minimal +7.500,-/item

Available Colour :
• black
• cornflower
• glamour
• mulberry

OPEN LIST H+1 SETELAH LAUNCHING S/D RABU, 21 JANUARI 2026 PUKUL 08.30 WIB ‼️
INSYALLAH LANGSUNG PEMBAGIAN📌''',
    },
    {
      'name': 'Xavia Glamour',
      'image': 'assets/images/xavia blue old.jpg',
      'category': 'Dress',
      'description': '''Bismillahirrahmanirrahim..
Sebelum menyimak lebih lanjut, jangan lupa shalawatan dulu yuk! Semoga jualan kita laris manis dan berkah untuk kita semua. Aamiin.. 🤲🏻

XAVIA SERIES - Glamour
On model pakai size M

Berbahan rayon premium yang sangat nyaman, adem. Modelnya simple namun looknya super mewah! Cocok banget untuk outfit daily, outfit hangout atau semi formal My Nadheera! 😍

DETAIL DRESS & MIDI DRESS :
✔️ model simpel looknya mewah dan so slimmy
✔️ detail lengan semi puffy dengan kopel karet ( Wudlu friendly )
✔️ detail kerah shanghai dengan detail zipper bagian depan ( Busui friendly ) 
✔️ detail Cutting Aline super lebar 
✔️ berlabel ORI Nadheera Luxury

Size Chart Midi Dress :
LD : 92/96/100/104/110/120
PB : 130
P. Lengan : 57

Size Chart Dress :
LD : 92/96/100/104/110/120
PB : 135/138/140/140/140/140
P. Lengan : 57

HARGA NORMAL DRESS & MIDI DRESS :
IDR 239.900,- (S)
IDR 244.900,- (M)
IDR 249.900,- (L)
IDR 254.900,- (XL)
IDR 259.900,- (XXL)
IDR 264.900,- (XXXL)

HARGA SP DRESS & MIDI DRESS S-L :
Retail : IDR 189.900,-
Reseller : IDR 179.900,-
Sub Agen : IDR 169.900,-
Agen : IDR 154.900,-

HARGA SP DRESS & MIDI DRESS XL-XXXL :
Retail : IDR 194.900,-
Reseller : IDR 184.900,-
Sub Agen : IDR 174.900,-
Agen : IDR 159.900,-

NOTE :
Retail-Sub Agen : Jika order dibawah minimal +5.000,-/item
Agen-Distributor : Jika order dibawah minimal +7.500,-/item

Available Colour :
• black
• cornflower
• glamour
• mulberry

OPEN LIST H+1 SETELAH LAUNCHING S/D RABU, 21 JANUARI 2026 PUKUL 08.30 WIB ‼️
INSYALLAH LANGSUNG PEMBAGIAN📌''',
    },
    {
      'name': 'Xavia Purple',
      'image': 'assets/images/xavia purple.jpg',
      'category': 'Dress',
      'description': '''Bismillahirrahmanirrahim..
Sebelum menyimak lebih lanjut, jangan lupa shalawatan dulu yuk! Semoga jualan kita laris manis dan berkah untuk kita semua. Aamiin.. 🤲🏻

XAVIA SERIES - Mulberry
On model pakai size M

Berbahan rayon premium yang sangat nyaman, adem. Modelnya simple namun looknya super mewah! Cocok banget untuk outfit daily, outfit hangout atau semi formal My Nadheera! 😍

DETAIL DRESS & MIDI DRESS :
✔️ model simpel looknya mewah dan so slimmy
✔️ detail lengan semi puffy dengan kopel karet ( Wudlu friendly )
✔️ detail kerah shanghai dengan detail zipper bagian depan ( Busui friendly ) 
✔️ detail Cutting Aline super lebar 
✔️ berlabel ORI Nadheera Luxury

Size Chart Midi Dress :
LD : 92/96/100/104/110/120
PB : 130
P. Lengan : 57

Size Chart Dress :
LD : 92/96/100/104/110/120
PB : 135/138/140/140/140/140
P. Lengan : 57

HARGA NORMAL DRESS & MIDI DRESS :
IDR 239.900,- (S)
IDR 244.900,- (M)
IDR 249.900,- (L)
IDR 254.900,- (XL)
IDR 259.900,- (XXL)
IDR 264.900,- (XXXL)

HARGA SP DRESS & MIDI DRESS S-L :
Retail : IDR 189.900,-
Reseller : IDR 179.900,-
Sub Agen : IDR 169.900,-
Agen : IDR 154.900,-

HARGA SP DRESS & MIDI DRESS XL-XXXL :
Retail : IDR 194.900,-
Reseller : IDR 184.900,-
Sub Agen : IDR 174.900,-
Agen : IDR 159.900,-

NOTE :
Retail-Sub Agen : Jika order dibawah minimal +5.000,-/item
Agen-Distributor : Jika order dibawah minimal +7.500,-/item

Available Colour :
• black
• cornflower
• glamour
• mulberry

OPEN LIST H+1 SETELAH LAUNCHING S/D RABU, 21 JANUARI 2026 PUKUL 08.30 WIB ‼️
INSYALLAH LANGSUNG PEMBAGIAN📌''',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Koleksi'),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: fashionItems.length,
        itemBuilder: (context, index) {
          final item = fashionItems[index];
          return _buildGalleryItem(context, item);
        },
      ),
    );
  }

  Widget _buildGalleryItem(BuildContext context, Map<String, String> item) {
    return GestureDetector(
      onTap: () => _showImageDetail(context, item),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  item['image']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['category']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDetail(BuildContext context, Map<String, String> item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          child: Column(
            children: [
              // Header dengan tombol close
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Content scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row dengan gambar dan kategori
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gambar lebih besar di kiri
                          Container(
                            width: 160,
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                item['image']!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Info singkat di kanan gambar
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00796B).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF00796B),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    item['category']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF00796B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Koleksi ${item['category']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Bahan premium dengan kualitas terbaik untuk penampilan Anda',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.green[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Ready Stock',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_shipping_outlined,
                                      size: 16,
                                      color: Colors.blue[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Pengiriman Cepat',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      
                      // Deskripsi lengkap
                      Text(
                        item['description']!,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
