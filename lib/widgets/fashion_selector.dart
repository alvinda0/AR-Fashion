import 'package:flutter/material.dart';
import '../models/fashion_item.dart';
import '../services/fashion_data_service.dart';

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    const spacing = 20.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FashionSelector extends StatefulWidget {
  final Function(FashionItem) onItemSelected;
  final FashionCategory? selectedCategory;

  const FashionSelector({
    super.key,
    required this.onItemSelected,
    this.selectedCategory,
  });

  @override
  State<FashionSelector> createState() => _FashionSelectorState();
}

class _FashionSelectorState extends State<FashionSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FashionDataService _dataService = FashionDataService();
  
  final List<FashionCategory> _categories = [
    FashionCategory.hijabs,
    FashionCategory.dresses,
    FashionCategory.accessories,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
    );

    // Set initial tab based on selected category
    if (widget.selectedCategory != null) {
      final index = _categories.indexOf(widget.selectedCategory!);
      if (index != -1) {
        _tabController.index = index;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Fashion Item',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Category tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1E3C72),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF1E3C72),
            tabs: _categories.map((category) {
              return Tab(
                text: _getCategoryName(category),
                icon: Icon(_getCategoryIcon(category)),
              );
            }).toList(),
          ),

          // Items grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                return _buildItemsGrid(category);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid(FashionCategory category) {
    final items = _dataService.getItemsByCategory(category);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada item di kategori ini',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(FashionItem item) {
    return GestureDetector(
      onTap: () {
        try {
          debugPrint('Item card tapped: ${item.name}');
          widget.onItemSelected(item);
          // Delay pop sedikit untuk memastikan callback selesai
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        } catch (e) {
          debugPrint('Error in item card tap: $e');
          // Jangan pop jika ada error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: _buildThumbnail(item),
              ),
            ),

            // Item info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Rp ${_formatPrice(item.price)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                    // Show file size for local assets
                    if (item.metadata['isLocalAsset'] == true && item.metadata['fileSize'] != null)
                      Text(
                        '${item.metadata['fileSize']} • 3D Model',
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    const Spacer(),

                    // Color indicators
                    Row(
                      children: [
                        ...item.availableColors.take(3).map((color) {
                          return Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          );
                        }).toList(),
                        if (item.availableColors.length > 3)
                          Text(
                            '+${item.availableColors.length - 3}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(FashionItem item) {
    // For local GLB assets, show enhanced placeholder
    if (item.metadata['isLocalAsset'] == true) {
      return _buildGLBPlaceholder(item);
    }
    
    // For other items, try to load image or show regular placeholder
    return FutureBuilder<bool>(
      future: _checkImageExists(item.thumbnailPath),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Image.asset(
              item.thumbnailPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder(item);
              },
            ),
          );
        } else {
          return _buildPlaceholder(item);
        }
      },
    );
  }

  Widget _buildGLBPlaceholder(FashionItem item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3C72).withValues(alpha: 0.8),
            const Color(0xFF2A5298).withValues(alpha: 0.6),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPatternPainter(),
            ),
          ),
          
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.view_in_ar,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gamis 3D',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Ready for AR',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // GLB indicator
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'GLB',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkImageExists(String path) async {
    try {
      await DefaultAssetBundle.of(context).load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildPlaceholder(FashionItem item) {
    // Special handling for local GLB assets
    final isLocalAsset = item.metadata['isLocalAsset'] == true;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLocalAsset ? [
            const Color(0xFF4CAF50).withValues(alpha: 0.3),
            const Color(0xFF2E7D32).withValues(alpha: 0.1),
          ] : [
            item.availableColors.first.withValues(alpha: 0.3),
            item.availableColors.first.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getCategoryIcon(item.category),
                  size: 48,
                  color: isLocalAsset 
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.8)
                    : item.availableColors.first.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  item.category == FashionCategory.dresses ? 'Gamis' : 
                  item.category == FashionCategory.hijabs ? 'Hijab' : 
                  'Fashion',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isLocalAsset 
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.9)
                      : item.availableColors.first.withValues(alpha: 0.8),
                  ),
                ),
                if (isLocalAsset) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '3D Model',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isLocalAsset)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.view_in_ar,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getCategoryName(FashionCategory category) {
    switch (category) {
      case FashionCategory.hijabs:
        return 'Hijab';
      case FashionCategory.shirts:
        return 'Kemeja';
      case FashionCategory.jackets:
        return 'Jaket';
      case FashionCategory.dresses:
        return 'Gamis';
      case FashionCategory.accessories:
        return 'Aksesoris';
    }
  }

  IconData _getCategoryIcon(FashionCategory category) {
    switch (category) {
      case FashionCategory.hijabs:
        return Icons.headset_mic;
      case FashionCategory.shirts:
        return Icons.checkroom;
      case FashionCategory.jackets:
        return Icons.dry_cleaning;
      case FashionCategory.dresses:
        return Icons.woman;
      case FashionCategory.accessories:
        return Icons.diamond;
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}