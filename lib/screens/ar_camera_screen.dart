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
  bool _isModelLoaded = false;
  double _modelLoadProgress = 0.0;
  
  // Image recognition
  final ImageLabeler _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
  final TextRecognizer _textRecognizer = TextRecognizer();
  Timer? _recognitionTimer;
  bool _isProcessingImage = false;
  final Map<String, ui.Image> _referenceImages = {};
  String _lastDetectedLabel = '';
  List<String> _recentLabels = [];
  String _detectedText = '';
  
  // Fashion items data
  final List<Map<String, String>> _fashionItems = [
    {
      'id': 'dayana',
      'name': 'Dayana',
      'image': 'assets/images/dayana.jpg',
      'model': 'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/ar-fashion-glb/dayana_blue.glb',
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
      'model': 'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/ar-fashion-glb/nayra_black.glb',
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
      'model': 'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/ar-fashion-glb/sabrina_black.glb',
      'category': 'Dress',
      'description': 'Detail produk Sabrina Black',
    },
    {
      'id': 'sabrina_white',
      'name': 'Sabrina White',
      'image': 'assets/images/sabrina white.jpg',
      'model': 'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/ar-fashion-glb/sabrina_white.glb',
      'category': 'Dress',
      'description': 'Detail produk Sabrina White',
    },
    {
      'id': 'valerya_dusty',
      'name': 'Valerya Dusty',
      'image': 'assets/images/valerya pink.jpg',
      'model': 'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/ar-fashion-glb/valerya_pink.glb',
      'category': 'Dress',
      'description': '''Bismillahirrahmanirrahim..
Sebelum menyimak lebih lanjut, jangan lupa shalawatan dulu yuk! Semoga jualan kita laris manis dan berkah untuk kita semua. Aamiin.. 🤲🏻

VALERYA SERIES NEW - Dusty
On model pakai size M

Berbahan babydoll premium X rayon premium X tule premium yang sangat nyaman, adem. Modelnya simple namun looknya super mewah! Cocok banget untuk outfit daily, outfit hangout atau semi formal My Nadheera! 😍

DETAIL DRESS & MIDI DRESS :
✔️ model simpel looknya mewah dan so slimmy
✔️ detail lengan puffy dengan kopel karet smoke dipadukan dengan tule premium ( Wudlu friendly )
✔️ detail kerah shanghai dengan detail zipper bagian depan dan tali adjustable
✔️ detail Cutting super lebar dengan floi 
✔️ berlabel ORI Nadheera Luxury

Size Chart Midi Dress :
LD : 92/96/100/104
PB : 130
P. Lengan : 57

Size Chart Dress :
LD : 92/96/100/104
PB : 135/138/140/140
P. Lengan : 57

HARGA NORMAL DRESS & MIDI DRESS :
IDR 379.900,- (S)
IDR 389.900,- (M)
IDR 399.900,- (L)
IDR 409.900,- (XL)

HARGA SP DRESS & MIDI DRESS S-M :
Retail : IDR 299.900,-
Reseller : IDR 284.900,-
Sub Agen : IDR 269.900,-
Agen : IDR 249.900,-

HARGA SP DRESS & MIDI DRESS L-XL :
Retail : IDR 309.900,-
Reseller : IDR 294.900,-
Sub Agen : IDR 279.900,-
Agen : IDR 259.900,-

NOTE : 
Retail - Sub Agen : Jika order dibawah minimal +7.500,-/item
Agen - Distributor : Jika order dibawah minimal +10.000,-/item

Available Colour :
• bamboo
• blue caroline
• dusty
• olive

OPEN LIST H+1 SETELAH LAUNCHING S/D RABU, 21 JANUARI PUKUL 08.30 WIB ‼️
INSYALLAH LANGSUNG PEMBAGIAN''',
    },
    {
      'id': 'xavia_black',
      'name': 'Xavia Black',
      'image': 'assets/images/xavia black.jpg',
      'model': 'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/ar-fashion-glb/xavia_black.glb',
      'category': 'Dress',
      'description': 'Detail produk Xavia Black',
    },
    {
      'id': 'xavia_blue',
      'name': 'Xavia Cornflower Blue',
      'image': 'assets/images/xavia blue.jpg',
      'model': 'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/ar-fashion-glb/xavia_blue.glb',
      'category': 'Dress',
      'description': 'Detail produk Xavia Cornflower Blue',
    },
    {
      'id': 'xavia_glamour',
      'name': 'Xavia Glamour',
      'image': 'assets/images/xavia blue old.jpg',
      'model': 'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/ar-fashion-glb/xavia_blue_old.glb',
      'category': 'Dress',
      'description': '''Bismillahirrahmanirrahim..
Sebelum menyimak lebih lanjut, jangan lupa shalawatan dulu yuk! Semoga jualan kita laris manis dan berkah untuk kita semua. Aamiin.. 🤲🏻

XAVIA SERIES - Glamour
On model pakai size M

Berbahan rayon premium yang sangat nyaman, adem. Modelnya simple namun looknya super mewah! Cocok banget untuk outfit daily, outfit hangout atau semi formal My Nadheera! 😍

DETAIL DRESS & MIDI DRESS :
✔️ model simpel looknya mewah dan so slimmy
✔️ detail lengan semi puffy dengan kopel karet ( Wudlu friendly )
✔️ detail kerah shanghai dengan detail zipper bagian depan ( Busui friendly ) 
✔️ detail Cutting Aline super lebar 
✔️ berlabel ORI Nadheera Luxury

Size Chart Midi Dress :
LD : 92/96/100/104/110/120
PB : 130
P. Lengan : 57

Size Chart Dress :
LD : 92/96/100/104/110/120
PB : 135/138/140/140/140/140
P. Lengan : 57

HARGA NORMAL DRESS & MIDI DRESS :
IDR 239.900,- (S)
IDR 244.900,- (M)
IDR 249.900,- (L)
IDR 254.900,- (XL)
IDR 259.900,- (XXL)
IDR 264.900,- (XXXL)

HARGA SP DRESS & MIDI DRESS S-L :
Retail : IDR 189.900,-
Reseller : IDR 179.900,-
Sub Agen : IDR 169.900,-
Agen : IDR 154.900,-

HARGA SP DRESS & MIDI DRESS XL-XXXL :
Retail : IDR 194.900,-
Reseller : IDR 184.900,-
Sub Agen : IDR 174.900,-
Agen : IDR 159.900,-

NOTE :
Retail-Sub Agen : Jika order dibawah minimal +5.000,-/item
Agen-Distributor : Jika order dibawah minimal +7.500,-/item

Available Colour :
• black
• cornflower
• glamour
• mulberry

OPEN LIST H+1 SETELAH LAUNCHING S/D RABU, 21 JANUARI 2026 PUKUL 08.30 WIB ‼️
INSYALLAH LANGSUNG PEMBAGIAN📌''',
    },
    {
      'id': 'xavia_purple',
      'name': 'Xavia Purple',
      'image': 'assets/images/xavia purple.jpg',
      'model': 'https://qerzhadqtgkckrejxcqg.supabase.co/storage/v1/object/public/ar-fashion-glb/xavia_purple.glb',
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
    _recognitionTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      // Pause scanning when model is loading or being displayed
      if (!_isProcessingImage && 
          !_isLoadingModel &&
          !_isModelLoaded &&
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
      
      // Update UI with detected text
      if (mounted) {
        setState(() {
          _detectedText = detectedText;
        });
      }
      
      // Check if any product name is in the detected text
      String? matchedFromText = _findMatchingItemFromText(detectedText);
      if (matchedFromText != null && _selectedItemId != matchedFromText) {
        debugPrint('✓✓✓ MATCHED FROM TEXT: $matchedFromText');
        
        setState(() {
          _selectedItemId = matchedFromText;
          _isLoadingModel = true;
          _isModelLoaded = false;
          _modelLoadProgress = 0.0;
          _lastDetectedLabel = 'Text: ${matchedFromText.toUpperCase()}';
        });
        
        // Simulate loading progress
        _simulateLoadingProgress();
        _isProcessingImage = false;
        return;
      }
      
      // Don't process labels if already loading or model is displayed
      if (_isLoadingModel || _isModelLoaded) {
        _isProcessingImage = false;
        return;
      }
      
      // If no text match, try image labeling
      final labels = await _imageLabeler.processImage(inputImage);
      
      debugPrint('=== Image Labels Detected ===');
      for (var label in labels) {
        debugPrint('Label: ${label.label}, Confidence: ${label.confidence}');
      }
      
      // Update UI with recent labels
      if (mounted && labels.isNotEmpty) {
        setState(() {
          _recentLabels = labels.take(5).map((l) => '${l.label} (${(l.confidence * 100).toInt()}%)').toList();
          _lastDetectedLabel = labels.first.label;
        });
      }
      
      // Match based on labels with lower threshold
      for (var label in labels) {
        if (label.confidence > 0.2) { // Even lower threshold for better detection
          final matchedItem = _findMatchingItem(label.label);
          if (matchedItem != null && _selectedItemId != matchedItem) {
            debugPrint('✓✓✓ MATCHED FROM LABEL: $matchedItem for label: ${label.label} (confidence: ${label.confidence})');
            setState(() {
              _selectedItemId = matchedItem;
              _isLoadingModel = true;
              _isModelLoaded = false;
              _modelLoadProgress = 0.0;
            });
            
            _simulateLoadingProgress();
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
    
    // Remove special characters and extra spaces for better matching
    final cleanText = lowerText.replaceAll(RegExp(r'[^\w\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ');
    debugPrint('Cleaned text: $cleanText');
    
    // Check for product names in text (case insensitive, flexible matching)
    if (cleanText.contains('dayana') || cleanText.contains('daiana') || cleanText.contains('diana')) {
      debugPrint('✓ Found DAYANA in text');
      return 'dayana';
    }
    if (cleanText.contains('nayra') || cleanText.contains('naira') || cleanText.contains('nayla')) {
      debugPrint('✓ Found NAYRA in text');
      return 'nayra';
    }
    if (cleanText.contains('sabrina') || cleanText.contains('sabina')) {
      debugPrint('✓ Found SABRINA in text');
      if (cleanText.contains('black') || cleanText.contains('hitam')) {
        debugPrint('  → Variant: BLACK');
        return 'sabrina_black';
      }
      if (cleanText.contains('white') || cleanText.contains('putih')) {
        debugPrint('  → Variant: WHITE');
        return 'sabrina_white';
      }
      return 'sabrina_black'; // default
    }
    if (cleanText.contains('valerya') || cleanText.contains('valeria') || cleanText.contains('valery')) {
      debugPrint('✓ Found VALERYA in text');
      return 'valerya_dusty';
    }
    if (cleanText.contains('xavia') || cleanText.contains('xafia') || cleanText.contains('xavier')) {
      debugPrint('✓ Found XAVIA in text');
      if (cleanText.contains('black') || cleanText.contains('hitam')) {
        debugPrint('  → Variant: BLACK');
        return 'xavia_black';
      }
      if (cleanText.contains('blue') || cleanText.contains('biru') || cleanText.contains('cornflower')) {
        debugPrint('  → Variant: CORNFLOWER BLUE');
        return 'xavia_blue';
      }
      if (cleanText.contains('glamour') || cleanText.contains('glamor')) {
        debugPrint('  → Variant: GLAMOUR');
        return 'xavia_glamour';
      }
      if (cleanText.contains('purple') || cleanText.contains('ungu') || cleanText.contains('violet') || cleanText.contains('mulberry')) {
        debugPrint('  → Variant: PURPLE');
        return 'xavia_purple';
      }
      return 'xavia_black'; // default
    }
    
    // Check for color keywords alone (if no product name found)
    if (cleanText.contains('blue') || cleanText.contains('biru') || cleanText.contains('cornflower')) {
      debugPrint('✓ Found BLUE/CORNFLOWER color - matching xavia cornflower blue');
      return 'xavia_blue';
    }
    if (cleanText.contains('black') || cleanText.contains('hitam')) {
      debugPrint('✓ Found BLACK color - matching nayra');
      return 'nayra';
    }
    if (cleanText.contains('white') || cleanText.contains('putih')) {
      debugPrint('✓ Found WHITE color - matching sabrina white');
      return 'sabrina_white';
    }
    if (cleanText.contains('pink') || cleanText.contains('merah muda') || cleanText.contains('dusty')) {
      debugPrint('✓ Found PINK/DUSTY color - matching valerya');
      return 'valerya_dusty';
    }
    if (cleanText.contains('purple') || cleanText.contains('ungu') || cleanText.contains('violet')) {
      debugPrint('✓ Found PURPLE color - matching xavia purple');
      return 'xavia_purple';
    }
    
    debugPrint('✗ No product name found in text');
    return null;
  }
  
  void _simulateLoadingProgress() {
    // Simulate realistic loading progress
    _modelLoadProgress = 0.0;
    
    // Stage 1: Downloading (0-30%)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _isLoadingModel) {
        setState(() => _modelLoadProgress = 0.15);
      }
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _isLoadingModel) {
        setState(() => _modelLoadProgress = 0.30);
      }
    });
    
    // Stage 2: Processing (30-70%)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && _isLoadingModel) {
        setState(() => _modelLoadProgress = 0.50);
      }
    });
    
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted && _isLoadingModel) {
        setState(() => _modelLoadProgress = 0.70);
      }
    });
    
    // Stage 3: Rendering (70-100%)
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _isLoadingModel) {
        setState(() => _modelLoadProgress = 0.85);
      }
    });
    
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted && _isLoadingModel) {
        setState(() => _modelLoadProgress = 0.95);
      }
    });
    
    // Complete
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _modelLoadProgress = 1.0;
          _isLoadingModel = false;
          _isModelLoaded = true;
        });
      }
    });
  }
  
  String? _findMatchingItem(String label) {
    final lowerLabel = label.toLowerCase();
    
    debugPrint('Checking label: $lowerLabel');
    
    // Match ANY visual content - be very aggressive
    if (lowerLabel.contains('poster') || 
        lowerLabel.contains('picture') ||
        lowerLabel.contains('photo') ||
        lowerLabel.contains('image') ||
        lowerLabel.contains('paper') ||
        lowerLabel.contains('document') ||
        lowerLabel.contains('print') ||
        lowerLabel.contains('text') ||
        lowerLabel.contains('advertisement') ||
        lowerLabel.contains('flyer')) {
      debugPrint('✓ Detected VISUAL CONTENT - showing fashion item');
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
    if (lowerLabel.contains('blue') || lowerLabel.contains('azure') || lowerLabel.contains('cornflower')) {
      debugPrint('✓ Detected BLUE/CORNFLOWER - matching xavia cornflower blue');
      return 'xavia_blue';
    }
    if (lowerLabel.contains('black') || lowerLabel.contains('dark')) {
      debugPrint('✓ Detected BLACK - matching nayra');
      return 'nayra';
    }
    if (lowerLabel.contains('white') || lowerLabel.contains('light')) {
      debugPrint('✓ Detected WHITE - matching sabrina white');
      return 'sabrina_white';
    }
    if (lowerLabel.contains('pink') || lowerLabel.contains('rose') || lowerLabel.contains('dusty')) {
      debugPrint('✓ Detected PINK/DUSTY - matching valerya');
      return 'valerya_dusty';
    }
    if (lowerLabel.contains('purple') || lowerLabel.contains('violet') || lowerLabel.contains('lavender')) {
      debugPrint('✓ Detected PURPLE - matching xavia purple');
      return 'xavia_purple';
    }
    
    // Match based on clothing keywords - very broad
    if (lowerLabel.contains('dress') || 
        lowerLabel.contains('clothing') ||
        lowerLabel.contains('fashion') ||
        lowerLabel.contains('apparel') ||
        lowerLabel.contains('garment') ||
        lowerLabel.contains('textile') ||
        lowerLabel.contains('fabric') ||
        lowerLabel.contains('wear') ||
        lowerLabel.contains('outfit') ||
        lowerLabel.contains('attire')) {
      debugPrint('✓ Detected CLOTHING - showing first item');
      return _fashionItems.first['id'];
    }
    
    // Match person/model - show fashion item
    if (lowerLabel.contains('person') ||
        lowerLabel.contains('woman') ||
        lowerLabel.contains('model') ||
        lowerLabel.contains('human') ||
        lowerLabel.contains('face')) {
      debugPrint('✓ Detected PERSON/MODEL - showing fashion item');
      return _fashionItems.first['id'];
    }
    
    debugPrint('✗ No match found for: $lowerLabel');
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
                            autoRotate: false,
                            autoPlay: false,
                            cameraControls: true,
                            backgroundColor: Colors.transparent,
                            loading: Loading.eager,
                            shadowIntensity: 0,
                            shadowSoftness: 0,
                            interactionPrompt: InteractionPrompt.none,
                            // Performance optimizations
                            disablePan: false,
                            disableTap: false,
                            touchAction: TouchAction.panY,
                            // Optimize rendering with CSS
                            relatedCss: '''
                              model-viewer {
                                --poster-color: transparent;
                                --progress-bar-color: #00796B;
                                /* Hardware acceleration */
                                transform: translateZ(0);
                                -webkit-transform: translateZ(0);
                                will-change: transform;
                                /* Smooth rendering */
                                -webkit-font-smoothing: antialiased;
                                -moz-osx-font-smoothing: grayscale;
                                /* Optimize performance */
                                backface-visibility: hidden;
                                -webkit-backface-visibility: hidden;
                              }
                              
                              /* Optimize canvas rendering */
                              model-viewer canvas {
                                transform: translateZ(0);
                                -webkit-transform: translateZ(0);
                              }
                            ''',
                            // Track loading progress
                            relatedJs: '''
                              const modelViewer = document.querySelector('model-viewer');
                              if (modelViewer) {
                                // Track loading progress
                                modelViewer.addEventListener('progress', (event) => {
                                  const progress = event.detail.totalProgress;
                                  window.flutter_inappwebview.callHandler('onProgress', progress);
                                });
                                
                                // Model loaded
                                modelViewer.addEventListener('load', () => {
                                  window.flutter_inappwebview.callHandler('onModelLoaded');
                                  
                                  // Optimize WebGL context
                                  const canvas = modelViewer.shadowRoot.querySelector('canvas');
                                  if (canvas) {
                                    const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');
                                    if (gl) {
                                      gl.enable(gl.CULL_FACE);
                                      gl.cullFace(gl.BACK);
                                    }
                                  }
                                });
                                
                                // Error handling
                                modelViewer.addEventListener('error', (event) => {
                                  window.flutter_inappwebview.callHandler('onError', event.detail);
                                });
                              }
                            ''',
                          ),
                        ),
                        if (_isLoadingModel || !_isModelLoaded)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Circular progress indicator
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Background circle
                                        SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: CircularProgressIndicator(
                                            value: _modelLoadProgress > 0 ? _modelLoadProgress : null,
                                            strokeWidth: 4,
                                            backgroundColor: Colors.grey[800],
                                            valueColor: const AlwaysStoppedAnimation<Color>(
                                              Color(0xFF00796B),
                                            ),
                                          ),
                                        ),
                                        // Percentage text
                                        if (_modelLoadProgress > 0)
                                          Text(
                                            '${(_modelLoadProgress * 100).toInt()}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Loading text
                                  const Text(
                                    'Loading 3D Model...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Product name
                                  Text(
                                    _fashionItems.firstWhere(
                                      (item) => item['id'] == _selectedItemId,
                                    )['name']!,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Loading stages
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _modelLoadProgress < 0.3
                                              ? Icons.cloud_download
                                              : _modelLoadProgress < 0.7
                                                  ? Icons.memory
                                                  : Icons.view_in_ar,
                                          color: const Color(0xFF00796B),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _modelLoadProgress < 0.3
                                              ? 'Downloading...'
                                              : _modelLoadProgress < 0.7
                                                  ? 'Processing...'
                                                  : 'Rendering...',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
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
                

                // Scanning indicator (only show when scanning, not when loading/loaded)
                if (_isProcessingImage && !_isLoadingModel && !_isModelLoaded)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF00796B),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search,
                              color: Color(0xFF00796B),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Scanning image...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // Detection result (show briefly after detection)
                if (_lastDetectedLabel.isNotEmpty && !_isLoadingModel && !_isModelLoaded)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.greenAccent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.greenAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Detected: $_lastDetectedLabel',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
                    child: Column(
                      children: [
                        // Close button
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 28),
                          onPressed: () {
                            setState(() {
                              _selectedItemId = null;
                              _isModelLoaded = false;
                              _modelLoadProgress = 0.0;
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Scan again button
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                          onPressed: () {
                            setState(() {
                              _selectedItemId = null;
                              _isModelLoaded = false;
                              _modelLoadProgress = 0.0;
                              _lastDetectedLabel = '';
                              _detectedText = '';
                              _recentLabels = [];
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF00796B),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Detail button (when model is shown)
                if (_selectedItemId != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 176,
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
                              _isModelLoaded = false;
                              _modelLoadProgress = 0.0;
                            });
                            
                            // Simulate model loading progress
                            _simulateLoadingProgress();
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
                                if (isSelected && (_isLoadingModel || !_isModelLoaded))
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child: CircularProgressIndicator(
                                                    value: _modelLoadProgress > 0 ? _modelLoadProgress : null,
                                                    strokeWidth: 3,
                                                    backgroundColor: Colors.grey[800],
                                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                                      Color(0xFF00796B),
                                                    ),
                                                  ),
                                                ),
                                                if (_modelLoadProgress > 0)
                                                  Text(
                                                    '${(_modelLoadProgress * 100).toInt()}%',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _modelLoadProgress < 0.3
                                                ? 'Downloading'
                                                : _modelLoadProgress < 0.7
                                                    ? 'Processing'
                                                    : 'Rendering',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
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
