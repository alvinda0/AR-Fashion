import 'package:flutter/material.dart';

class FashionCollectionScreen extends StatefulWidget {
  const FashionCollectionScreen({super.key});

  @override
  State<FashionCollectionScreen> createState() => _FashionCollectionScreenState();
}

class _FashionCollectionScreenState extends State<FashionCollectionScreen> {
  final List<Map<String, dynamic>> _fashionCategories = [
    {
      'title': 'Hijab Segi Empat',
      'icon': Icons.crop_square,
      'items': ['Hijab Voal', 'Hijab Satin', 'Hijab Chiffon', 'Hijab Organza'],
      'color': Colors.blue,
    },
    {
      'title': 'Hijab Instan',
      'icon': Icons.headset_mic,
      'items': ['Hijab Bergo', 'Hijab Pet', 'Hijab Khimar', 'Hijab Pashmina'],
      'color': Colors.indigo,
    },
    {
      'title': 'Jilbab Syari',
      'icon': Icons.woman,
      'items': ['Jilbab Set', 'Gamis Set', 'Abaya', 'Kaftan'],
      'color': Colors.blueAccent,
    },
    {
      'title': 'Aksesoris',
      'icon': Icons.star,
      'items': ['Bros Hijab', 'Ciput', 'Inner Hijab', 'Peniti Hijab'],
      'color': Colors.lightBlue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3C72), // Blue primary
              Color(0xFF2A5298), // Blue lighter
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 16,
                      vertical: isTablet ? 24 : 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Gallery Hijab',
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          'Jelajahi galeri hijab dan busana muslim kami',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: isTablet ? 32 : 24),
                        
                        // Grid
                        _buildResponsiveGrid(isTablet, isLandscape),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(bool isTablet, bool isLandscape) {
    // Determine grid layout based on screen size
    int crossAxisCount;
    double childAspectRatio;
    
    if (isTablet) {
      crossAxisCount = isLandscape ? 4 : 3;
      childAspectRatio = isLandscape ? 1.3 : 1.2;
    } else {
      crossAxisCount = isLandscape ? 3 : 2;
      childAspectRatio = isLandscape ? 1.4 : 1.2;
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isTablet ? 20 : 16,
        mainAxisSpacing: isTablet ? 20 : 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _fashionCategories.length,
      itemBuilder: (context, index) {
        final category = _fashionCategories[index];
        return _buildCategoryCard(category, isTablet);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, bool isTablet) {
    final iconSize = isTablet ? 60.0 : 45.0;
    final titleSize = isTablet ? 16.0 : 14.0;
    final subtitleSize = isTablet ? 12.0 : 11.0;
    final cardPadding = isTablet ? 12.0 : 10.0;
    
    return GestureDetector(
      onTap: () => _showCategoryItems(category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(iconSize / 2),
                  border: Border.all(
                    color: (category['color'] as Color).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  category['icon'] as IconData,
                  size: iconSize * 0.45,
                  color: category['color'] as Color,
                ),
              ),
              
              SizedBox(height: isTablet ? 8 : 6),
              
              // Title
              Flexible(
                child: Text(
                  category['title'] as String,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              SizedBox(height: isTablet ? 6 : 4),
              
              // Item count
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 8 : 6,
                  vertical: isTablet ? 3 : 2,
                ),
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(category['items'] as List).length} items',
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryItems(Map<String, dynamic> category) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: screenSize.height * (isLandscape ? 0.8 : 0.7),
          minHeight: screenSize.height * 0.3,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1E3C72), // Blue primary
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: isLandscape && !isTablet
                      ? _buildLandscapeModalContent(category, isTablet)
                      : _buildPortraitModalContent(category, isTablet),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitModalContent(Map<String, dynamic> category, bool isTablet) {
    final titleSize = isTablet ? 24.0 : 20.0;
    final itemTextSize = isTablet ? 18.0 : 16.0;
    final buttonTextSize = isTablet ? 18.0 : 16.0;
    final iconSize = isTablet ? 28.0 : 24.0;
    final itemPadding = isTablet ? 20.0 : 16.0;
    final buttonHeight = isTablet ? 56.0 : 48.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              category['icon'] as IconData,
              color: category['color'] as Color,
              size: iconSize,
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Text(
                category['title'] as String,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: isTablet ? 24 : 20),
        
        // Items grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 2 : 1,
            crossAxisSpacing: isTablet ? 16 : 0,
            mainAxisSpacing: isTablet ? 16 : 12,
            childAspectRatio: isTablet ? 3 : 4,
          ),
          itemCount: (category['items'] as List<String>).length,
          itemBuilder: (context, index) {
            final item = (category['items'] as List<String>)[index];
            return Container(
              padding: EdgeInsets.all(itemPadding),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (category['color'] as Color).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: isTablet ? 40 : 32,
                    height: isTablet ? 40 : 32,
                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getItemIcon(item),
                      color: category['color'] as Color,
                      size: isTablet ? 20 : 16,
                    ),
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: itemTextSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        
        SizedBox(height: isTablet ? 32 : 24),
        
        // Action button
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fitur ${category['title']} akan segera tersedia!'),
                  backgroundColor: category['color'] as Color,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: category['color'] as Color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonHeight / 2),
              ),
              elevation: 4,
            ),
            child: Text(
              'Coba Sekarang',
              style: TextStyle(
                fontSize: buttonTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // Bottom padding for safe area
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }

  Widget _buildLandscapeModalContent(Map<String, dynamic> category, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Header
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category['title'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih dari ${(category['items'] as List).length} pilihan ${category['title'].toString().toLowerCase()} di galeri kami',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Right side - Items and button
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Items
              ...((category['items'] as List<String>).map((item) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (category['color'] as Color).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: (category['color'] as Color).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _getItemIcon(item),
                            color: category['color'] as Color,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
              
              const SizedBox(height: 16),
              
              // Action button
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fitur ${category['title']} akan segera tersedia!'),
                        backgroundColor: category['color'] as Color,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: category['color'] as Color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Coba Sekarang',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getItemIcon(String item) {
    // Return appropriate icons for different hijab items
    if (item.toLowerCase().contains('voal') || item.toLowerCase().contains('satin')) {
      return Icons.texture;
    } else if (item.toLowerCase().contains('bergo') || item.toLowerCase().contains('instan')) {
      return Icons.headset_mic;
    } else if (item.toLowerCase().contains('jilbab') || item.toLowerCase().contains('gamis')) {
      return Icons.woman;
    } else if (item.toLowerCase().contains('bros') || item.toLowerCase().contains('aksesoris')) {
      return Icons.star;
    } else if (item.toLowerCase().contains('ciput') || item.toLowerCase().contains('inner')) {
      return Icons.circle;
    } else {
      return Icons.checkroom;
    }
  }
}