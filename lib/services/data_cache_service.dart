import 'package:flutter/foundation.dart';
import 'image_target_service.dart';
import 'custom_model_service.dart';
import '../config/supabase_config.dart';

/// Service untuk caching data dari Supabase
/// Data di-fetch sekali saat app start, kemudian disimpan di memory
class DataCacheService {
  static final DataCacheService _instance = DataCacheService._internal();
  factory DataCacheService() => _instance;
  DataCacheService._internal();

  final ImageTargetService _imageTargetService = ImageTargetService();
  final CustomModelService _customModelService = CustomModelService();
  
  // Cached data
  List<ImageTarget>? _cachedImageTargets;
  List<String>? _cachedModels;
  List<CustomModel>? _cachedCustomModels;
  List<Map<String, String>>? _cachedFashionModels;
  DateTime? _lastFetchTime;
  
  // Loading states
  bool _isFetching = false;
  bool _hasFetchedOnce = false;
  
  // Getters
  List<ImageTarget> get imageTargets => _cachedImageTargets ?? [];
  List<String> get models => _cachedModels ?? [];
  List<CustomModel> get customModels => _cachedCustomModels ?? [];
  List<Map<String, String>> get fashionModels => _cachedFashionModels ?? [];
  bool get hasCachedData => _cachedImageTargets != null;
  bool get hasCustomModels => _cachedCustomModels != null;
  bool get hasFashionModels => _cachedFashionModels != null;
  bool get isFetching => _isFetching;
  bool get hasFetchedOnce => _hasFetchedOnce;
  DateTime? get lastFetchTime => _lastFetchTime;
  
  /// Pre-fetch semua data dari Supabase
  /// Dipanggil saat aplikasi start di main.dart
  Future<void> preFetchData() async {
    if (_isFetching) {
      debugPrint('⏳ Data fetch already in progress, skipping...');
      return;
    }
    
    _isFetching = true;
    debugPrint('🔄 Starting data pre-fetch...');
    
    try {
      if (!SupabaseConfig.isInitialized) {
        debugPrint('⚠️ Supabase not initialized, skipping pre-fetch');
        _isFetching = false;
        return;
      }
      
      // Fetch image targets
      debugPrint('📥 Fetching image targets...');
      final imageTargets = await _imageTargetService.getImageTargets();
      _cachedImageTargets = imageTargets;
      debugPrint('✅ Cached ${imageTargets.length} image targets');
      
      // Fetch available models
      debugPrint('📥 Fetching available models...');
      final models = await _fetchAvailableModels();
      _cachedModels = models;
      debugPrint('✅ Cached ${models.length} models');
      
      // Fetch custom models
      debugPrint('📥 Fetching custom models...');
      final customModels = await _customModelService.getCustomModels();
      _cachedCustomModels = customModels;
      debugPrint('✅ Cached ${customModels.length} custom models');
      
      // Fetch fashion models
      debugPrint('📥 Fetching fashion models...');
      final fashionModels = await _fetchFashionModels();
      _cachedFashionModels = fashionModels;
      debugPrint('✅ Cached ${fashionModels.length} fashion models');
      
      _lastFetchTime = DateTime.now();
      _hasFetchedOnce = true;
      
      debugPrint('✅ Data pre-fetch completed successfully');
      debugPrint('📊 Cache summary:');
      debugPrint('   - Image Targets: ${_cachedImageTargets?.length ?? 0}');
      debugPrint('   - Models: ${_cachedModels?.length ?? 0}');
      debugPrint('   - Custom Models: ${_cachedCustomModels?.length ?? 0}');
      debugPrint('   - Fashion Models: ${_cachedFashionModels?.length ?? 0}');
      debugPrint('   - Last Fetch: $_lastFetchTime');
      
    } catch (e) {
      debugPrint('❌ Error during data pre-fetch: $e');
      // Don't throw, just log - app should continue even if pre-fetch fails
    } finally {
      _isFetching = false;
    }
  }
  
