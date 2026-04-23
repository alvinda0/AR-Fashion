import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../config/supabase_config.dart';

class CustomModel {
  final String id;
  final String name;
  final String filePath;
  final String? imageTargetPath;
  final String? supabaseModelUrl;
  final String? supabaseImageUrl;
  final DateTime uploadedAt;
  final int? fileSize;
  final String? description;

  CustomModel({
    required this.id,
    required this.name,
    required this.filePath,
    this.imageTargetPath,
    this.supabaseModelUrl,
    this.supabaseImageUrl,
    required this.uploadedAt,
    this.fileSize,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'file_path': filePath,
      'image_target_path': imageTargetPath,
      'supabase_model_url': supabaseModelUrl,
      'supabase_image_url': supabaseImageUrl,
      'uploaded_at': uploadedAt.toIso8601String(),
      'file_size': fileSize,
      'description': description,
    };
  }

  factory CustomModel.fromJson(Map<String, dynamic> json) {
    return CustomModel(
      id: json['id'],
      name: json['name'],
      filePath: json['file_path'] ?? json['filePath'] ?? '',
      imageTargetPath: json['image_target_path'] ?? json['imageTargetPath'],
      supabaseModelUrl: json['supabase_model_url'] ?? json['supabaseModelUrl'],
      supabaseImageUrl: json['supabase_image_url'] ?? json['supabaseImageUrl'],
      uploadedAt: DateTime.parse(json['uploaded_at'] ?? json['uploadedAt']),
      fileSize: json['file_size'] ?? json['fileSize'],
      description: json['description'],
    );
  }
}

class CustomModelService {
  static const String _storageKey = 'custom_models';
  
  SupabaseClient get _supabase {
    if (!SupabaseConfig.isInitialized) {
      throw Exception('Supabase not initialized. Please check your internet connection and restart the app.');
    }
    return SupabaseConfig.client;
  }
  
  // Get models from Supabase
  Future<List<CustomModel>> getCustomModels() async {
    try {
      if (!SupabaseConfig.isInitialized) {
        print('⚠️ Supabase not initialized, using local storage');
        return _getLocalModels();
      }
      
      final response = await _supabase
          .from(SupabaseConfig.modelsTable)
          .select()
          .order('uploaded_at', ascending: false);
      
      return (response as List)
          .map((json) => CustomModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching from Supabase: $e');
      // Fallback to local storage
      return _getLocalModels();
    }
  }
  
  // Fallback: Get models from local storage
  Future<List<CustomModel>> _getLocalModels() async {
    final prefs = await SharedPreferences.getInstance();
    final modelsJson = prefs.getString(_storageKey);
    
    if (modelsJson == null) {
      return [];
    }
    
    final List<dynamic> modelsList = json.decode(modelsJson);
    return modelsList.map((json) => CustomModel.fromJson(json)).toList();
  }
  
  // Upload model file to Supabase Storage
  Future<String> uploadModelToSupabase(File file, String fileName) async {
    try {
      final bytes = await file.readAsBytes();
      final filePath = 'models/$fileName';
      
      await _supabase.storage
          .from(SupabaseConfig.modelsBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
            ),
          );
      
      final publicUrl = _supabase.storage
          .from(SupabaseConfig.modelsBucket)
          .getPublicUrl(filePath);
      
      return publicUrl;
    } catch (e) {
      print('Error uploading model to Supabase: $e');
      rethrow;
    }
  }
  
  // Upload image target to Supabase Storage
  Future<String> uploadImageToSupabase(File file, String fileName) async {
    try {
      final bytes = await file.readAsBytes();
      final filePath = 'images/$fileName';
      
      await _supabase.storage
          .from(SupabaseConfig.imagesBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
            ),
          );
      
      final publicUrl = _supabase.storage
          .from(SupabaseConfig.imagesBucket)
          .getPublicUrl(filePath);
      
      return publicUrl;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      rethrow;
    }
  }
  
  // Save model to Supabase database
  Future<void> saveCustomModel(CustomModel model) async {
    try {
      // Save to Supabase
      await _supabase
          .from(SupabaseConfig.modelsTable)
          .insert(model.toJson());
      
      // Also save to local storage as backup
      await _saveLocalModel(model);
    } catch (e) {
      print('Error saving to Supabase: $e');
      // Fallback to local storage only
      await _saveLocalModel(model);
    }
  }
  
  // Fallback: Save to local storage
  Future<void> _saveLocalModel(CustomModel model) async {
    final models = await _getLocalModels();
    models.add(model);
    
    final prefs = await SharedPreferences.getInstance();
    final modelsJson = json.encode(models.map((m) => m.toJson()).toList());
    await prefs.setString(_storageKey, modelsJson);
  }
  
  // Delete model from Supabase
  Future<void> deleteCustomModel(String id) async {
    try {
      // Get model info first
      final models = await getCustomModels();
      final model = models.firstWhere((m) => m.id == id);
      
      // Delete from Supabase Storage
      if (model.supabaseModelUrl != null) {
        final modelPath = _extractPathFromUrl(model.supabaseModelUrl!);
        await _supabase.storage
            .from(SupabaseConfig.modelsBucket)
            .remove([modelPath]);
      }
      
      if (model.supabaseImageUrl != null) {
        final imagePath = _extractPathFromUrl(model.supabaseImageUrl!);
        await _supabase.storage
            .from(SupabaseConfig.imagesBucket)
            .remove([imagePath]);
      }
      
      // Delete from database
      await _supabase
          .from(SupabaseConfig.modelsTable)
          .delete()
          .eq('id', id);
      
      // Delete local files
      await _deleteLocalFiles(model);
      
      // Delete from local storage
      await _deleteLocalModel(id);
    } catch (e) {
      print('Error deleting from Supabase: $e');
      // Try to delete locally anyway
      final models = await _getLocalModels();
      final model = models.firstWhere((m) => m.id == id);
      await _deleteLocalFiles(model);
      await _deleteLocalModel(id);
    }
  }
  
  String _extractPathFromUrl(String url) {
    // Extract path from Supabase public URL
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf('object');
    if (bucketIndex != -1 && bucketIndex + 2 < segments.length) {
      return segments.sublist(bucketIndex + 2).join('/');
    }
    return '';
  }
  
  Future<void> _deleteLocalFiles(CustomModel model) async {
    try {
      final modelFile = File(model.filePath);
      if (await modelFile.exists()) {
        await modelFile.delete();
      }
      
      if (model.imageTargetPath != null) {
        final imageFile = File(model.imageTargetPath!);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
    } catch (e) {
      print('Error deleting local files: $e');
    }
  }
  
  Future<void> _deleteLocalModel(String id) async {
    final models = await _getLocalModels();
    models.removeWhere((m) => m.id == id);
    
    final prefs = await SharedPreferences.getInstance();
    final modelsJson = json.encode(models.map((m) => m.toJson()).toList());
    await prefs.setString(_storageKey, modelsJson);
  }
  
  // Copy file to local app directory
  Future<String> copyFileToAppDirectory(File file, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${appDir.path}/custom_models');
    
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    
    final newPath = '${modelsDir.path}/$fileName';
    final newFile = await file.copy(newPath);
    return newFile.path;
  }
}
