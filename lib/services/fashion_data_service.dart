import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/fashion_item.dart';

class FashionDataService {
  static final FashionDataService _instance = FashionDataService._internal();
  factory FashionDataService() => _instance;
  FashionDataService._internal();

  List<FashionItem> _fashionItems = [];
  bool _isInitialized = false;

  // Initialize data service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Fashion data service already initialized');
      return;
    }
    
    debugPrint('Initializing fashion data service...');
    
    try {
      // Try to load from assets first
      await _loadFromAssets().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('Assets loading timeout - using default items');
          throw Exception('Assets loading timeout');
        },
      );
    } catch (e) {
      debugPrint('Assets loading failed: $e - using default items');
      _loadDefaultItems();
    }
    
    _isInitialized = true;
    debugPrint('Fashion data service initialized with ${_fashionItems.length} items');
  }

  // Load fashion items from assets and local storage
  Future<void> _loadFashionItems() async {
    try {
      // Load from assets (default items)
      await _loadFromAssets();
      
      // Skip local storage for now to avoid hang
      // await _loadFromLocalStorage();
      
    } catch (e) {
      debugPrint('Error loading fashion items: $e');
      // Load default items if error
      _loadDefaultItems();
    }
  }

  Future<void> _loadFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/fashion_items.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      final List<FashionItem> assetItems = jsonList
          .map((json) => FashionItem.fromJson(json))
          .toList();
      
      _fashionItems.addAll(assetItems);
    } catch (e) {
      debugPrint('No fashion_items.json found in assets, using default items');
    }
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/custom_fashion_items.json');
      
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        
        final List<FashionItem> customItems = jsonList
            .map((json) => FashionItem.fromJson(json))
            .toList();
        
        _fashionItems.addAll(customItems);
      }
    } catch (e) {
      debugPrint('Error loading custom items: $e');
    }
  }

  void _loadDefaultItems() {
    _fashionItems = [
      // Hijabs
      FashionItem(
        id: 'hijab_001',
        name: 'Hijab Segi Empat Premium',
        description: 'Hijab segi empat dengan bahan premium, nyaman digunakan sehari-hari',
        category: FashionCategory.hijabs,
        modelPath: 'assets/models/clothing/hijabs/hijab_square.glb',
        thumbnailPath: 'assets/images/hijabs/hijab_square_thumb.jpg',
        availableSizes: ['S', 'M', 'L'],
        availableColors: [Colors.black, Colors.white, const Color(0xFF8D6E63), Colors.grey],
        price: 85000,
        metadata: const {
          'material': 'Voal Premium',
          'brand': 'Vast Hijab',
          'care': 'Hand wash only',
        },
      ),
      
      FashionItem(
        id: 'hijab_002',
        name: 'Hijab Pashmina Instant',
        description: 'Hijab pashmina dengan model instant, praktis dan elegan',
        category: FashionCategory.hijabs,
        modelPath: 'assets/models/clothing/hijabs/hijab_pashmina.glb',
        thumbnailPath: 'assets/images/hijabs/hijab_pashmina_thumb.jpg',
        availableSizes: ['M', 'L'],
        availableColors: [const Color(0xFF1565C0), const Color(0xFF8E24AA), const Color(0xFF689F38), const Color(0xFFEC407A)],
        price: 125000,
        metadata: const {
          'material': 'Chiffon Ceruti',
          'brand': 'Vast Hijab',
          'style': 'Instant',
        },
      ),

      FashionItem(
        id: 'hijab_003',
        name: 'Hijab Bergo Daily',
        description: 'Hijab bergo untuk pemakaian sehari-hari, simple dan nyaman',
        category: FashionCategory.hijabs,
        modelPath: 'assets/models/clothing/hijabs/hijab_bergo.glb',
        thumbnailPath: 'assets/images/hijabs/hijab_bergo_thumb.jpg',
        availableSizes: ['S', 'M', 'L', 'XL'],
        availableColors: [Colors.black, Colors.white, Colors.grey, const Color(0xFFF5F5DC)],
        price: 65000,
        metadata: const {
          'material': 'Jersey Premium',
          'brand': 'Vast Hijab',
          'style': 'Bergo',
        },
      ),

      // Dresses
      FashionItem(
        id: 'dress_001',
        name: 'Gamis Tes Custom',
        description: 'Gamis custom dengan model 3D lokal untuk testing AR try-on',
        category: FashionCategory.dresses,
        modelPath: 'assets/models/clothing/dresses/tes.glb',
        thumbnailPath: 'assets/images/dresses/tes_thumb.jpg',
        availableSizes: ['S', 'M', 'L', 'XL'],
        availableColors: [Colors.black, const Color(0xFF1565C0), const Color(0xFF8E24AA)],
        price: 285000,
        metadata: const {
          'material': 'Custom 3D Model',
          'brand': 'Vast Fashion',
          'style': 'Test Gamis',
          'fileSize': '59.8MB',
          'isLocalAsset': true,
        },
      ),

      FashionItem(
        id: 'dress_002',
        name: 'Tunik Casual Modern',
        description: 'Tunik casual dengan desain modern untuk aktivitas sehari-hari',
        category: FashionCategory.dresses,
        modelPath: 'assets/models/clothing/dresses/tunik_casual.glb',
        thumbnailPath: 'assets/images/dresses/tunik_casual_thumb.jpg',
        availableSizes: ['S', 'M', 'L', 'XL'],
        availableColors: [const Color(0xFFEC407A), const Color(0xFF689F38), const Color(0xFFFFF8E1), const Color(0xFFE1BEE7)],
        price: 165000,
        metadata: const {
          'material': 'Cotton Rayon',
          'brand': 'Vast Fashion',
          'style': 'Casual',
        },
      ),

      // Accessories
      FashionItem(
        id: 'acc_001',
        name: 'Bros Hijab Premium',
        description: 'Bros hijab dengan desain premium untuk melengkapi penampilan',
        category: FashionCategory.accessories,
        modelPath: 'assets/models/clothing/accessories/bros_premium.glb',
        thumbnailPath: 'assets/images/accessories/bros_premium_thumb.jpg',
        availableSizes: ['One Size'],
        availableColors: [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFE91E63)],
        price: 45000,
        metadata: const {
          'material': 'Alloy Premium',
          'brand': 'Vast Accessories',
          'type': 'Bros',
        },
      ),
    ];
  }

  // Get all fashion items
  List<FashionItem> getAllItems() {
    return List.unmodifiable(_fashionItems);
  }

  // Get items by category
  List<FashionItem> getItemsByCategory(FashionCategory category) {
    try {
      debugPrint('Getting items for category: $category');
      final items = _fashionItems
          .where((item) => item.category == category && item.isAvailable)
          .toList();
      debugPrint('Found ${items.length} items for category $category');
      return items;
    } catch (e) {
      debugPrint('Error getting items by category: $e');
      return [];
    }
  }

  // Get item by ID
  FashionItem? getItemById(String id) {
    try {
      return _fashionItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search items
  List<FashionItem> searchItems(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _fashionItems
        .where((item) => 
          item.name.toLowerCase().contains(lowercaseQuery) ||
          item.description.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Add custom item
  Future<void> addCustomItem(FashionItem item) async {
    _fashionItems.add(item);
    await _saveCustomItems();
  }

  // Remove item
  Future<void> removeItem(String id) async {
    _fashionItems.removeWhere((item) => item.id == id);
    await _saveCustomItems();
  }

  // Update item
  Future<void> updateItem(FashionItem updatedItem) async {
    final index = _fashionItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _fashionItems[index] = updatedItem;
      await _saveCustomItems();
    }
  }

  // Save custom items to local storage
  Future<void> _saveCustomItems() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/custom_fashion_items.json');
      
      // Only save custom items (not default ones)
      final customItems = _fashionItems
          .where((item) => !_isDefaultItem(item.id))
          .toList();
      
      final jsonList = customItems.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error saving custom items: $e');
    }
  }

  bool _isDefaultItem(String id) {
    final defaultIds = [
      'hijab_001', 'hijab_002', 'hijab_003',
      'dress_001', 'dress_002',
      'acc_001',
    ];
    return defaultIds.contains(id);
  }

  // Get categories with item counts
  Map<FashionCategory, int> getCategoryCounts() {
    final Map<FashionCategory, int> counts = {};
    
    for (final category in FashionCategory.values) {
      counts[category] = getItemsByCategory(category).length;
    }
    
    return counts;
  }

  // Get featured items
  List<FashionItem> getFeaturedItems({int limit = 6}) {
    return _fashionItems
        .where((item) => item.isAvailable)
        .take(limit)
        .toList();
  }

  // Get items by price range
  List<FashionItem> getItemsByPriceRange(double minPrice, double maxPrice) {
    return _fashionItems
        .where((item) => 
          item.isAvailable && 
          item.price >= minPrice && 
          item.price <= maxPrice)
        .toList();
  }

  // Get items by color
  List<FashionItem> getItemsByColor(Color color) {
    return _fashionItems
        .where((item) => 
          item.isAvailable && 
          item.availableColors.contains(color))
        .toList();
  }

  // Get items by size
  List<FashionItem> getItemsBySize(String size) {
    return _fashionItems
        .where((item) => 
          item.isAvailable && 
          item.availableSizes.contains(size))
        .toList();
  }

  // Refresh data
  Future<void> refresh() async {
    _fashionItems.clear();
    _isInitialized = false;
    await initialize();
  }

  // Check if item exists
  bool itemExists(String id) {
    return _fashionItems.any((item) => item.id == id);
  }

  // Get total items count
  int get totalItemsCount => _fashionItems.length;

  // Get available items count
  int get availableItemsCount => 
      _fashionItems.where((item) => item.isAvailable).length;
}