  /// Refresh data dari Supabase
  /// Dipanggil manual ketika user ingin refresh data
  Future<void> refreshData() async {
    debugPrint('🔄 Refreshing cached data...');
    await preFetchData();
  }
  
  /// Fetch available models dari Supabase storage
  Future<List<String>> _fetchAvailableModels() async {
    try {
      if (!SupabaseConfig.isInitialized) {
        return [];
      }
      
      final files = await SupabaseConfig.client.storage
          .from('ar-fashion-glb')
          .list();
      
      final models = files
          .where((file) => file.name.endsWith('.glb'))
          .map((file) {
            final url = SupabaseConfig.client.storage
                .from('ar-fashion-glb')
                .getPublicUrl(file.name);
            return url;
          })
          .toList();
      
      return models;
    } catch (e) {
      debugPrint('❌ Error fetching models: $e');
      return [];
    }
  }
  
  /// Fetch fashion models dari Supabase storage
  Future<List<Map<String, String>>> _fetchFashionModels() async {
    try {
      if (!SupabaseConfig.isInitialized) {
        return [];
      }
      
      final files = await SupabaseConfig.client.storage
          .from('ar-fashion-glb')
          .list();
      
      final models = files
          .where((file) => file.name.endsWith('.glb'))
          .map((file) {
            final url = SupabaseConfig.client.storage
                .from('ar-fashion-glb')
                .getPublicUrl(file.name);
            
            // Format display name
            final displayName = file.name
                .replaceAll('.glb', '')
                .replaceAll('_', ' ')
                .split(' ')
                .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
                .join(' ');
            
            return {
              'name': displayName,
              'fileName': file.name,
              'url': url,
              'size': file.metadata?['size']?.toString() ?? '0',
            };
          })
          .toList();
      
      return models;
    } catch (e) {
      debugPrint('❌ Error fetching fashion models: $e');
      return [];
    }
  }
  
  /// Clear cache
  void clearCache() {
    debugPrint('🗑️ Clearing cache...');
    _cachedImageTargets = null;
    _cachedModels = null;
    _cachedCustomModels = null;
    _cachedFashionModels = null;
    _lastFetchTime = null;
    _hasFetchedOnce = false;
    debugPrint('✅ Cache cleared');
  }
  
  /// Add new image target to cache
  void addImageTargetToCache(ImageTarget target) {
    if (_cachedImageTargets != null) {
      _cachedImageTargets!.insert(0, target);
      debugPrint('✅ Added new image target to cache: ${target.name}');
    }
  }
  
  /// Remove image target from cache
  void removeImageTargetFromCache(int id) {
    if (_cachedImageTargets != null) {
      _cachedImageTargets!.removeWhere((target) => target.id == id);
      debugPrint('✅ Removed image target from cache: $id');
    }
  }
  
  /// Add new custom model to cache
  void addCustomModelToCache(CustomModel model) {
    if (_cachedCustomModels != null) {
      _cachedCustomModels!.insert(0, model);
      debugPrint('✅ Added new custom model to cache: ${model.name}');
    }
  }
  
  /// Remove custom model from cache
  void removeCustomModelFromCache(String id) {
    if (_cachedCustomModels != null) {
      _cachedCustomModels!.removeWhere((model) => model.id == id);
      debugPrint('✅ Removed custom model from cache: $id');
    }
  }
  
  /// Remove fashion model from cache
  void removeFashionModelFromCache(String fileName) {
    if (_cachedFashionModels != null) {
      _cachedFashionModels!.removeWhere((model) => model['fileName'] == fileName);
      debugPrint('✅ Removed fashion model from cache: $fileName');
    }
  }
  
  /// Check if cache is stale (older than specified duration)
  bool isCacheStale({Duration maxAge = const Duration(minutes: 30)}) {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) > maxAge;
  }
}
