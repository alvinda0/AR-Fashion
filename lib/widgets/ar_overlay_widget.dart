import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../models/fashion_item.dart';
import 'simple_glb_viewer.dart';

class AROverlayWidget extends StatefulWidget {
  final FashionItem? fashionItem;
  final vm.Matrix4 transformMatrix;
  final Size screenSize;
  final bool isVisible;
  final bool isManualMode;
  final bool useModelViewer; // New parameter to control ModelViewer usage

  const AROverlayWidget({
    super.key,
    this.fashionItem,
    required this.transformMatrix,
    required this.screenSize,
    this.isVisible = true,
    this.isManualMode = false,
    this.useModelViewer = true, // Default to true, can be disabled if issues occur
  });

  @override
  State<AROverlayWidget> createState() => _AROverlayWidgetState();
}

class _AROverlayWidgetState extends State<AROverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  bool _modelViewerReady = false;
  bool _showModelViewer = false;
  bool _modelViewerFailed = false;
  bool _loadingTimeout = false;
  
  // Manual positioning controls
  double _manualScale = 1.0;
  Offset _manualOffset = Offset.zero;
  
  // Gesture tracking
  double _baseScale = 1.0;
  Offset _baseOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    // Make pulse animation more subtle and stable
    _pulseAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }

    // Only animate in manual mode, keep stable in auto mode
    if (widget.isManualMode) {
      _animationController.repeat(reverse: true);
    }

    // Log GLB model info and delay ModelViewer initialization
    if (widget.fashionItem?.modelPath.endsWith('.glb') == true) {
      debugPrint('AR Overlay: GLB model detected: ${widget.fashionItem!.modelPath}');
      _initializeModelViewer();
    }
  }

  void _initializeModelViewer() {
    // Add more delay for large GLB files
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _modelViewerReady = true;
        });
        
        // Additional delay for large files like tes.glb (18MB)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showModelViewer = true;
            });
            debugPrint('🚀 ModelViewer initialization complete for ${widget.fashionItem!.modelPath}');
          }
        });
      }
    });

    // Timeout fallback - if ModelViewer doesn't load in 10 seconds, show SimpleGLBViewer
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !_modelViewerFailed) {
        debugPrint('⏰ ModelViewer loading timeout - falling back to SimpleGLBViewer');
        setState(() {
          _loadingTimeout = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(AROverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    // Control animation based on manual mode
    if (widget.isManualMode != oldWidget.isManualMode) {
      if (widget.isManualMode) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.value = 1.0; // Keep at full scale
      }
    }

    // Reset ModelViewer state when fashion item changes
    if (widget.fashionItem?.modelPath != oldWidget.fashionItem?.modelPath &&
        widget.fashionItem?.modelPath.endsWith('.glb') == true) {
      debugPrint('AR Overlay: GLB model changed to: ${widget.fashionItem!.modelPath}');
      setState(() {
        _modelViewerReady = false;
        _showModelViewer = false;
        _modelViewerFailed = false;
        _loadingTimeout = false; // Reset timeout state
      });
      _initializeModelViewer();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fashionItem == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        try {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                _build3DModel(),
              ],
            ),
          );
        } catch (e) {
          debugPrint('Error building AR overlay: $e');
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _build3DModel() {
    if (widget.fashionItem!.modelPath.endsWith('.glb') && widget.useModelViewer) {
      return _buildEnhanced3DModel();
    } else {
      return CustomPaint(
        size: widget.screenSize,
        painter: FashionOverlayPainter(
          fashionItem: widget.fashionItem!,
          transformMatrix: widget.transformMatrix,
        ),
      );
    }
  }

  Widget _buildEnhanced3DModel() {
    final translation = widget.transformMatrix.getTranslation();
    final scale = widget.transformMatrix.getMaxScaleOnAxis();

    // Debug positioning
    debugPrint('AR Overlay: translation=${translation.x}, ${translation.y}, scale=$scale');

    // Fallback positioning if transform is invalid
    double left = translation.x - 100;
    double top = translation.y - 150;
    double finalScale = scale > 0 ? scale * 0.8 : 1.0;

    // If transform seems invalid, use center positioning
    if (translation.x == 0 && translation.y == 0) {
      left = widget.screenSize.width / 2 - 100;
      top = widget.screenSize.height / 2 - 150;
      finalScale = 1.0;
      debugPrint('AR Overlay: Using fallback center positioning');
    }

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onScaleStart: (details) {
          if (widget.isManualMode) {
            _baseScale = _manualScale;
            _baseOffset = _manualOffset;
          }
        },
        onScaleUpdate: (details) {
          if (widget.isManualMode) {
            setState(() {
              _manualScale = (_baseScale * details.scale).clamp(0.3, 3.0);
              _manualOffset = _baseOffset + details.focalPointDelta;
            });
          }
        },
        onDoubleTap: () {
          if (widget.isManualMode) {
            setState(() {
              _manualScale = 1.0;
              _manualOffset = Offset.zero;
            });
          }
        },
        child: Transform.translate(
          offset: widget.isManualMode ? _manualOffset : Offset.zero,
          child: Transform.scale(
            scale: widget.isManualMode ? _manualScale : finalScale,
            child: _buildActual3DModel(),
          ),
        ),
      ),
    );
  }

  Widget _buildActual3DModel() {
    // For GLB files, use ModelViewer with safety checks
    if (widget.fashionItem!.modelPath.endsWith('.glb')) {
      return AnimatedBuilder(
        animation: _fadeAnimation, // Use fade animation instead of pulse
        builder: (context, child) {
          // Use stable scale, only apply pulse in manual mode
          double scale = 1.0;
          if (widget.isManualMode) {
            scale = _pulseAnimation.value;
          }
          
          return Transform.scale(
            scale: scale,
            child: Stack(
              children: [
                Container(
                  width: 200,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildSafeModelViewer(),
                  ),
                ),
                // GLB indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'GLB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Model name
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.fashionItem!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    
    // Fallback to CustomPaint for non-GLB files
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        double scale = 1.0;
        if (widget.isManualMode) {
          scale = _pulseAnimation.value;
        }
        
        return Transform.scale(
          scale: scale,
          child: CustomPaint(
            size: const Size(200, 300),
            painter: Enhanced3DGamisPainter(
              fashionItem: widget.fashionItem!,
              isManualMode: widget.isManualMode,
              animationValue: _pulseAnimation.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSafeModelViewer() {
    // Show loading state first
    if (!_modelViewerReady || !_showModelViewer) {
      return _buildFallbackView();
    }

    // If ModelViewer failed or timed out, use simple viewer
    if (_modelViewerFailed || _loadingTimeout || !widget.useModelViewer) {
      return SimpleGLBViewer(
        fashionItem: widget.fashionItem!,
        isManualMode: widget.isManualMode,
        animationValue: _pulseAnimation.value,
      );
    }

    try {
      return ModelViewer(
        backgroundColor: Colors.transparent,
        src: widget.fashionItem!.modelPath,
        alt: "3D Model of ${widget.fashionItem!.name}",
        ar: false,
        autoRotate: !widget.isManualMode,
        cameraControls: widget.isManualMode,
        disableZoom: !widget.isManualMode,
        shadowIntensity: 0.0, // Disable shadows for better performance with large files
        shadowSoftness: 0.0,
        cameraOrbit: "0deg 75deg 200%", // Move camera further back for better view
        fieldOfView: "45deg", // Wider field of view
        loading: Loading.eager,
        reveal: Reveal.auto,
        debugLogging: true,
        onWebViewCreated: (controller) {
          debugPrint('✅ ModelViewer WebView created successfully for ${widget.fashionItem!.modelPath}');
          debugPrint('📁 File size: ~18MB - Loading may take a moment...');
        },
      );
    } catch (e) {
      debugPrint('❌ Error creating ModelViewer: $e');
      setState(() {
        _modelViewerFailed = true;
      });
      return SimpleGLBViewer(
        fashionItem: widget.fashionItem!,
        isManualMode: widget.isManualMode,
        animationValue: _pulseAnimation.value,
      );
    }
  }

  Widget _buildFallbackView() {
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withValues(alpha: 0.3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.view_in_ar,
            size: 48,
            color: Colors.white70,
          ),
          const SizedBox(height: 8),
          const Text(
            'Loading GLB Model',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _modelViewerReady ? 'Rendering 3D...' : 'Preparing...',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'File: ${widget.fashionItem!.modelPath.split('/').last}',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '~18MB - Please wait...',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class Enhanced3DGamisPainter extends CustomPainter {
  final FashionItem fashionItem;
  final bool isManualMode;
  final double animationValue;

  Enhanced3DGamisPainter({
    required this.fashionItem,
    required this.isManualMode,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      _drawEnhanced3DGamis(canvas, size);
      canvas.restore();
    } catch (e) {
      debugPrint('Error painting enhanced 3D gamis: $e');
      canvas.restore();
    }
  }

  void _drawEnhanced3DGamis(Canvas canvas, Size size) {
    // Get primary color (already a Color object)
    final primaryColor = fashionItem.availableColors.first;
    
    // Main dress paint
    final mainPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    // Shadow paint
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Highlight paint
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Draw shadow
    final shadowPath = Path();
    shadowPath.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(-63, 8, 126, 115),
      const Radius.circular(10),
    ));
    shadowPath.moveTo(-63, 123);
    shadowPath.quadraticBezierTo(-95, 200, -100, 290);
    shadowPath.lineTo(100, 290);
    shadowPath.quadraticBezierTo(95, 200, 63, 123);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main dress body
    final mainPath = Path();
    mainPath.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(-60, 5, 120, 110),
      const Radius.circular(8),
    ));
    
    // Skirt
    mainPath.moveTo(-60, 115);
    mainPath.quadraticBezierTo(-92, 190, -97, 285);
    mainPath.lineTo(97, 285);
    mainPath.quadraticBezierTo(92, 190, 60, 115);
    mainPath.close();

    canvas.drawPath(mainPath, mainPaint);

    // Add highlights
    final highlightPath = Path();
    highlightPath.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(-50, 15, 25, 90),
      const Radius.circular(5),
    ));
    canvas.drawPath(highlightPath, highlightPaint);

    // Add texture lines
    final texturePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Vertical texture lines
    for (int i = 0; i < 6; i++) {
      final x = -75 + (i * 25).toDouble();
      canvas.drawLine(
        Offset(x, 130),
        Offset(x - 5, 280),
        texturePaint,
      );
    }

    // Horizontal flowing lines
    for (int i = 0; i < 8; i++) {
      final y = 140 + (i * 18).toDouble();
      final curve = (i * 3).toDouble();
      canvas.drawLine(
        Offset(-85 + curve, y),
        Offset(85 - curve, y),
        texturePaint,
      );
    }

    // Add sleeves
    final sleevePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // Left sleeve
    final leftSleeve = Path();
    leftSleeve.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(-95, 20, 35, 70),
      const Radius.circular(17),
    ));
    canvas.drawPath(leftSleeve, sleevePaint);

    // Right sleeve
    final rightSleeve = Path();
    rightSleeve.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(60, 20, 35, 70),
      const Radius.circular(17),
    ));
    canvas.drawPath(rightSleeve, sleevePaint);

    // Add collar
    final collarPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      const Rect.fromLTWH(-25, 5, 50, 30),
      0,
      3.14159,
      false,
      collarPaint,
    );

    // Add decorative buttons
    final decorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(0, 40 + (i * 25).toDouble()),
        2,
        decorPaint,
      );
    }

    // Add status indicators
    _drawStatusIndicators(canvas, size);
    _drawModeIndicators(canvas, size);
  }

  void _drawStatusIndicators(Canvas canvas, Size size) {
    // GLB Badge
    final badgePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(65, -140, 30, 16),
        const Radius.circular(8),
      ),
      badgePaint,
    );

    // GLB text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'GLB',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(70, -147));

    // Status indicator - always green for CustomPaint fallback
    final statusPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(85, -110), 6, statusPaint);

    // Status icon
    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '✓',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(canvas, const Offset(82, -114));
  }

  void _drawModeIndicators(Canvas canvas, Size size) {
    // Mode badge
    final modePaint = Paint()
      ..color = isManualMode ? Colors.purple : Colors.teal
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-95, -140, 40, 16),
        const Radius.circular(8),
      ),
      modePaint,
    );

    // Mode text
    final modeTextPainter = TextPainter(
      text: TextSpan(
        text: isManualMode ? 'MANUAL' : 'AUTO',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    modeTextPainter.layout();
    modeTextPainter.paint(canvas, const Offset(-90, -147));

    // Animation indicator
    if (!isManualMode) {
      final pulsePaint = Paint()
        ..color = Colors.greenAccent.withValues(alpha: animationValue)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        const Offset(-75, -110),
        3 + (animationValue * 2),
        pulsePaint,
      );
    }

    // Control instructions
    final instructionsPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-90, 120, 180, 30),
        const Radius.circular(6),
      ),
      instructionsPaint,
    );

    final instructionsText = TextPainter(
      text: TextSpan(
        text: isManualMode 
          ? 'Pinch: Zoom • Drag: Move • Double tap: Reset'
          : 'Following body movement automatically',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    instructionsText.layout(maxWidth: 170);
    instructionsText.paint(canvas, const Offset(-85, 130));
  }

  @override
  bool shouldRepaint(Enhanced3DGamisPainter oldDelegate) {
    return oldDelegate.isManualMode != isManualMode ||
           oldDelegate.animationValue != animationValue;
  }
}

