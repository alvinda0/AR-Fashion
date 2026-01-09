import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/fashion_item.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ARCameraV2 extends StatefulWidget {
  const ARCameraV2({super.key});

  @override
  State<ARCameraV2> createState() => _ARCameraV2State();
}

class _ARCameraV2State extends State<ARCameraV2> {
  // Camera
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isUsingFrontCamera = true;
  
  // State
  FashionItem? _selectedFashionItem;
  bool _isLoading = false;
  bool _showFashionSelector = false;
  bool _isModelVisible = true;
  vm.Matrix4 _transformMatrix = vm.Matrix4.identity();
  String? _errorMessage;
  List<FashionItem> _fashionItems = [];
  
  // Manual positioning
  Offset _modelPosition = const Offset(0, 0); // Relative to center
  double _modelScale = 1.0;
  
  // Gesture tracking
  double _baseScale = 1.0;
  Offset _baseOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    debugPrint('ARCameraV2: initState called');
    _initializeServices();
  }

  @override
  void dispose() {
    debugPrint('ARCameraV2: dispose called');
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔄 Starting AR Camera V2 initialization...');
      
      // Step 1: Initialize camera (we know this works)
      debugPrint('📷 Step 1: Initializing camera...');
      await _initializeCamera();
      debugPrint('✅ Step 1 complete: Camera working');
      
      // Step 2: Skip fashion data service - use hardcoded only
      debugPrint('📦 Step 2: Using hardcoded fashion items only...');
      _loadHardcodedItems();
      debugPrint('✅ Step 2 complete: ${_fashionItems.length} fashion items loaded');
      
      // Step 3: Set default transform for manual mode
      debugPrint('🎯 Step 3: Setting up manual mode...');
      _transformMatrix = vm.Matrix4.identity();
      _transformMatrix.translate(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
        0.0,
      );
      debugPrint('✅ Step 3 complete: Manual mode ready');
      
      setState(() {
        _isLoading = false;
      });
      
      debugPrint('🎉 AR Camera V2 ready!');
      _showSnackBar('✅ AR Camera ready - Manual mode');
      
    } catch (e, stackTrace) {
      debugPrint('❌ AR Camera V2 initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Initialization failed: ${e.toString()}';
      });
    }
  }

  void _loadHardcodedItems() {
    _fashionItems = [
      // PNG version - safe option
      FashionItem(
        id: 'dress_001_png',
        name: 'Gamis PNG Model',
        description: 'Gamis dengan model PNG untuk AR try-on yang stabil',
        category: FashionCategory.dresses,
        modelPath: 'assets/images/dresses/gamis.png', // Updated path
        thumbnailPath: 'assets/images/dresses/gamis.png', // Updated path
        availableSizes: ['S', 'M', 'L', 'XL'],
        availableColors: [Colors.purple, const Color(0xFF1565C0), const Color(0xFF8E24AA)],
        price: 285000,
        metadata: const {
          'material': 'PNG Image Model',
          'brand': 'Vast Fashion',
          'style': 'Safe PNG',
          'fileType': 'PNG',
          'isLocalAsset': true,
        },
      ),
      // GLB version - advanced option
      FashionItem(
        id: 'dress_001_glb',
        name: 'Gamis GLB 3D Model',
        description: 'Gamis dengan model GLB 3D (experimental)',
        category: FashionCategory.dresses,
        modelPath: 'assets/models/clothing/dresses/tes.glb',
        thumbnailPath: 'assets/images/dresses/gamis.png', // Updated path
        availableSizes: ['S', 'M', 'L', 'XL'],
        availableColors: [Colors.black, const Color(0xFF1565C0), const Color(0xFF8E24AA)],
        price: 285000,
        metadata: const {
          'material': 'GLB 3D Model',
          'brand': 'Vast Fashion',
          'style': 'Advanced 3D',
          'fileType': 'GLB',
          'fileSize': '18MB',
          'isLocalAsset': true,
        },
      ),
    ];
    debugPrint('Loaded ${_fashionItems.length} fashion items (PNG + GLB options)');
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
      await _cameraController?.dispose();

      final selectedCamera = _isUsingFrontCamera
          ? _cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      debugPrint('📷 Setting up camera: ${selectedCamera.name}');

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      setState(() {
        _isCameraInitialized = true;
      });
      
      debugPrint('✅ Camera setup complete');
      
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

  void _clearScene() {
    setState(() {
      _selectedFashionItem = null;
      _isModelVisible = false;
      _modelPosition = const Offset(0, 0);
      _modelScale = 1.0;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSafeAROverlay() {
    try {
      final screenSize = MediaQuery.of(context).size;
      final centerX = screenSize.width / 2;
      final centerY = screenSize.height / 2;
      
      return Positioned(
        left: centerX - 100 + _modelPosition.dx,
        top: centerY - 150 + _modelPosition.dy,
        child: GestureDetector(
          onScaleStart: (details) {
            // Store initial values for both pan and scale
            _baseScale = _modelScale;
            _baseOffset = _modelPosition;
          },
          onScaleUpdate: (details) {
            setState(() {
              // Handle scaling
              _modelScale = (_baseScale * details.scale).clamp(0.5, 2.0);
              
              // Handle panning (movement) - use focalPointDelta for movement
              if (details.scale == 1.0) {
                // Pure pan gesture
                _modelPosition = _baseOffset + details.focalPointDelta;
              } else {
                // Scale gesture with optional pan
                _modelPosition = _baseOffset + (details.focalPointDelta * 0.5);
              }
            });
          },
          onDoubleTap: () {
            setState(() {
              _modelPosition = const Offset(0, 0);
              _modelScale = 1.0;
            });
          },
          child: Transform.scale(
            scale: _modelScale,
            child: Container(
              width: 200,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main content based on file type
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 200,
                      height: 300,
                      child: _buildModelContent(),
                    ),
                  ),
                  
                  // Overlay gradient for better text visibility
                  Container(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                  
                  // File type indicator
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getFileTypeColor(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getFileTypeLabel(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Status indicator
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(),
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                  
                  // Item name overlay
                  Positioned(
                    bottom: 40,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _selectedFashionItem!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  
                  // Manual mode indicator
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Drag • Pinch • Double tap',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error building AR overlay: $e');
      return _buildErrorOverlay();
    }
  }

  Widget _buildModelContent() {
    final modelPath = _selectedFashionItem!.modelPath;
    
    if (modelPath.endsWith('.png') || modelPath.endsWith('.jpg') || modelPath.endsWith('.jpeg')) {
      // Handle image files (PNG/JPG)
      return _buildImageContent();
    } else if (modelPath.endsWith('.glb') || modelPath.endsWith('.gltf')) {
      // Handle GLB/GLTF files with safe fallback
      return _buildGLBContent();
    } else {
      // Unknown format
      return _buildFallbackContent();
    }
  }

  Widget _buildGLBContent() {
    // For GLB files, show a safe representation instead of ModelViewer
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedFashionItem!.availableColors.first.withValues(alpha: 0.8),
            _selectedFashionItem!.availableColors.first.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 4),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 6.28 * 2, // Double rotation for GLB
                  child: Icon(
                    Icons.view_in_ar,
                    size: 100,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              '3D GLB Model',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'tes.glb (18MB)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Safe Mode - No WebView',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFileTypeColor() {
    final modelPath = _selectedFashionItem!.modelPath;
    if (modelPath.endsWith('.png') || modelPath.endsWith('.jpg')) {
      return Colors.green.withValues(alpha: 0.9);
    } else if (modelPath.endsWith('.glb') || modelPath.endsWith('.gltf')) {
      return Colors.orange.withValues(alpha: 0.9);
    }
    return Colors.grey.withValues(alpha: 0.9);
  }

  String _getFileTypeLabel() {
    final modelPath = _selectedFashionItem!.modelPath;
    if (modelPath.endsWith('.png')) return 'PNG';
    if (modelPath.endsWith('.jpg') || modelPath.endsWith('.jpeg')) return 'JPG';
    if (modelPath.endsWith('.glb')) return 'GLB';
    if (modelPath.endsWith('.gltf')) return 'GLTF';
    return 'UNK';
  }

  IconData _getStatusIcon() {
    final modelPath = _selectedFashionItem!.modelPath;
    if (modelPath.endsWith('.png') || modelPath.endsWith('.jpg')) {
      return Icons.image;
    } else if (modelPath.endsWith('.glb') || modelPath.endsWith('.gltf')) {
      return Icons.view_in_ar;
    }
    return Icons.help;
  }

  Widget _buildErrorOverlay() {
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - 50,
      top: MediaQuery.of(context).size.height / 2 - 25,
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Error',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    try {
      // Try to load the PNG image from the correct path
      final imagePath = _selectedFashionItem!.modelPath;
      debugPrint('Trying to load image from: $imagePath');
      
      return Image.asset(
        imagePath,
        width: 200,
        height: 300,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image from $imagePath: $error');
          // Fallback to gradient with icon if image fails
          return _buildFallbackContent();
        },
      );
    } catch (e) {
      debugPrint('Exception loading image: $e');
      return _buildFallbackContent();
    }
  }

  Widget _buildFallbackContent() {
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedFashionItem!.availableColors.first.withValues(alpha: 0.7),
            _selectedFashionItem!.availableColors.first.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 3),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 6.28, // Full rotation
                  child: Icon(
                    Icons.checkroom,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Gamis Model',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Image Fallback',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fashion AR Try-On V2',
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
                  Text('Initializing AR Camera V2...'),
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

          // AR Overlay for 3D fashion items - SAFE VERSION
          if (_selectedFashionItem != null && _isModelVisible && _isCameraInitialized)
            _buildSafeAROverlay(),

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
                child: _buildFashionSelector(),
              ),
            ),

          // Control buttons
          if (_isCameraInitialized)
            _buildControlButtons(isTablet),

          // Selected item indicator
          if (_selectedFashionItem != null)
            _buildSelectedItemIndicator(isTablet),

          // Status indicators
          _buildStatusIndicators(isTablet),

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

  Widget _buildFashionSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pilih Fashion Item',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _fashionItems.length,
              itemBuilder: (context, index) {
                final item = _fashionItems[index];
                return GestureDetector(
                  onTap: () => _onFashionItemSelected(item),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Try to show thumbnail image, fallback to icon
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            child: Image.asset(
                              item.thumbnailPath,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.checkroom,
                                  size: 40,
                                  color: item.availableColors.first,
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showFashionSelector = false;
              });
            },
            child: const Text('Tutup'),
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

  Widget _buildStatusIndicators(bool isTablet) {
    return Positioned(
      top: isTablet ? 80 : 70,
      right: isTablet ? 24 : 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Manual mode indicator
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 8,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pan_tool,
                  color: Colors.white,
                  size: isTablet ? 16 : 14,
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Text(
                  'Manual Mode',
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
              'Pilih fashion item untuk mencoba virtual try-on dalam mode manual',
              style: TextStyle(
                color: Colors.white70,
                fontSize: isTablet ? 14 : 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}