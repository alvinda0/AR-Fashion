import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../services/body_detection_service.dart';
import '../services/fashion_fitting_service.dart';
import '../models/fashion_item.dart';
import '../widgets/fashion_selector.dart';
import '../widgets/ar_overlay_widget.dart';
import '../services/fashion_data_service.dart';

class ARCameraScreen extends StatefulWidget {
  const ARCameraScreen({super.key});

  @override
  State<ARCameraScreen> createState() => _ARCameraScreenState();
}

class _ARCameraScreenState extends State<ARCameraScreen> {
  // Camera
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isUsingFrontCamera = true; // Default ke kamera depan untuk selfie
  
  // Services
  final BodyDetectionService _bodyDetectionService = BodyDetectionService();
  final FashionFittingService _fittingService = FashionFittingService();
  final FashionDataService _fashionDataService = FashionDataService();
  
  // State
  FashionItem? _selectedFashionItem;
  bool _isLoading = false;
  bool _showFashionSelector = false;
  bool _isModelVisible = true;
  bool _isManualControlMode = false; // New: Manual control toggle
  Map<PoseLandmarkType, Offset> _bodyLandmarks = {};
  vm.Matrix4 _transformMatrix = vm.Matrix4.identity(); // Add transform matrix
  String? _errorMessage;
  bool _mlKitEnabled = true; // Track if ML Kit is working

  @override
  void initState() {
    super.initState();
    debugPrint('ARCameraScreen: initState called');
    _initializeServices();
  }