class FashionOverlayPainter extends CustomPainter {
  final FashionItem fashionItem;
  final vm.Matrix4 transformMatrix;

  FashionOverlayPainter({
    required this.fashionItem,
    required this.transformMatrix,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      canvas.save();
      final Matrix4 matrix = Matrix4.fromFloat64List(transformMatrix.storage);
      canvas.transform(matrix.storage);

      switch (fashionItem.category) {
        case FashionCategory.hijabs:
          _drawHijab(canvas, size);
          break;
        case FashionCategory.shirts:
          _drawShirt(canvas, size);
          break;
        case FashionCategory.jackets:
          _drawJacket(canvas, size);
          break;
        case FashionCategory.dresses:
          _drawDress(canvas, size);
          break;
        case FashionCategory.accessories:
          _drawAccessory(canvas, size);
          break;
      }

      canvas.restore();
    } catch (e) {
      debugPrint('Error painting fashion overlay: $e');
      canvas.restore();
    }
  }

  void _drawHijab(Canvas canvas, Size size) {
    final primaryColor = fashionItem.availableColors.first;
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.addOval(Rect.fromCenter(
      center: const Offset(0, -40),
      width: 160,
      height: 120,
    ));
    
    path.moveTo(-80, 20);
    path.quadraticBezierTo(-100, 60, -120, 100);
    path.lineTo(120, 100);
    path.quadraticBezierTo(100, 60, 80, 20);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawShirt(Canvas canvas, Size size) {
    final primaryColor = fashionItem.availableColors.first;
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(-60, 0, 120, 150),
      const Radius.circular(10),
    ));
    
