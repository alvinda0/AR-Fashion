import 'package:flutter/material.dart';

class BodyTrackingScreen extends StatelessWidget {
  const BodyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 48 : 24,
                vertical: isTablet ? 32 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: isTablet ? 100 : 80,
                          height: isTablet ? 100 : 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(isTablet ? 50 : 40),
                          ),
                          child: Icon(
                            Icons.menu_book,
                            size: isTablet ? 50 : 40,
                            color: Colors.white,
                          ),
                        ),
                        
                        SizedBox(height: isTablet ? 24 : 16),
                        
                        Text(
                          'Panduan Penggunaan',
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: isTablet ? 12 : 8),
                        
                        Text(
                          'Ikuti langkah-langkah berikut untuk menggunakan aplikasi',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 40 : 32),
                  
                  // Tutorial steps
                  _buildTutorialStep(
                    1,
                    'Memulai AR Camera',
                    'Pilih menu "AR Camera" dari halaman utama. Aplikasi akan meminta izin untuk menggunakan kamera perangkat Anda.',
                    Icons.camera_alt,
                    isTablet,
                  ),
                  
                  SizedBox(height: isTablet ? 24 : 20),
                  
                  _buildTutorialStep(
                    2,
                    'Posisikan Kamera',
                    'Arahkan kamera ke wajah Anda dengan pencahayaan yang cukup. Pastikan wajah terlihat jelas dalam frame kamera.',
                    Icons.face,
                    isTablet,
                  ),
                  
                  SizedBox(height: isTablet ? 24 : 20),
                  
                  _buildTutorialStep(
                    3,
                    'Pilih Hijab',
                    'Gunakan menu "Gallery" untuk memilih model hijab yang ingin dicoba. Tersedia berbagai kategori hijab yang dapat dipilih.',
                    Icons.photo_library,
                    isTablet,
                  ),
                  
                  SizedBox(height: isTablet ? 24 : 20),
                  
                  _buildTutorialStep(
                    4,
                    'Coba Virtual Try-On',
                    'Hijab akan muncul secara virtual pada wajah Anda. Gerakkan kepala untuk melihat hijab dari berbagai sudut.',
                    Icons.headset_mic,
                    isTablet,
                  ),
                  
                  SizedBox(height: isTablet ? 24 : 20),
                  
                  _buildTutorialStep(
                    5,
                    'Ganti Model Hijab',
                    'Anda dapat mengganti model hijab kapan saja dengan memilih dari galeri yang tersedia tanpa keluar dari mode AR.',
                    Icons.swap_horiz,
                    isTablet,
                  ),
                  
                  SizedBox(height: isTablet ? 40 : 32),
                  
                  // Tips section
                  Container(
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
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.amber,
                              size: isTablet ? 24 : 20,
                            ),
                            SizedBox(width: isTablet ? 12 : 8),
                            Text(
                              'Tips Penggunaan',
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: isTablet ? 16 : 12),
                        
                        _buildTipItem('Gunakan pencahayaan yang cukup untuk hasil terbaik', isTablet),
                        _buildTipItem('Pastikan wajah berada di tengah frame kamera', isTablet),
                        _buildTipItem('Jaga jarak sekitar 30-50 cm dari kamera', isTablet),
                        _buildTipItem('Hindari gerakan yang terlalu cepat saat mencoba hijab', isTablet),
                        _buildTipItem('Eksplorasi berbagai kategori hijab di Gallery', isTablet),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 24 : 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialStep(int stepNumber, String title, String description, IconData icon, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: isTablet ? 40 : 32,
            height: isTablet ? 40 : 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3C72),
                ),
              ),
            ),
          ),
          
          SizedBox(width: isTablet ? 16 : 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: isTablet ? 20 : 18,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isTablet ? 8 : 6),
                
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 6 : 4,
            height: isTablet ? 6 : 4,
            margin: EdgeInsets.only(top: isTablet ? 8 : 6, right: isTablet ? 12 : 8),
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                color: Colors.white70,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}