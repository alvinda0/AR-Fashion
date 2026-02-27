import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00796B),
              Color(0xFF26A69A),
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
                        ? _buildLandscapeLayout(isTablet)
                        : _buildPortraitLayout(isTablet),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(bool isTablet) {
    final logoSize = isTablet ? 120.0 : 100.0;
    final titleSize = isTablet ? 32.0 : 28.0;
    final subtitleSize = isTablet ? 18.0 : 16.0;
    final bodyTextSize = isTablet ? 16.0 : 14.0;
    final sectionTitleSize = isTablet ? 22.0 : 20.0;
    
    return Column(
      children: [
        // App logo and title
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
        
        SizedBox(height: isTablet ? 32 : 24),
        
        Text(
          'AR Fashion',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: isTablet ? 12 : 8),
        
        Text(
          'Virtual Fashion 3D Experience',
          style: TextStyle(
            fontSize: subtitleSize,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: isTablet ? 40 : 32),
        
        // About the app section
        _buildInfoSection(
          'Tentang Aplikasi',
          'AR Fashion adalah aplikasi yang memungkinkan Anda untuk melihat produk fashion dalam bentuk 3D secara virtual menggunakan teknologi AR (Augmented Reality). Scan gambar produk untuk melihat model 3D yang detail dan interaktif.',
          sectionTitleSize,
          bodyTextSize,
          isTablet,
        ),
        
        SizedBox(height: isTablet ? 32 : 24),
        
        // Developer info section
        _buildInfoSection(
          'Pembuat Aplikasi',
          'Aplikasi ini dikembangkan oleh:\n\nAlvinda Shahrul\nNIM: 191011450055\nProgram Studi: Teknik Informatika\n\nDikembangkan sebagai bagian dari proyek tugas akhir untuk memberikan solusi inovatif dalam berbelanja fashion menggunakan teknologi AR dan visualisasi 3D.',
          sectionTitleSize,
          bodyTextSize,
          isTablet,
        ),
        
        SizedBox(height: isTablet ? 32 : 24),
        
        // Features section
        _buildInfoSection(
          'Fitur Utama',
          '• AR Camera - Scan gambar produk untuk melihat model 3D\n• Image Recognition - Deteksi otomatis produk dari gambar\n• 3D Model Viewer - Lihat detail produk dari berbagai sudut\n• Gallery - Koleksi lengkap produk fashion\n• Tutorial - Panduan penggunaan aplikasi\n• Responsive Design - Optimal di semua perangkat',
          sectionTitleSize,
          bodyTextSize,
          isTablet,
        ),
        
        SizedBox(height: isTablet ? 40 : 32),
        
        // Version info
        Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.white70,
                size: isTablet ? 32 : 24,
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'Versi 1.0.0',
                style: TextStyle(
                  fontSize: bodyTextSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isTablet ? 8 : 4),
              Text(
                '© 2026 AR Fashion',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: isTablet ? 24 : 16),
      ],
    );
  }

  Widget _buildLandscapeLayout(bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Logo and basic info
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.headset_mic,
                        size: 40,
                        color: Color(0xFF00796B),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'AR Fashion',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Virtual Fashion 3D Experience',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white70,
                      size: 24,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Versi 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '© 2026 AR Fashion',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 32),
        
        // Right side - Detailed info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(
                'Tentang Aplikasi',
                'AR Fashion adalah aplikasi yang memungkinkan Anda melihat produk fashion dalam bentuk 3D secara virtual. Scan gambar produk untuk melihat model 3D yang detail dan interaktif.',
                18,
                13,
                false,
              ),
              
              const SizedBox(height: 20),
              
              _buildInfoSection(
                'Pembuat Aplikasi',
                'Alvinda Shahrul\nNIM: 191011450055\nTeknik Informatika',
                18,
                13,
                false,
              ),
              
              const SizedBox(height: 20),
              
              _buildInfoSection(
                'Fitur Utama',
                '• AR Camera • Image Recognition • 3D Model Viewer • Gallery • Tutorial',
                18,
                13,
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content, double titleSize, double contentSize, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            content,
            style: TextStyle(
              fontSize: contentSize,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}