    path.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(-90, 10, 30, 80),
      const Radius.circular(15),
    ));
    path.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(60, 10, 30, 80),
      const Radius.circular(15),
    ));

    canvas.drawPath(path, paint);
  }

  void _drawJacket(Canvas canvas, Size size) {
    final primaryColor = fashionItem.availableColors.first;
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(-70, 0, 140, 160),
      const Radius.circular(12),
    ));
    
    path.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(-100, 5, 35, 90),
      const Radius.circular(17),
    ));
    path.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(65, 5, 35, 90),
      const Radius.circular(17),
    ));

    canvas.drawPath(path, paint);

    final detailPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(0, 20 + (i * 30).toDouble()),
        3,
        detailPaint,
      );
    }
  }

  void _drawDress(Canvas canvas, Size size) {
    final primaryColor = fashionItem.availableColors.first;
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(-60, 0, 120, 100),
      const Radius.circular(8),
    ));
    
    path.moveTo(-60, 100);
    path.lineTo(-90, 280);
    path.lineTo(90, 280);
    path.lineTo(60, 100);
    path.close();

    canvas.drawPath(path, paint);

    if (fashionItem.name.contains('Tes Custom')) {
      final detailPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawLine(
        const Offset(-50, 50),
        const Offset(50, 50),
        detailPaint,
      );
      
      canvas.drawLine(
        const Offset(-40, 150),
        const Offset(40, 150),
        detailPaint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '3D',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, const Offset(-6, 200));
    }
  }

  void _drawAccessory(Canvas canvas, Size size) {
    final primaryColor = fashionItem.availableColors.first;
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      const Offset(0, 0),
      8,
      paint,
    );

    final patternPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(
      const Offset(0, 0),
      5,
      patternPaint,
    );
  }

  @override
  bool shouldRepaint(FashionOverlayPainter oldDelegate) {
    return oldDelegate.fashionItem != fashionItem ||
           oldDelegate.transformMatrix != transformMatrix;
  }
}