import '../screens/gallery_screen.dart';

class FashionContextService {
  // Generate context summary dari fashion items untuk AI
  static String getFashionContext() {
    final items = GalleryScreen.fashionItems;
    
    final buffer = StringBuffer();
    buffer.writeln('Kamu adalah AI assistant untuk toko fashion hijab. Berikut adalah katalog produk yang tersedia:');
    buffer.writeln();
    
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.writeln('${i + 1}. ${item['name']}');
      buffer.writeln('   Kategori: ${item['category']}');
      
      // Extract info penting dari deskripsi
      final desc = item['description'] ?? '';
      
      // Extract harga
      final priceMatch = RegExp(r'Rp\s*[\d.,]+').firstMatch(desc);
      if (priceMatch != null) {
        buffer.writeln('   Harga mulai: ${priceMatch.group(0)}');
      }
      
      // Extract bahan
      if (desc.contains('bahan') || desc.contains('material') || desc.contains('Matt')) {
        final bahanMatch = RegExp(r'(bahan|material|Matt)\s*:?\s*([^\n]+)', caseSensitive: false).firstMatch(desc);
        if (bahanMatch != null) {
          buffer.writeln('   Bahan: ${bahanMatch.group(2)?.trim()}');
        }
      }
      
      // Extract warna
      if (desc.contains('warna') || desc.contains('colour')) {
        final warnaSection = desc.split(RegExp(r'(warna|colour)', caseSensitive: false));
        if (warnaSection.length > 1) {
          final warnaText = warnaSection[1].split('\n').take(5).join(', ');
          buffer.writeln('   Warna tersedia: ${warnaText.replaceAll(':', '').trim()}');
        }
      }
      
      buffer.writeln();
    }
    
    buffer.writeln('Gunakan informasi ini untuk menjawab pertanyaan customer tentang produk, harga, bahan, warna, dan ukuran yang tersedia.');
    
    return buffer.toString();
  }
  
  // Get detail lengkap untuk item tertentu
  static String getItemDetail(String itemName) {
    final item = GalleryScreen.fashionItems.firstWhere(
      (item) => item['name']!.toLowerCase().contains(itemName.toLowerCase()),
      orElse: () => {},
    );
    
    if (item.isEmpty) {
      return 'Produk "$itemName" tidak ditemukan dalam katalog.';
    }
    
    return '''
Produk: ${item['name']}
Kategori: ${item['category']}

Detail Lengkap:
${item['description']}
''';
  }
  
  // Search items berdasarkan kriteria
  static List<Map<String, String>> searchItems({
    String? keyword,
    String? category,
    String? color,
  }) {
    var results = GalleryScreen.fashionItems;
    
    if (keyword != null && keyword.isNotEmpty) {
      results = results.where((item) {
        final name = item['name']!.toLowerCase();
        final desc = item['description']!.toLowerCase();
        final key = keyword.toLowerCase();
        return name.contains(key) || desc.contains(key);
      }).toList();
    }
    
    if (category != null && category.isNotEmpty) {
      results = results.where((item) {
        return item['category']!.toLowerCase().contains(category.toLowerCase());
      }).toList();
    }
    
    if (color != null && color.isNotEmpty) {
      results = results.where((item) {
        return item['description']!.toLowerCase().contains(color.toLowerCase());
      }).toList();
    }
    
    return results;
  }
  
  // Get summary untuk rekomendasi
  static String getRecommendationContext(String query) {
    final buffer = StringBuffer();
    buffer.writeln('Berdasarkan pertanyaan customer: "$query"');
    buffer.writeln();
    buffer.writeln('Produk yang tersedia:');
    
    for (var item in GalleryScreen.fashionItems) {
      buffer.writeln('- ${item['name']} (${item['category']})');
    }
    
    buffer.writeln();
    buffer.writeln('Berikan rekomendasi yang sesuai dengan kebutuhan customer.');
    
    return buffer.toString();
  }
}
