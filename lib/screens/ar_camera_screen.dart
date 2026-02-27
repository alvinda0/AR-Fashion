import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ARCameraScreen extends StatefulWidget {
  const ARCameraScreen({super.key});

  @override
  State<ARCameraScreen> createState() => _ARCameraScreenState();
}

class _ARCameraScreenState extends State<ARCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isLoading = true;
  bool _isLoadingModel = false;
  
  // Fashion items data
  final List<Map<String, String>> _fashionItems = [
    {
      'id': 'dayana',
      'name': 'Dayana',
      'image': 'assets/images/dayana.jpg',
      'model': 'assets/glb/dayana_blue.glb',
    },
    {
      'id': 'nayra',
      'name': 'Nayra',
      'image': 'assets/images/nayra.jpg',
      'model': 'assets/glb/nayra_black.glb',
    },
    {
      'id': 'sabrina_black',
      'name': 'Sabrina Black',
      'image': 'assets/images/sabrina black.jpg',
      'model': 'assets/glb/sabrina_black.glb',
    },
    {
      'id': 'sabrina_white',
      'name': 'Sabrina White',
      'image': 'assets/images/sabrina white.jpg',
      'model': 'assets/glb/sabrina_white.glb',
    },
    {
      'id': 'valerya_pink',
      'name': 'Valerya Pink',
      'image': 'assets/images/valerya pink.jpg',
      'model': 'assets/glb/valerya_pink.glb',
    },
    {
      'id': 'xavia_black',
      'name': 'Xavia Black',
      'image': 'assets/images/xavia black.jpg',
      'model': 'assets/glb/xavia_black.glb',
    },
    {
      'id': 'xavia_blue',
      'name': 'Xavia Blue',
      'image': 'assets/images/xavia blue.jpg',
      'model': 'assets/glb/xavia_blue.glb',
    },
    {
      'id': 'xavia_purple',
      'name': 'Xavia Purple',
      'image': 'assets/images/xavia purple.jpg',
      'model': 'assets/glb/xavia_purple.glb',
    },
  ];
  
  String? _selectedItemId;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final frontCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );
        
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Camera Preview (Full Screen - no AppBar)
                if (_isCameraInitialized && _cameraController != null)
                  Positioned.fill(
                    child: CameraPreview(_cameraController!),
                  )
                else
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      child: const Center(
                        child: Text(
                          'Camera not available',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                
                // 3D Model Overlay (when item is selected)
                if (_selectedItemId != null)
                  Positioned.fill(
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: ModelViewer(
                              key: ValueKey(_selectedItemId), // Force rebuild when item changes
                              src: _fashionItems.firstWhere(
                                (item) => item['id'] == _selectedItemId,
                              )['model']!,
                              alt: 'Fashion 3D Model',
                              ar: true,
                              autoRotate: true,
                              cameraControls: true,
                              backgroundColor: Colors.transparent,
                              loading: Loading.eager,
                            ),
                          ),
                        ),
                        if (_isLoadingModel)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Loading 3D Model...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
                
                // Close 3D Model button (when model is shown)
                if (_selectedItemId != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () {
                        setState(() {
                          _selectedItemId = null;
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                
                // Fashion Items List (Overlay at bottom)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16),
                      itemCount: _fashionItems.length,
                      itemBuilder: (context, index) {
                        final item = _fashionItems[index];
                        final isSelected = _selectedItemId == item['id'];
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedItemId = item['id'];
                              _isLoadingModel = true;
                            });
                            // Simulate model loading time
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                setState(() {
                                  _isLoadingModel = false;
                                });
                              }
                            });
                          },
                          child: Container(
                            width: 110,
                            margin: const EdgeInsets.only(right: 12),
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF00796B)
                                              : Colors.grey[300]!,
                                          width: isSelected ? 3 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: Image.asset(
                                          item['image']!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 32,
                                                color: Colors.grey[400],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['name']!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF00796B)
                                            : Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                // Loading indicator on item
                                if (isSelected && _isLoadingModel)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
