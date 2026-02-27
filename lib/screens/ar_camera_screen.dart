import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

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
  bool _isFrontCamera = true;
  
  // Image recognition
  final ImageLabeler _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
  final TextRecognizer _textRecognizer = TextRecognizer();
  Timer? _recognitionTimer;
  bool _isProcessingImage = false;
  final Map<String, ui.Image> _referenceImages = {};
  String _lastDetectedLabel = '';
  
  // Fashion items data
  final List<Map<String, String>> _fashionItems = [
    {
      'id': 'dayana',
      'name': 'Dayana',
      'image': 'assets/images/dayana.jpg',
      'model': 'assets/glb/dayana_blue.glb',
      'category': 'Dress',
      'description': '''Bismillah…Open Katalog Seragaman💐

Dayana Dress by @aerahijab.official💐

Dayana Dress di design simple dengan kombinasi Babydoll yang memadukan nuansa feminim dan modis. Menggunakan bahan utama Shakilla Premium yang lembut, serta sifatnya yang flowy dan tidak mudah kusut, sehingga sangat praktis untuk dirawat.

Dayana Dress memberikan sentuhan mewah dan modern untuk penampilan sehari-hari Anda✨

🖊Detail :
⁃ Matt : Shakilla Premium
⁃ Terdapat kombinasi layer dengan material Babydoll Premium yang membuat dressnya terlihat lebih menawan
⁃ Terdapat aksen manik permata pada bagian depan yang membuat looknya elegan
⁃ Terdapat kancing pada layer Babydoll Premium
⁃ Terdapat resleting pada bagian depan dressnya sehingga busui friendly
⁃ Menggunakan desain kerah kemeja yang membuat looknya simpel namun tetap menawan
⁃ Terdapat saku pada bagian kanan sehingga memudahkan untuk membawa barang-barang kecil
⁃ Desain lengan dari kombinasi Babydoll Premium yang mempercantik tampilannya
⁃ Free tali lepas pasang untuk styling dressnya, sehingga bisa dijadikan beberapa macam style

🌈Varian Warna :
⁃ Dusty Choco
⁃ Mauve Lilac
⁃ Steel Blue 
⁃ White
⁃ Black

Pashmina :
⁃ Dusty Choco
⁃ Mauve Lilac 
⁃ Steel Blue
⁃ White
⁃ Black

📐 Sizechart :
* XS : LD 84 cm // PB 125 cm
* S : LD 90 cm // PB 131 cm
* M : LD 96 cm // PB 135 cm
* L : LD 100 cm // PB 137 cm
* XL : LD 110 cm // PB 140 cm
* XXL : LD 120 cm // PB 142 cm

Pashmina : 180 cm x 70 cm

⚖️ Estimasi Berat : 400 gram

💵Pricelist 
* XS : Rp 140.000 ,-
* S : Rp 150.000 ,-
* M : Rp 155.000 ,-
* L : Rp 160.000 ,-
* XL : Rp 165.000 ,-
* XXL : Rp 170.000 ,-

Pashmina : Rp 55.000 ,-

⛔️Lebih atau Kurang 1-3 Cm dikarenakan Proses Produksi
⛔️ Kemiripan warna 90%, Karena setiap layar HP/PC mempunyai karakteristik yang berbeda. Selain itu efek pencahayaan saat Photoshot bisa saja mempengaruhi tampilan warna pada hasil foto''',
    },
    {
      'id': 'nayra',
      'name': 'Nayra',
      'image': 'assets/images/nayra.jpg',
      'model': 'assets/glb/nayra_black.glb',
      'category': 'Dress',
      'description': '''NAYRA Dress AFAS X SITA
(Open PO 19-26 Jan 2026)

Detail Dress

🌸 Material Ceruty Babydoll premium memiliki karakteristik bahan yang jatuh, lembut, tidak mudah kusut, dan sangat adem
🌸 Menggunakan resleting belakang
🌸 Kerah Shanghai untuk tampilan rapi namun tetap santai
🌸 Terdapat variasi lis kombinasi vertikal di bagian depan untuk membuat ilusi tubuh menjadi lebih slim dan jenjang
🌸 Variasi Swarovski pada bagian depan membuat look lebih elegant
🌸 Menggunakan lengan manset untuk memberikan keseimbangan antara ringan dan rapi yang modern (Wudhu Friendly)
🌸 Cutting A-line, melebar kebawah dengan anggun, memberikan kesan feminim dan sopan
🌸 Terdapat Plat Ekslusif di bagian lengan

Warna
🌸 Coffee
🌸 Jade
🌸 Steel

Size
Dress : XS-XXL

Harga
XS-XL : ~429.000~ 389.000
XXL : +30.000

Nayra Dress by @sita.id.official @afas_id 

NOTE :
⚘️ Perbedaan warna 10-20% karena efek cahaya dalam photoshoot
⚘️ Perbedaan ukuran bisa lebih atau kurang karena proses produksi
⚘️ Estimasi Ready 3-4 minggu setelah close PO
⚘️ Full Payment
⚘️ Produk Ready akan diinfokan 1 minggu sebelumnya untuk diteruskan di tim masing-masing''',
    },
    {
      'id': 'sabrina_black',
      'name': 'Sabrina Black',
      'image': 'assets/images/sabrina black.jpg',
      'model': 'assets/glb/sabrina_black.glb',
      'category': 'Dress',
      'description': 'Detail produk Sabrina Black',
    },
    {
      'id': 'sabrina_white',
      'name': 'Sabrina White',
      'image': 'assets/images/sabrina white.jpg',
      'model': 'assets/glb/sabrina_white.glb',
      'category': 'Dress',
      'description': 'Detail produk Sabrina White',
    },
    {
      'id': 'valerya_pink',
      'name': 'Valerya Pink',
      'image': 'assets/images/valerya pink.jpg',
      'model': 'assets/glb/valerya_pink.glb',
      'category': 'Dress',
      'description': 'Detail produk Valerya Pink',
    },
    {
      'id': 'xavia_black',
      'name': 'Xavia Black',
      'image': 'assets/images/xavia black.jpg',
      'model': 'assets/glb/xavia_black.glb',
      'category': 'Dress',
      'description': 'Detail produk Xavia Black',
    },
    {
      'id': 'xavia_blue',
      'name': 'Xavia Blue',
      'image': 'assets/images/xavia blue.jpg',
      'model': 'assets/glb/xavia_blue.glb',
      'category': 'Dress',
      'description': 'Detail produk Xavia Blue',
    },
    {
      'id': 'xavia_purple',
      'name': 'Xavia Purple',
      'image': 'assets/images/xavia purple.jpg',
      'model': 'assets/glb/xavia_purple.glb',
      'category': 'Dress',
      'description': 'Detail produk Xavia Purple',
    },
  ];
  
  String? _selectedItemId;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadReferenceImages();
  }

  @override
  void dispose() {
    _recognitionTimer?.cancel();
    _imageLabeler.close();
    _textRecognizer.close();
    _cameraController?.dispose();
    super.dispose();
  }
  
  Future<void> _loadReferenceImages() async {
    for (var item in _fashionItems) {
      try {
        final ByteData data = await rootBundle.load(item['image']!);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _referenceImages[item['id']!] = frame.image;
      } catch (e) {
        debugPrint('Error loading reference image ${item['id']}: $e');
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final selectedCamera = _isFrontCamera
            ? _cameras.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first,
              )
            : _cameras.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras.first,
              );
        
        _cameraController = CameraController(
          selectedCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
            _isLoading = false;
          });
          
          // Start image recognition
          _startImageRecognition();
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
  
  Future<void> _switchCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isCameraInitialized = false;
    });
    
    _recognitionTimer?.cancel();
    await _cameraController?.dispose();
    
    await _initializeCamera();
  }
  
  void _startImageRecognition() {
    _recognitionTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      // Continue scanning even when model is displayed for real-time detection
      if (!_isProcessingImage && 
          !_isLoadingModel &&
          _cameraController != null && 
          _cameraController!.value.isInitialized) {
        _processCurrentFrame();
      }
    });
  }
  
  Future<void> _processCurrentFrame() async {
    if (_isProcessingImage) return;
    
    _isProcessingImage = true;
    
    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      
      // Try text recognition first (for reading product names on posters)
      final recognizedText = await _textRecognizer.processImage(inputImage);
      String detectedText = recognizedText.text.toLowerCase();
      
      debugPrint('=== Text Detected ===');
      debugPrint(detectedText);
      
      // Check if any product name is in the detected text
      String? matchedFromText = _findMatchingItemFromText(detectedText);
      if (matchedFromText != null && _selectedItemId != matchedFromText) {
        debugPrint('Matched from text: $matchedFromText');
        
        setState(() {
          _selectedItemId = matchedFromText;
          _isLoadingModel = true;
          _lastDetectedLabel = 'Text: ${matchedFromText.toUpperCase()}';
        });
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isLoadingModel = false;
            });
          }
        });
        _isProcessingImage = false;
        return;
      }
      
      // If no text match, try image labeling
      final labels = await _imageLabeler.processImage(inputImage);
      
      debugPrint('=== Image Labels Detected ===');
      for (var label in labels) {
        debugPrint('Label: ${label.label}, Confidence: ${label.confidence}');
      }
      
      // Update last detected label for UI
      if (labels.isNotEmpty && mounted) {
        setState(() {
          _lastDetectedLabel = labels.first.label;
        });
      }
      
      // Match based on labels with lower threshold
      for (var label in labels) {
        if (label.confidence > 0.3) { // Lower threshold for better detection
          final matchedItem = _findMatchingItem(label.label);
          if (matchedItem != null && _selectedItemId != matchedItem) {
            debugPrint('Matched item: $matchedItem for label: ${label.label}');
            setState(() {
              _selectedItemId = matchedItem;
              _isLoadingModel = true;
            });
            
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _isLoadingModel = false;
                });
              }
            });
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error processing frame: $e');
    } finally {
      _isProcessingImage = false;
    }
  }
  
  String? _findMatchingItemFromText(String text) {
    final lowerText = text.toLowerCase();
    
    debugPrint('Searching for product names in text: $lowerText');
    
    // Check for product names in text (case insensitive)
    if (lowerText.contains('dayana')) {
      debugPrint('✓ Found DAYANA in text');
      return 'dayana';
    }
    if (lowerText.contains('nayra')) {
      debugPrint('✓ Found NAYRA in text');
      return 'nayra';
    }
    if (lowerText.contains('sabrina')) {
      debugPrint('✓ Found SABRINA in text');
      if (lowerText.contains('black')) {
        debugPrint('  → Variant: BLACK');
        return 'sabrina_black';
      }
      if (lowerText.contains('white')) {
        debugPrint('  → Variant: WHITE');
        return 'sabrina_white';
      }
      return 'sabrina_black'; // default
    }
    if (lowerText.contains('valerya')) {
      debugPrint('✓ Found VALERYA in text');
      return 'valerya_pink';
    }
    if (lowerText.contains('xavia')) {
      debugPrint('✓ Found XAVIA in text');
      if (lowerText.contains('black')) {
        debugPrint('  → Variant: BLACK');
        return 'xavia_black';
      }
      if (lowerText.contains('blue')) {
        debugPrint('  → Variant: BLUE');
        return 'xavia_blue';
      }
      if (lowerText.contains('purple')) {
        debugPrint('  → Variant: PURPLE');
        return 'xavia_purple';
      }
      return 'xavia_black'; // default
    }
    
    debugPrint('✗ No product name found in text');
    return null;
  }
  
  String? _findMatchingItem(String label) {
    final lowerLabel = label.toLowerCase();
    
    debugPrint('Checking label: $lowerLabel');
    
    // Match poster - show random or cycle through items
    if (lowerLabel.contains('poster') || 
        lowerLabel.contains('picture') ||
        lowerLabel.contains('photo') ||
        lowerLabel.contains('image')) {
      debugPrint('Detected POSTER/IMAGE - showing fashion item');
      // Cycle through items based on current selection
      if (_selectedItemId == null) {
        return _fashionItems.first['id'];
      } else {
        final currentIndex = _fashionItems.indexWhere((item) => item['id'] == _selectedItemId);
        final nextIndex = (currentIndex + 1) % _fashionItems.length;
        return _fashionItems[nextIndex]['id'];
      }
    }
    
    // Match based on color keywords
    if (lowerLabel.contains('blue')) {
      debugPrint('Detected BLUE - matching dayana or xavia blue');
      return 'dayana'; // or 'xavia_blue'
    }
    if (lowerLabel.contains('black')) {
      debugPrint('Detected BLACK - matching nayra');
      return 'nayra';
    }
    if (lowerLabel.contains('white')) {
      debugPrint('Detected WHITE - matching sabrina white');
      return 'sabrina_white';
    }
    if (lowerLabel.contains('pink')) {
      debugPrint('Detected PINK - matching valerya');
      return 'valerya_pink';
    }
    if (lowerLabel.contains('purple') || lowerLabel.contains('violet')) {
      debugPrint('Detected PURPLE - matching xavia purple');
      return 'xavia_purple';
    }
    
    // Match based on clothing keywords
    if (lowerLabel.contains('dress') || 
        lowerLabel.contains('clothing') ||
        lowerLabel.contains('fashion') ||
        lowerLabel.contains('apparel') ||
        lowerLabel.contains('garment') ||
        lowerLabel.contains('textile') ||
        lowerLabel.contains('fabric')) {
      debugPrint('Detected clothing item - showing first item');
      return _fashionItems.first['id'];
    }
    
    return null;
  }
  
  void _showProductDetail() {
    if (_selectedItemId == null) return;
    
    final item = _fashionItems.firstWhere((item) => item['id'] == _selectedItemId);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image and category
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 140,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                item['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00796B).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF00796B)),
                                  ),
                                  child: Text(
                                    item['category'] ?? 'Dress',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF00796B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Koleksi Premium',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Bahan premium dengan kualitas terbaik',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      
                      // Description
                      Text(
                        item['description'] ?? 'Detail produk ${item['name']}',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                
                // 3D Model Overlay (when item is selected) - Full Screen
                if (_selectedItemId != null)
                  Positioned.fill(
                    child: Stack(
                      children: [
                        // Full screen 3D model
                        Positioned.fill(
                          child: ModelViewer(
                            key: ValueKey(_selectedItemId), // Force rebuild when item changes
                            src: _fashionItems.firstWhere(
                              (item) => item['id'] == _selectedItemId,
                            )['model']!,
                            alt: 'Fashion 3D Model',
                            ar: true,
                            autoRotate: false, // Disable auto-rotate
                            autoPlay: false, // Disable animation auto-play
                            cameraControls: true,
                            backgroundColor: Colors.transparent,
                            loading: Loading.eager,
                            shadowIntensity: 0, // Disable shadow
                            shadowSoftness: 0,
                            interactionPrompt: InteractionPrompt.none, // Remove interaction prompt
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
                
                // Switch Camera button (hide when 3D model is shown)
                if (_selectedItemId == null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
                      onPressed: _cameras.length > 1 ? _switchCamera : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                
                // Image Recognition Indicator (always show, even when model is displayed)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isProcessingImage ? Icons.search : Icons.text_fields,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isProcessingImage 
                                    ? 'Reading text...' 
                                    : _selectedItemId == null 
                                        ? 'Point at poster with product name'
                                        : 'Scanning for other products...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (_lastDetectedLabel.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _lastDetectedLabel,
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Close 3D Model button (when model is shown)
                if (_selectedItemId != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 64,
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
                
                // Detail button (when model is shown)
                if (_selectedItemId != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 120,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
                      onPressed: _showProductDetail,
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
