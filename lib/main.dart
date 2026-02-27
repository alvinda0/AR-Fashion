import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/ar_camera_screen.dart';
import 'screens/tutorial_screen.dart';
import 'screens/about_screen.dart';
import 'screens/gallery_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Skip fashion data service initialization for now
  // await FashionDataService().initialize();
  
  runApp(const FashionARApp());
}

class FashionARApp extends StatelessWidget {
  const FashionARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vast Hijab Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _navigateToARCamera() async {

    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      
      if (cameraStatus.isGranted) {
        // Navigate to AR Camera V2
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ARCameraScreen(),
            ),
          );
        }
      } else {
        _showPermissionDialog();
      }
    } catch (e) {
      _showErrorDialog('Error requesting permissions: $e');
    }
  }

  void _navigateToBodyTracking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TutorialScreen(),
      ),
    );
  }

  void _navigateToGallery() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GalleryScreen(),
      ),
    );
  }

  void _navigateToAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Camera permission is required to use AR features. '
          'Please grant permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00796B), // Teal primary
              Color(0xFF26A69A), // Teal lighter
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 48 : 24,
                      vertical: isLandscape ? 16 : 24,
                    ),
                    child: isLandscape && !isTablet
                        ? _buildLandscapeLayout(screenSize)
                        : _buildPortraitLayout(screenSize, isTablet),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(Size screenSize, bool isTablet) {
    final logoSize = isTablet ? 150.0 : 120.0;
    final titleSize = isTablet ? 40.0 : 32.0;
    final subtitleSize = isTablet ? 20.0 : 16.0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // App logo/icon
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(logoSize / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(logoSize / 2),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.headset_mic,
                  size: logoSize * 0.5,
                  color: const Color(0xFF00796B),
                );
              },
            ),
          ),
        ),
        
        SizedBox(height: isTablet ? 40 : 32),
        
        // App title
        Text(
          'Vast Hijab Store',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: isTablet ? 12 : 8),
        
        Text(
          'Virtual Hijab Try-On Experience',
          style: TextStyle(
            fontSize: subtitleSize,
            color: Colors.white70,
          ),
        ),
        
        SizedBox(height: isTablet ? 60 : 48),
        
        // Features list
        ..._buildFeaturesList(isTablet),
        
        SizedBox(height: isTablet ? 60 : 48),
        
        // Info text
        _buildInfoText(isTablet),
      ],
    );
  }

  Widget _buildLandscapeLayout(Size screenSize) {
    return Row(
      children: [
        // Left side - Logo and title
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.headset_mic,
                        size: 50,
                        color: Color(0xFF00796B),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Vast Hijab Store',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Virtual Hijab Try-On Experience',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 32),
        
        // Right side - Features and button
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._buildFeaturesList(false),
              
              const SizedBox(height: 32),
              
              _buildInfoText(false),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeaturesList(bool isTablet) {
    final features = [
      {
        'icon': Icons.camera_alt,
        'title': 'AR Camera',
        'description': 'Gunakan kamera untuk melihat hijab dalam AR',
        'onTap': _navigateToARCamera,
      },
      {
        'icon': Icons.play_circle_outline,
        'title': 'Tutorial',
        'description': 'Panduan',
        'onTap': _navigateToBodyTracking,
      },
      {
        'icon': Icons.photo_library,
        'title': 'Gallery',
        'description': 'Koleksi lengkap hijab, jilbab, dan aksesoris muslim',
        'onTap': _navigateToGallery,
      },
      {
        'icon': Icons.info_outline,
        'title': 'About',
        'description': 'Informasi tentang aplikasi dan pembuat',
        'onTap': _navigateToAbout,
      },
    ];

    return features.map((feature) {
      return Padding(
        padding: EdgeInsets.only(bottom: isTablet ? 20 : 16),
        child: _buildFeatureItem(
          feature['icon'] as IconData,
          feature['title'] as String,
          feature['description'] as String,
          feature['onTap'] as VoidCallback,
          isTablet,
        ),
      );
    }).toList();
  }

  Widget _buildInfoText(bool isTablet) {
    return Text(
      'Pastikan Anda berada di tempat dengan pencahayaan yang cukup',
      style: TextStyle(
        fontSize: isTablet ? 14 : 12,
        color: Colors.white.withValues(alpha: 0.8),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, VoidCallback onTap, bool isTablet) {
    final iconSize = isTablet ? 56.0 : 48.0;
    final titleSize = isTablet ? 18.0 : 16.0;
    final descSize = isTablet ? 14.0 : 12.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: const Color(0xFF00796B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(iconSize / 2),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00796B),
                size: iconSize * 0.5,
              ),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: descSize,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF00796B),
              size: isTablet ? 20 : 16,
            ),
          ],
        ),
      ),
    );
  }
}
