import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase Project Configuration
  static const String supabaseUrl = 'https://qerzhadqtgkckrejxcqg.supabase.co';
  
  // Legacy anon public key (correct format)
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFlcnpoYWRxdGdrY2tyZWp4Y3FnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxNzkxODUsImV4cCI6MjA4Nzc1NTE4NX0.bGGLCJXhRk0pZF1LD3JeO2WoAvgCYrluffaTuuN-Mjw';
  
  // Storage bucket names
  static const String modelsBucket = 'models';
  static const String imagesBucket = 'image_target'; // Changed from 'images' to 'image_target'
  
  // Table names
  static const String modelsTable = 'custom_models';
  static const String imageTargetsTable = 'image_targets';
  
  static bool _isInitialized = false;
  
  static bool get isInitialized => _isInitialized;
  
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ Supabase already initialized');
      return;
    }
    
    try {
      print('🔄 Initializing Supabase...');
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _isInitialized = true;
      print('✅ Supabase initialized successfully');
      print('📍 URL: $supabaseUrl');
    } catch (e) {
      print('❌ Failed to initialize Supabase: $e');
      rethrow;
    }
  }
  
  static SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call SupabaseConfig.initialize() first.');
    }
    return Supabase.instance.client;
  }
}
