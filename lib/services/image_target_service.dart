import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class ImageTarget {
  final int? id;
  final String name;
  final String imageTarget;
  final String? modelUrl;
  final String? description;
  final DateTime? createdAt;

  ImageTarget({
    this.id,
    required this.name,
    required this.imageTarget,
    this.modelUrl,
    this.description,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'image_target': imageTarget,
      if (modelUrl != null) 'model_url': modelUrl,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory ImageTarget.fromJson(Map<String, dynamic> json) {
    return ImageTarget(
      id: json['id'],
      name: json['name'],
      imageTarget: json['image_target'],
      modelUrl: json['model_url'],
      description: json['description'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
}

class ImageTargetService {
  SupabaseClient get _supabase {
    if (!SupabaseConfig.isInitialized) {
      throw Exception('Supabase not initialized. Please check your internet connection and restart the app.');
    }
    return SupabaseConfig.client;
  }
  
  // Get all image targets from Supabase
  Future<List<ImageTarget>> getImageTargets() async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception('Supabase not initialized');
      }
      
      final response = await _supabase
          .from('image_target')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => ImageTarget.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching image targets: $e');
      rethrow;
    }
  }
  
  // Upload image to Supabase Storage
  Future<String> uploadImageToSupabase(File file, String fileName) async {
    try {
      final bytes = await file.readAsBytes();
      final filePath = 'image_targets/$fileName';
      
      await _supabase.storage
          .from('image_target') // Changed from 'images' to 'image_target'
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
            ),
          );
      
      final publicUrl = _supabase.storage
          .from('image_target') // Changed from 'images' to 'image_target'
          .getPublicUrl(filePath);
      
      return publicUrl;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      rethrow;
    }
  }
  
  // Save image target to database
  Future<void> saveImageTarget(ImageTarget imageTarget) async {
    try {
      await _supabase
          .from('image_target')
          .insert(imageTarget.toJson());
    } catch (e) {
      print('Error saving image target: $e');
      rethrow;
    }
  }
  
  // Delete image target
  Future<void> deleteImageTarget(int id, String imageUrl) async {
    try {
      // Delete from storage
      if (imageUrl.isNotEmpty) {
        final path = _extractPathFromUrl(imageUrl);
        if (path.isNotEmpty) {
          await _supabase.storage
              .from('image_target') // Changed from 'images' to 'image_target'
              .remove([path]);
        }
      }
      
      // Delete from database
      await _supabase
          .from('image_target')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting image target: $e');
      rethrow;
    }
  }
  
  String _extractPathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf('object');
      if (bucketIndex != -1 && bucketIndex + 2 < segments.length) {
        return segments.sublist(bucketIndex + 2).join('/');
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
