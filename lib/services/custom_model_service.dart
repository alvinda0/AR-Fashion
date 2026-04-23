import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CustomModel {
  final String id;
  final String name;
  final String filePath;
  final String? imagePath;
  final DateTime uploadedAt;

  CustomModel({
    required this.id,
    required this.name,
    required this.filePath,
    this.imagePath,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filePath': filePath,
      'imagePath': imagePath,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory CustomModel.fromJson(Map<String, dynamic> json) {
    return CustomModel(
      id: json['id'],
      name: json['name'],
      filePath: json['filePath'],
      imagePath: json['imagePath'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}

class CustomModelService {
  static const String _storageKey = 'custom_models';
  
  Future<List<CustomModel>> getCustomModels() async {
    final prefs = await SharedPreferences.getInstance();
    final modelsJson = prefs.getString(_storageKey);
    
    if (modelsJson == null) {
      return [];
    }
    
    final List<dynamic> modelsList = json.decode(modelsJson);
    return modelsList.map((json) => CustomModel.fromJson(json)).toList();
  }
  
  Future<void> saveCustomModel(CustomModel model) async {
    final models = await getCustomModels();
    models.add(model);
    
    final prefs = await SharedPreferences.getInstance();
    final modelsJson = json.encode(models.map((m) => m.toJson()).toList());
    await prefs.setString(_storageKey, modelsJson);
  }
  
  Future<void> deleteCustomModel(String id) async {
    final models = await getCustomModels();
    final model = models.firstWhere((m) => m.id == id);
    
    // Delete the files
    try {
      final modelFile = File(model.filePath);
      if (await modelFile.exists()) {
        await modelFile.delete();
      }
      
      if (model.imagePath != null) {
        final imageFile = File(model.imagePath!);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
    } catch (e) {
      print('Error deleting files: $e');
    }
    
    // Remove from list
    models.removeWhere((m) => m.id == id);
    
    final prefs = await SharedPreferences.getInstance();
    final modelsJson = json.encode(models.map((m) => m.toJson()).toList());
    await prefs.setString(_storageKey, modelsJson);
  }
  
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
