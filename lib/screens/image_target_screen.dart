import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/image_target_service.dart';
import '../config/supabase_config.dart';

class ImageTargetScreen extends StatefulWidget {
  const ImageTargetScreen({super.key});

  @override
  State<ImageTargetScreen> createState() => _ImageTargetScreenState();
}

class _ImageTargetScreenState extends State<ImageTargetScreen> {
  final ImageTargetService _service = ImageTargetService();
  final TextEditingController _nameController = TextEditingController();
  List<ImageTarget> _imageTargets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImageTargets();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadImageTargets() async {
    setState(() => _isLoading = true);
    try {
      if (!SupabaseConfig.isInitialized) {
        setState(() => _isLoading = false);
        _showErrorDialog(
          'Supabase belum diinisialisasi.\n\n'
          'Pastikan:\n'
          '1. Internet connection aktif\n'
          '2. Supabase credentials benar\n'
          '3. Restart aplikasi'
        );
        return;
      }
      
      final targets = await _service.getImageTargets();
      setState(() {
        _imageTargets = targets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error loading image targets:\n$e');
    }
  }

  void _showUploadDialog() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: isTablet ? 32 : 20,
              right: isTablet ? 32 : 20,
              top: isTablet ? 24 : 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + (isTablet ? 24 : 16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: isTablet ? 16 : 12),
                Container(
                  width: isTablet ? 60 : 40,
                  height: isTablet ? 6 : 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                SizedBox(height: isTablet ? 28 : 20),
                Text(
                  'Upload Image Target',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Text(
                  'Masukkan nama dan pilih gambar untuk image target',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: const Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 32 : 24),
                
                // Name input field
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Image Target',
                    hintText: 'Contoh: Product 1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.label),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                
                SizedBox(height: isTablet ? 24 : 16),
                
                // Upload button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_nameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama image target harus diisi'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      _pickAndUploadImage(_nameController.text);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Pilih Gambar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00796B),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, isTablet ? 56 : 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: isTablet ? 16 : 12),
                
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      _nameController.clear();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size(double.infinity, isTablet ? 56 : 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: isTablet ? 16 : 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(String name) async {
    try {
      // Check Supabase initialization
      if (!SupabaseConfig.isInitialized) {
        _showErrorDialog(
          'Supabase belum diinisialisasi.\n\n'
          'Pastikan internet connection aktif dan restart aplikasi.'
        );
        return;
      }
      
      // Pick image file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading to Supabase...'),
              ],
            ),
          ),
        );
      }

      try {
        // Upload image to Supabase
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final imageFileName = '${timestamp}_$fileName';
        final imageUrl = await _service.uploadImageToSupabase(
          file,
          imageFileName,
        );

        // Create image target
        final imageTarget = ImageTarget(
          name: name,
          imageTarget: imageUrl,
          createdAt: DateTime.now(),
        );

        // Save to database
        await _service.saveImageTarget(imageTarget);

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Clear name controller
        _nameController.clear();

        // Reload list
        await _loadImageTargets();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image target "$name" berhasil diupload!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }
        _showErrorDialog('Error uploading to Supabase: $e');
      }
    } catch (e) {
      _showErrorDialog('Error picking file: $e');
    }
  }

  Future<void> _deleteImageTarget(ImageTarget target) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Image Target'),
        content: Text('Apakah Anda yakin ingin menghapus "${target.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && target.id != null) {
      try {
        await _service.deleteImageTarget(target.id!, target.imageTarget);
        await _loadImageTargets();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image target "${target.name}" berhasil dihapus'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        _showErrorDialog('Error deleting image target: $e');
      }
    }
  }

  void _showImagePreview(ImageTarget target) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(target.name),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Image.network(
                    target.imageTarget,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ID: ${target.id}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (target.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Uploaded: ${target.createdAt!.day}/${target.createdAt!.month}/${target.createdAt!.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Target'),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Upload'),
              onPressed: _showUploadDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00796B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : _imageTargets.isEmpty
                  ? _buildEmptyState(isTablet)
                  : Column(
                      children: [
                        // Info banner
                        Container(
                          margin: EdgeInsets.all(isTablet ? 24 : 16),
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: isTablet ? 24 : 20,
                              ),
                              SizedBox(width: isTablet ? 16 : 12),
                              Expanded(
                                child: Text(
                                  'Klik tombol "Upload" di header untuk menambah image target baru',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Image targets grid
                        Expanded(
                          child: GridView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 16,
                            ),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isTablet ? 3 : 2,
                              crossAxisSpacing: isTablet ? 16 : 12,
                              mainAxisSpacing: isTablet ? 16 : 12,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: _imageTargets.length,
                            itemBuilder: (context, index) {
                              final target = _imageTargets[index];
                              return _buildImageCard(target, isTablet);
                            },
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: isTablet ? 80 : 64,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Belum ada image target',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Klik tombol "Upload" di header untuk memulai',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(ImageTarget target, bool isTablet) {
    return GestureDetector(
      onTap: () => _showImagePreview(target),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  target.imageTarget,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Info
            Padding(
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    target.name,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (target.createdAt != null) ...[
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      '${target.createdAt!.day}/${target.createdAt!.month}/${target.createdAt!.year}',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    iconSize: isTablet ? 24 : 20,
                    onPressed: () => _deleteImageTarget(target),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