  @override
  void dispose() {
    debugPrint('ARCameraScreen: dispose called');
    
    // Clear pose update callback to prevent memory leaks
    _bodyDetectionService.onPoseUpdate = null;
    
    _cameraController?.dispose();
    _bodyDetectionService.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔄 Starting AR Camera initialization...');
      
      // Step 1: Initialize camera first (most critical)
      debugPrint('� Step 1: Iinitializing camera...');
      await _initializeCamera();
      debugPrint('✅ Step 1 complete: Camera initialized');
      
      // Step 2: Initialize fashion data service
      debugPrint('� Stetp 2: Initializing fashion data service...');
      try {
        await _fashionDataService.initialize().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('⏰ Fashion data service timeout - using fallback');
            throw Exception('Fashion data service timeout');
          },
        );
        debugPrint('✅ Step 2 complete: Fashion data service initialized');
      } catch (e) {
        debugPrint('⚠️ Fashion data service failed: $e - continuing anyway');
      }
      
      // Step 3: Try to initialize ML Kit (optional)
      debugPrint('🤖 Step 3: Initializing ML Kit body detection...');
      try {
        await _bodyDetectionService.initialize().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('⏰ ML Kit timeout - continuing without body detection');
            throw Exception('ML Kit timeout');
          },
        );
        debugPrint('✅ Step 3 complete: Body detection service initialized');
        
        // Set up pose update callback only if ML Kit works
        _bodyDetectionService.onPoseUpdate = (landmarks) {
          if (mounted) {
            setState(() {
              _bodyLandmarks = landmarks;
            });
            
            if (_selectedFashionItem != null) {
              final fittingResult = _fittingService.fitItemToBody(
                _selectedFashionItem!,
                landmarks,
                MediaQuery.of(context).size,
              );
              
              setState(() {
                _transformMatrix = fittingResult;
              });
            }
          }
        };
        
      } catch (e) {
        debugPrint('⚠️ ML Kit failed: $e - continuing in manual mode only');
        setState(() {
          _mlKitEnabled = false;
        });
      }
      
      setState(() {
        _isLoading = false;
      });
      
      debugPrint('🎉 AR Camera initialization complete!');
      _showSnackBar('✅ AR Camera siap digunakan!');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Critical AR Camera initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Camera initialization failed: ${e.toString()}';
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      debugPrint('📷 Getting available cameras...');
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        throw Exception('No cameras available on this device');
      }

      debugPrint('📷 Found ${_cameras.length} cameras');
      await _setupCamera();
      
    } catch (e) {
      debugPrint('❌ Camera initialization failed: $e');
      throw Exception('Failed to initialize camera: $e');
    }
  }

  Future<void> _setupCamera() async {
    try {
      // Dispose existing controller if any
      await _cameraController?.dispose();

      // Select camera based on current preference
      CameraDescription selectedCamera;
      if (_isUsingFrontCamera) {
        selectedCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );
      } else {
        selectedCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );
      }

      debugPrint('📷 Setting up camera: ${selectedCamera.name} (${selectedCamera.lensDirection})');

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      debugPrint('📷 Initializing camera controller...');
      await _cameraController!.initialize();
      debugPrint('✅ Camera controller initialized');
      
      // Start image stream for pose detection only if ML Kit is enabled
      if (_mlKitEnabled) {
        debugPrint('🎥 Starting image stream for ML Kit...');
        _cameraController!.startImageStream((CameraImage image) {
          _bodyDetectionService.processImage(image);
        });
        debugPrint('✅ Image stream started');
      } else {
        debugPrint('⚠️ Skipping image stream - ML Kit disabled');
      }

      setState(() {
        _isCameraInitialized = true;
      });
      
    } catch (e) {
      debugPrint('❌ Camera setup failed: $e');
      throw Exception('Camera setup failed: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) {
      _showSnackBar('Hanya ada satu kamera tersedia');
      return;
    }

    setState(() {
      _isCameraInitialized = false;
      _isUsingFrontCamera = !_isUsingFrontCamera;
    });

    try {
      await _setupCamera();
      _showSnackBar(_isUsingFrontCamera ? 'Beralih ke kamera depan' : 'Beralih ke kamera belakang');
    } catch (e) {
      debugPrint('Error switching camera: $e');
      // Revert back if failed
      setState(() {
        _isUsingFrontCamera = !_isUsingFrontCamera;
      });
      _showSnackBar('Gagal beralih kamera: $e');
    }
  }

  void _onFashionItemSelected(FashionItem item) {
    try {
      debugPrint('Fashion item selected: ${item.name}');
      debugPrint('Model path: ${item.modelPath}');
      
      setState(() {
        _selectedFashionItem = item;
        _showFashionSelector = false;
        _isModelVisible = true;
      });

      // Fit item to current body landmarks if available
      if (_bodyLandmarks.isNotEmpty) {
        debugPrint('Fitting item to body landmarks');
        final fittingResult = _fittingService.fitItemToBody(
          item,
          _bodyLandmarks,
          MediaQuery.of(context).size,
        );
        
        // Update transform matrix for AR overlay
        setState(() {
          _transformMatrix = fittingResult;
        });
      } else {
        debugPrint('No body landmarks available yet - using default positioning');
        // Use default center positioning
        _transformMatrix = vm.Matrix4.identity();
        _transformMatrix.translate(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height / 2,
          0.0,
        );
      }

      _showSnackBar('${item.name} dipilih untuk AR try-on');
      
    } catch (e, stackTrace) {
      debugPrint('Error selecting fashion item: $e');
      debugPrint('Stack trace: $stackTrace');
      
      setState(() {
        _showFashionSelector = false;
        _errorMessage = 'Error loading fashion item: $e';
      });
      
      _showSnackBar('Error: Gagal memuat item fashion');
    }
  }

  void _toggleModelVisibility() {
    setState(() {
      _isModelVisible = !_isModelVisible;
    });
  }

  void _toggleManualControl() {
    setState(() {
      _isManualControlMode = !_isManualControlMode;
    });
    
    _showSnackBar(_isManualControlMode 
      ? 'Manual control enabled - Pinch to zoom, drag to move'
      : 'Auto tracking enabled - Model follows body');
  }

  void _clearScene() {
    setState(() {
      _selectedFashionItem = null;
      _isModelVisible = false;
      _isManualControlMode = false; // Reset manual control when clearing
    });
    _fittingService.clearFitting();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showItemInfo() {
    if (_selectedFashionItem == null) return;

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _selectedFashionItem!.name,
          style: TextStyle(fontSize: isTablet ? 20 : 18),
        ),
        content: SizedBox(
          width: isTablet ? 400 : double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedFashionItem!.description,
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              _buildInfoRow('Kategori', _getCategoryName(_selectedFashionItem!.category), isTablet),
              _buildInfoRow('Harga', 'Rp ${_formatPrice(_selectedFashionItem!.price)}', isTablet),
              SizedBox(height: isTablet ? 12 : 8),
              _buildInfoRow('Ukuran Tersedia', _selectedFashionItem!.availableSizes.join(', '), isTablet),
              SizedBox(height: isTablet ? 12 : 8),
              
              // Color indicators
              const Text('Warna Tersedia:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _selectedFashionItem!.availableColors.map((color) {
                  return Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 6 : 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.black87,
            fontSize: isTablet ? 15 : 13,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
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

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fashion AR Try-On',
          style: TextStyle(fontSize: isTablet ? 20 : 18),
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedFashionItem != null)
            IconButton(
              icon: Icon(Icons.clear, size: isTablet ? 28 : 24),
              onPressed: _clearScene,
              tooltip: 'Clear Scene',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing AR Camera...'),
                ],
              ),
            )
          else if (_errorMessage != null)
            _buildErrorView(isTablet)
          else if (_isCameraInitialized && _cameraController != null)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CameraPreview(_cameraController!),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Camera not available',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          // AR Overlay for 3D fashion items
          if (_selectedFashionItem != null && _isModelVisible && _isCameraInitialized)
            AROverlayWidget(
              fashionItem: _selectedFashionItem,
              transformMatrix: _transformMatrix,
              screenSize: MediaQuery.of(context).size,
              isVisible: _isModelVisible,
              isManualMode: _isManualControlMode,
              useModelViewer: true, // Set to true to try real ModelViewer for GLB files
            ),

          // Fashion selector overlay
          if (_showFashionSelector)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: FashionSelector(
                  onItemSelected: _onFashionItemSelected,
                ),
              ),
            ),

          // Control buttons
          if (_isCameraInitialized)
            _buildControlButtons(isTablet),

          // Selected item indicator
          if (_selectedFashionItem != null)
            _buildSelectedItemIndicator(isTablet),

          // Body tracking status
          _buildBodyTrackingStatus(isTablet),

          // Instructions
          if (!_showFashionSelector && _selectedFashionItem == null && _isCameraInitialized)
            _buildInstructions(isTablet),
        ],
      ),
    );
  }

  Widget _buildErrorView(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 80 : 64,
            color: Colors.red[300],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'AR Camera Error',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[300],
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          ElevatedButton(
            onPressed: _initializeServices,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 12 : 8,
              ),
              child: Text(
                'Retry',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(bool isTablet) {
    final buttonSize = isTablet ? 64.0 : 56.0;
    
    return Positioned(
      bottom: 20,
      left: isTablet ? 32 : 20,
      right: isTablet ? 32 : 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Fashion selector button
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: FloatingActionButton(
              heroTag: 'fashion_selector',
              onPressed: () {
                debugPrint('Fashion selector button pressed');
                setState(() => _showFashionSelector = true);
              },
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.checkroom,
                size: isTablet ? 32 : 24,
              ),
            ),
          ),
          
          // Camera switch button
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: FloatingActionButton(
              heroTag: 'camera_switch',
              onPressed: _cameras.length > 1 ? _switchCamera : null,
              backgroundColor: _cameras.length > 1 
                ? (_isUsingFrontCamera ? Colors.teal : Colors.indigo)
                : Colors.grey,
              child: Icon(
                _isUsingFrontCamera ? Icons.camera_front : Icons.camera_rear,
                size: isTablet ? 32 : 24,
              ),
            ),
          ),
          
          // Manual control button (if item selected)
          if (_selectedFashionItem != null)
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: FloatingActionButton(
                heroTag: 'manual_control',
                onPressed: _toggleManualControl,
                backgroundColor: _isManualControlMode ? Colors.purple : Colors.cyan,
                child: Icon(
                  _isManualControlMode ? Icons.pan_tool : Icons.control_camera,
                  size: isTablet ? 32 : 24,
                ),
              ),
            ),
          
          // Toggle visibility button (if item selected)
          if (_selectedFashionItem != null)
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: FloatingActionButton(
                heroTag: 'toggle_visibility',
                onPressed: _toggleModelVisibility,
                backgroundColor: _isModelVisible ? Colors.green : Colors.grey,
                child: Icon(
                  _isModelVisible ? Icons.visibility : Icons.visibility_off,
                  size: isTablet ? 32 : 24,
                ),
              ),
            ),
          
          // Item info button (if item selected)
          if (_selectedFashionItem != null)
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: FloatingActionButton(
                heroTag: 'item_info',
                onPressed: _showItemInfo,
                backgroundColor: Colors.orange,
                child: Icon(
                  Icons.info,
                  size: isTablet ? 32 : 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedItemIndicator(bool isTablet) {
    return Positioned(
      top: isTablet ? 24 : 20,
      left: isTablet ? 24 : 20,
      right: isTablet ? 24 : 20,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        ),
        child: Text(
          'AR Model: ${_selectedFashionItem!.name}',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBodyTrackingStatus(bool isTablet) {
    final isTracking = _bodyLandmarks.isNotEmpty && _mlKitEnabled;
    
    return Positioned(
      top: isTablet ? 80 : 70,
      right: isTablet ? 24 : 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Body tracking status
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 8,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: _mlKitEnabled 
                ? (isTracking ? Colors.green : Colors.orange)
                : Colors.red,
              borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _mlKitEnabled 
                    ? (isTracking ? Icons.person : Icons.person_search)
                    : Icons.person_off,
                  color: Colors.white,
                  size: isTablet ? 16 : 14,
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Text(
                  _mlKitEnabled 
                    ? (isTracking ? 'Body Detected' : 'Detecting...')
                    : 'Manual Only',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Camera status
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 8,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: _isUsingFrontCamera ? Colors.teal : Colors.indigo,
              borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isUsingFrontCamera ? Icons.camera_front : Icons.camera_rear,
                  color: Colors.white,
                  size: isTablet ? 16 : 14,
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Text(
                  _isUsingFrontCamera ? 'Front Cam' : 'Back Cam',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Manual control status (if item selected)
          if (_selectedFashionItem != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 8,
                vertical: isTablet ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color: _isManualControlMode ? Colors.purple : Colors.cyan,
                borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isManualControlMode ? Icons.pan_tool : Icons.control_camera,
                    color: Colors.white,
                    size: isTablet ? 16 : 14,
                  ),
                  SizedBox(width: isTablet ? 6 : 4),
                  Text(
                    _isManualControlMode ? 'Manual' : 'Auto Track',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 12 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructions(bool isTablet) {
    return Positioned(
      top: isTablet ? 120 : 100,
      left: isTablet ? 32 : 20,
      right: isTablet ? 32 : 20,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        ),
        child: Column(
          children: [
            Icon(
              Icons.view_in_ar,
              color: Colors.white,
              size: isTablet ? 40 : 32,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'Fashion AR Ready!',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 8 : 4),
            Text(
              'Pilih fashion item untuk mencoba virtual try-on dengan body tracking',
              style: TextStyle(
                color: Colors.white70,
                fontSize: isTablet ? 14 : 12,
              ),
              textAlign: TextAlign.center,
            ),
            if (_cameras.length > 1) ...[
              SizedBox(height: isTablet ? 12 : 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Colors.white60,
                    size: isTablet ? 16 : 14,
                  ),
                  SizedBox(width: isTablet ? 6 : 4),
                  Text(
                    'Tap kamera untuk beralih antara depan/belakang',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: isTablet ? 12 : 10,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}