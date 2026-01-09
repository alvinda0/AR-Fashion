import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class BodyDetectionService {
  static final BodyDetectionService _instance = BodyDetectionService._internal();
  factory BodyDetectionService() => _instance;
  BodyDetectionService._internal();

  late PoseDetector _poseDetector;
  bool _isInitialized = false;

  // Body landmarks untuk fashion fitting
  Map<PoseLandmarkType, Offset> _bodyLandmarks = {};
  
  // Callback untuk update pose
  Function(Map<PoseLandmarkType, Offset>)? onPoseUpdate;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('🤖 Initializing ML Kit PoseDetector...');
      
      final options = PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base, // Use base model for faster initialization
      );
      
      _poseDetector = PoseDetector(options: options);
      _isInitialized = true;
      
      debugPrint('✅ ML Kit PoseDetector initialized successfully');
    } catch (e) {
      debugPrint('❌ ML Kit initialization failed: $e');
      throw Exception('Failed to initialize ML Kit: $e');
    }
  }

  Future<void> processImage(CameraImage image) async {
    if (!_isInitialized) return;

    try {
      final inputImage = _convertCameraImage(image);
      final poses = await _poseDetector.processImage(inputImage);
      
      if (poses.isNotEmpty) {
        final pose = poses.first;
        _updateBodyLandmarks(pose);
        
        // Notify listeners
        if (onPoseUpdate != null) {
          onPoseUpdate!(_bodyLandmarks);
        }
      }
    } catch (e) {
      debugPrint('Error processing pose: $e');
    }
  }

  void _updateBodyLandmarks(Pose pose) {
    _bodyLandmarks.clear();
    
    // Key points untuk fashion fitting
    final keyPoints = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
      PoseLandmarkType.nose,
    ];

    for (final landmark in pose.landmarks.values) {
      if (keyPoints.contains(landmark.type)) {
        _bodyLandmarks[landmark.type] = Offset(
          landmark.x,
          landmark.y,
        );
      }
    }
  }

  InputImage _convertCameraImage(CameraImage image) {
    final BytesBuilder allBytes = BytesBuilder();
    for (final Plane plane in image.planes) {
      allBytes.add(plane.bytes);
    }
    final bytes = allBytes.toBytes();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    const InputImageRotation imageRotation = InputImageRotation.rotation0deg;
    const InputImageFormat inputImageFormat = InputImageFormat.nv21;

    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageData,
    );
  }

  // Get body measurements untuk sizing
  Map<String, double> getBodyMeasurements() {
    if (_bodyLandmarks.isEmpty) return {};

    final leftShoulder = _bodyLandmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = _bodyLandmarks[PoseLandmarkType.rightShoulder];
    final leftHip = _bodyLandmarks[PoseLandmarkType.leftHip];
    final rightHip = _bodyLandmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || 
        leftHip == null || rightHip == null) {
      return {};
    }

    // Calculate measurements
    final shoulderWidth = (rightShoulder.dx - leftShoulder.dx).abs();
    final hipWidth = (rightHip.dx - leftHip.dx).abs();
    final torsoHeight = ((leftShoulder.dy + rightShoulder.dy) / 2 - 
                        (leftHip.dy + rightHip.dy) / 2).abs();

    return {
      'shoulderWidth': shoulderWidth,
      'hipWidth': hipWidth,
      'torsoHeight': torsoHeight,
    };
  }

  void dispose() {
    if (_isInitialized) {
      _poseDetector.close();
      _isInitialized = false;
    }
  }
}