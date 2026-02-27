import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
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
                    'Scan Gambar Produk',
                    'Arahkan kamera ke gambar/poster produk fashion. Aplikasi akan otomatis mendeteksi produk dari gambar atau teks yang terlihat.',
                    Icons.qr_code_scanner,
                    isTablet,
                  ),
                  
                  SizedBox(height: isTablet ? 24 : 20),
                  
                  _buildTutorialStep(
                    3,
                    'Loading Model 3D',
                    'Setelah produk terdeteksi, model 3D akan dimuat secara otomatis. Progress loading akan ditampilkan pada item di list bawah.',
                    Icons.downloading,
                    isTablet,
                  ),
                  
                  SizedBox(height: isTablet ? 24 : 20),
                  
                  _buildTutorialStep(
                    4,
                    'Lihat Model 3D',
                    'Model 3D produk akan muncul di layar penuh. Anda dapat memutar, zoom, dan melihat detail produk dari berbagai sudut.',
                    Icons.view_in_ar,
                    isTablet,
                  ),
                  
                  SizedBox(height: isTablet ? 24 : 20),
                  
                  _buildTutorialStep(
                    5,
                    'Pilih Produk Lain',
                    'Tap item di list bawah untuk melihat produk lain, atau tap tombol refresh untuk scan produk baru.',
                    Icons.collections,
                    isTablet,
                  ),
                  
                  SizedBox(height: isTablet ? 24 : 20),
                  
                  _buildTutorialStep(
                    6,
                    'Lihat Detail Produk',
                    'Tap tombol info (i) untuk melihat deskripsi lengkap, harga, dan detail produk.',
                    Icons.info_outline,
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
                        
                        _buildTipItem('Gunakan pencahayaan yang cukup agar gambar produk terdeteksi dengan baik', isTablet),
                        _buildTipItem('Pastikan gambar/poster produk terlihat jelas dalam frame kamera', isTablet),
                        _buildTipItem('Jaga jarak yang cukup agar seluruh gambar produk terlihat', isTablet),
                        _buildTipItem('Tunggu hingga model 3D selesai loading untuk hasil terbaik', isTablet),
                        _buildTipItem('Gunakan 2 jari untuk zoom dan 1 jari untuk memutar model 3D', isTablet),
                        _buildTipItem('Tap tombol refresh untuk scan produk baru setelah melihat model', isTablet),
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
                  color: const Color(0xFF00796B),
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