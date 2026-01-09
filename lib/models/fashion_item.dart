import 'package:flutter/material.dart';

enum FashionCategory {
  shirts,
  jackets, 
  dresses,
  hijabs,
  accessories,
}

enum FashionSize {
  xs,
  s,
  m,
  l,
  xl,
  xxl,
}

class FashionItem {
  final String id;
  final String name;
  final String description;
  final FashionCategory category;
  final String modelPath; // Path ke file GLB/GLTF
  final String thumbnailPath;
  final List<String> availableSizes;
  final List<Color> availableColors;
  final double price;
  final Map<String, dynamic> metadata;
  final bool isAvailable;

  const FashionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.modelPath,
    required this.thumbnailPath,
    required this.availableSizes,
    required this.availableColors,
    required this.price,
    this.metadata = const {},
    this.isAvailable = true,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'modelPath': modelPath,
      'thumbnailPath': thumbnailPath,
      'availableSizes': availableSizes,
      'availableColors': availableColors.map((c) => c.toARGB32()).toList(),
      'price': price,
      'metadata': metadata,
      'isAvailable': isAvailable,
    };
  }

  // Create from JSON
  factory FashionItem.fromJson(Map<String, dynamic> json) {
    return FashionItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: FashionCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      modelPath: json['modelPath'],
      thumbnailPath: json['thumbnailPath'],
      availableSizes: List<String>.from(json['availableSizes']),
      availableColors: (json['availableColors'] as List)
          .map((colorValue) => Color(colorValue as int))
          .toList(),
      price: json['price'].toDouble(),
      metadata: json['metadata'] ?? {},
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  FashionItem copyWith({
    String? id,
    String? name,
    String? description,
    FashionCategory? category,
    String? modelPath,
    String? thumbnailPath,
    List<String>? availableSizes,
    List<Color>? availableColors,
    double? price,
    Map<String, dynamic>? metadata,
    bool? isAvailable,
  }) {
    return FashionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      modelPath: modelPath ?? this.modelPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      availableSizes: availableSizes ?? this.availableSizes,
      availableColors: availableColors ?? this.availableColors,
      price: price ?? this.price,
      metadata: metadata ?? this.metadata,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FashionItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FashionItem(id: $id, name: $name, category: $category)';
  }
}