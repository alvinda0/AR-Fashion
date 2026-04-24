import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/image_target_service.dart';
import '../services/data_cache_service.dart';
import '../config/supabase_config.dart';

class ImageTargetScreen extends StatefulWidget {
  const ImageTargetScreen({super.key});

  @override
  State<ImageTargetScreen> createState() => _ImageTargetScreenState();
}

class _ImageTargetScreenState extends State<ImageTargetScreen> {
  final ImageTargetService _service = ImageTargetService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<ImageTarget> _imageTargets = [];
  List<String> _availableModels = [];
  String? _selectedModelUrl;
  bool _isLoading = true;
  bool _isLoadingModels = false;

  @override
  void initState() {
    super.initState();
    _loadImageTargetsFromCache();
    _loadAvailableModelsFromCache();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _refreshData() async {
    debugPrint('🔄 Refreshing data from Supabase...');
    
    try {
      // Refresh cache dari Supabase
      await DataCacheService().refreshData();
      
      // Update UI dengan data terbaru dari cache
      setState(() {
        _imageTargets = DataCacheService().imageTargets;
        _availableModels = DataCacheService().models;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diperbarui'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      debugPrint('✅ Data refreshed successfully');
    } catch (e) {
      debugPrint('❌ Error refreshing data: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadImageTargetsFromCache() async {
    // Gunakan data dari cache yang sudah di-fetch saat app start
    final cacheService = DataCacheService();
    
    if (cacheService.hasCachedData) {
      // Data sudah ada di cache, langsung gunakan tanpa loading
      setState(() {
        _imageTargets = cacheService.imageTargets;
        _isLoading = false;
      });
      debugPrint('✅ Loaded ${_imageTargets.length} image targets from cache (instant!)');
      return;
    }
    
    // Fallback: jika cache kosong, fetch dari Supabase
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
      debugPrint('✅ Loaded ${_imageTargets.length} image targets from Supabase');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error loading image targets:\n$e');
    }
  }
  
  Future<void> _loadAvailableModelsFromCache() async {
    // Gunakan data dari cache yang sudah di-fetch saat app start
    final cacheService = DataCacheService();
    
    if (cacheService.models.isNotEmpty) {
      // Data sudah ada di cache, langsung gunakan tanpa loading
      setState(() {
        _availableModels = cacheService.models;
        _isLoadingModels = false;
      });
      debugPrint('✅ Loaded ${_availableModels.length} models from cache (instant!)');
      return;
    }
    
    // Fallback: jika cache kosong, fetch dari Supabase
    setState(() => _isLoadingModels = true);
    try {
      if (!SupabaseConfig.isInitialized) {
        setState(() => _isLoadingModels = false);
        return;
      }
      
      // Get list of files from ar-fashion-glb bucket
      final files = await SupabaseConfig.client.storage
          .from('ar-fashion-glb')
          .list();
      
      final models = files
          .where((file) => file.name.endsWith('.glb'))
          .map((file) {
            final url = SupabaseConfig.client.storage
                .from('ar-fashion-glb')
                .getPublicUrl(file.name);
            return url;
          })
          .toList();
      
      setState(() {
        _availableModels = models;
        _isLoadingModels = false;
      });
      
      debugPrint('✅ Loaded ${_availableModels.length} models from ar-fashion-glb');
    } catch (e) {
      setState(() => _isLoadingModels = false);
      debugPrint('❌ Error loading models: $e');
    }
  }

  void _showUploadDialog() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    // Reset selected model
    _selectedModelUrl = null;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
              child: SingleChildScrollView(
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
                      'Masukkan nama, pilih model 3D, dan gambar untuk image target',
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
                    
                    SizedBox(height: isTablet ? 20 : 16),
                    
                    // Description input field
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi (Opsional)',
                        hintText: 'Contoh: Sepatu olahraga warna hitam',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    
                    SizedBox(height: isTablet ? 24 : 16),
                    
                    // Model 3D Dropdown
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoadingModels
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Loading models...',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              initialValue: _selectedModelUrl,
                              decoration: InputDecoration(
                                labelText: 'Pilih Model 3D',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                prefixIcon: const Icon(Icons.view_in_ar),
                              ),
                              hint: Text(
                                _availableModels.isEmpty
                                    ? 'Tidak ada model tersedia'
                                    : 'Pilih model 3D (opsional)',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                              items: _availableModels.map((url) {
                                final fileName = url.split('/').last;
                                final displayName = fileName
                                    .replaceAll('.glb', '')
                                    .replaceAll('_', ' ')
                                    .split(' ')
                                    .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
                                    .join(' ');
                                
                                return DropdownMenuItem<String>(
                                  value: url,
                                  child: Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setModalState(() {
                                  _selectedModelUrl = value;
                                });
                              },
                            ),
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
                          _pickAndUploadImage(
                            _nameController.text,
                            _selectedModelUrl,
                            _descriptionController.text.isEmpty 
                                ? null 
                                : _descriptionController.text,
                          );
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
                          _descriptionController.clear();
                          _selectedModelUrl = null;
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
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(String name, String? modelUrl, String? description) async {
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

        // Create image target with model URL
        final imageTarget = ImageTarget(
          name: name,
          imageTarget: imageUrl,
          modelUrl: modelUrl,
          description: description,
          createdAt: DateTime.now(),
        );

        // Save to database
        await _service.saveImageTarget(imageTarget);
        
        // Tambahkan ke cache agar langsung muncul tanpa perlu reload
        DataCacheService().addImageTargetToCache(imageTarget);

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Clear name controller
        _nameController.clear();
        _descriptionController.clear();
        _selectedModelUrl = null;

        // Reload list dari cache (instant, no loading)
        await _loadImageTargetsFromCache();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                modelUrl != null
                    ? 'Image target "$name" dengan model 3D berhasil diupload!'
                    : 'Image target "$name" berhasil diupload!',
              ),
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
        
        // Hapus dari cache agar langsung hilang tanpa perlu reload
        DataCacheService().removeImageTargetFromCache(target.id!);
        
        await _loadImageTargetsFromCache();
        
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
      backgroundColor: const Color(0xFF00796B), // Set background color untuk Scaffold
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
        width: double.infinity, // Pastikan container full width
        height: double.infinity, // Pastikan container full height
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
                  ? RefreshIndicator(
                      onRefresh: _refreshData,
                      color: const Color(0xFF00796B),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 200,
                          child: _buildEmptyState(isTablet),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshData,
                      color: const Color(0xFF00796B),
                      child: GridView.builder(
                        padding: EdgeInsets.only(
                          left: isTablet ? 24 : 16,
                          right: isTablet ? 24 : 16,
                          top: isTablet ? 24 : 16,
                          bottom: isTablet ? 24 : 16,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Ubah dari 3 menjadi 2 kolom untuk semua ukuran layar
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
        ],
      ),
    );
  }

  Widget _buildImageCard(ImageTarget target, bool isTablet) {
    return Container(
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          target.name,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (target.modelUrl != null && target.modelUrl!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00796B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.view_in_ar,
                            size: 14,
                            color: Color(0xFF00796B),
                          ),
                        ),
                    ],
                  ),
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
    );
  }
}
