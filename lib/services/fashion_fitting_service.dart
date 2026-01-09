import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:google_ml_kit/google_ml_kit.dart';
import '../models/fashion_item.dart';

class FashionFittingService {
  static final FashionFittingService _instance = FashionFittingService._internal();
  factory FashionFittingService() => _instance;
  FashionFittingService._internal();

  // Current fitted item
  FashionItem? _currentItem;
  
  // 3D transformation matrix
  vm.Matrix4 _transformMatrix = vm.Matrix4.identity();
  
  // Body measurements
  Map<String, double> _bodyMeasurements = {};

  // Fit fashion item to body
  vm.Matrix4 fitItemToBody(
    FashionItem item, 
    Map<PoseLandmarkType, Offset> bodyLandmarks,
    Size screenSize,
  ) {
    try {
      debugPrint('Fitting item to body: ${item.name}');
      _currentItem = item;
      _calculateTransformation(item, bodyLandmarks, screenSize);
      debugPrint('Item fitting completed successfully');
      return _transformMatrix;
    } catch (e, stackTrace) {
      debugPrint('Error fitting item to body: $e');
      debugPrint('Stack trace: $stackTrace');
      // Reset to safe state
      _currentItem = null;
      _transformMatrix = vm.Matrix4.identity();
      return _transformMatrix;
    }
  }

  void _calculateTransformation(
    FashionItem item,
    Map<PoseLandmarkType, Offset> bodyLandmarks,
    Size screenSize,
  ) {
    try {
      // Reset transformation
      _transformMatrix = vm.Matrix4.identity();

      debugPrint('Calculating transformation for category: ${item.category}');

      switch (item.category) {
        case FashionCategory.shirts:
          _fitShirt(bodyLandmarks, screenSize);
          break;
        case FashionCategory.jackets:
          _fitJacket(bodyLandmarks, screenSize);
          break;
        case FashionCategory.dresses:
          _fitDress(bodyLandmarks, screenSize);
          break;
        case FashionCategory.hijabs:
          _fitHijab(bodyLandmarks, screenSize);
          break;
        case FashionCategory.accessories:
          _fitAccessory(bodyLandmarks, screenSize);
          break;
      }
      
      debugPrint('Transformation calculated successfully');
    } catch (e, stackTrace) {
      debugPrint('Error calculating transformation: $e');
      debugPrint('Stack trace: $stackTrace');
      // Reset to identity matrix on error
      _transformMatrix = vm.Matrix4.identity();
    }
  }

  void _fitShirt(Map<PoseLandmarkType, Offset> landmarks, Size screenSize) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final nose = landmarks[PoseLandmarkType.nose];

    if (leftShoulder == null || rightShoulder == null || nose == null) return;

    // Calculate shirt position and scale
    final centerX = (leftShoulder.dx + rightShoulder.dx) / 2;
    final centerY = nose.dy + 50; // Offset from nose
    
    final shoulderWidth = (rightShoulder.dx - leftShoulder.dx).abs();
    final scale = shoulderWidth / 200; // Base shirt width = 200px

    // Apply transformation
    _transformMatrix.translateByVector3(vm.Vector3(centerX, centerY, 0));
    _transformMatrix.scaleByVector3(vm.Vector3(scale, scale, 1.0));
  }

  void _fitJacket(Map<PoseLandmarkType, Offset> landmarks, Size screenSize) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final nose = landmarks[PoseLandmarkType.nose];

    if (leftShoulder == null || rightShoulder == null || nose == null) return;

    // Jacket is slightly larger than shirt
    final centerX = (leftShoulder.dx + rightShoulder.dx) / 2;
    final centerY = nose.dy + 40;
    
    final shoulderWidth = (rightShoulder.dx - leftShoulder.dx).abs();
    final scale = (shoulderWidth * 1.1) / 220; // Jacket is 10% wider

    _transformMatrix.translateByVector3(vm.Vector3(centerX, centerY, 0));
    _transformMatrix.scaleByVector3(vm.Vector3(scale, scale, 1.0));
  }

  void _fitDress(Map<PoseLandmarkType, Offset> landmarks, Size screenSize) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final nose = landmarks[PoseLandmarkType.nose];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || 
        nose == null || leftHip == null || rightHip == null) return;

    final centerX = (leftShoulder.dx + rightShoulder.dx) / 2;
    final centerY = nose.dy + 30;
    
    final shoulderWidth = (rightShoulder.dx - leftShoulder.dx).abs();
    final hipWidth = (rightHip.dx - leftHip.dx).abs();
    final avgWidth = (shoulderWidth + hipWidth) / 2;
    
    // Special handling for tes.glb - larger scale for better visibility
    double scale;
    double heightMultiplier;
    
    if (_currentItem?.name.contains('Tes Custom') == true) {
      scale = avgWidth / 200; // Larger scale for custom model
      heightMultiplier = 2.0; // Taller for gamis
    } else {
      scale = avgWidth / 250; // Default scale
      heightMultiplier = 1.5;
    }

    _transformMatrix.translateByVector3(vm.Vector3(centerX, centerY, 0));
    _transformMatrix.scaleByVector3(vm.Vector3(scale, scale * heightMultiplier, 1.0));
  }

  void _fitHijab(Map<PoseLandmarkType, Offset> landmarks, Size screenSize) {
    final nose = landmarks[PoseLandmarkType.nose];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if (nose == null || leftShoulder == null || rightShoulder == null) return;

    // Hijab covers head and shoulders
    final centerX = nose.dx;
    final centerY = nose.dy - 80; // Above head
    
    final shoulderWidth = (rightShoulder.dx - leftShoulder.dx).abs();
    final scale = (shoulderWidth * 1.3) / 300; // Cover shoulders

    _transformMatrix.translateByVector3(vm.Vector3(centerX, centerY, 0));
    _transformMatrix.scaleByVector3(vm.Vector3(scale, scale, 1.0));
  }

  void _fitAccessory(Map<PoseLandmarkType, Offset> landmarks, Size screenSize) {
    final nose = landmarks[PoseLandmarkType.nose];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if (nose == null || leftShoulder == null || rightShoulder == null) return;

    // Accessory positioned near hijab area
    final centerX = nose.dx + 30; // Slightly to the side
    final centerY = nose.dy - 20;
    
    final scale = 0.5; // Small accessory

    _transformMatrix.translateByVector3(vm.Vector3(centerX, centerY, 0));
    _transformMatrix.scaleByVector3(vm.Vector3(scale, scale, 1.0));
  }

  // Get current transformation matrix
  vm.Matrix4 get transformMatrix => _transformMatrix;

  // Get fitted item
  FashionItem? get currentItem => _currentItem;

  // Update body measurements
  void updateBodyMeasurements(Map<String, double> measurements) {
    _bodyMeasurements = measurements;
  }

  // Get recommended size based on body measurements
  String getRecommendedSize() {
    if (_bodyMeasurements.isEmpty) return 'M';

    final shoulderWidth = _bodyMeasurements['shoulderWidth'] ?? 0;
    
    if (shoulderWidth < 100) return 'S';
    if (shoulderWidth < 120) return 'M';
    if (shoulderWidth < 140) return 'L';
    return 'XL';
  }

  // Check if item fits well
  bool isGoodFit() {
    if (_currentItem == null || _bodyMeasurements.isEmpty) return false;
    
    final recommendedSize = getRecommendedSize();
    return _currentItem!.availableSizes.contains(recommendedSize);
  }

  void clearFitting() {
    _currentItem = null;
    _transformMatrix = vm.Matrix4.identity();
  }
}