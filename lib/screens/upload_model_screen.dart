import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/custom_model_service.dart';
import '../services/data_cache_service.dart';
import '../config/supabase_config.dart';

class UploadModelScreen extends StatefulWidget {
  const UploadModelScreen({super.key});

  @override
  State<UploadModelScreen> createState() => _UploadModelScreenState();
}

class _UploadModelScreenState extends State<UploadModelScreen> {
  final CustomModelService _modelService = CustomModelService();
  List<CustomModel> _customModels = [];
  List<Map<String, String>> _fashionModels = [];
  bool _isLoading = true;
  bool _isLoadingFashionModels = false;

  @override
  void initState() {
    super.initState();
    _loadCustomModelsFromCache();
    _loadFashionModelsFromCache();
  }

  Future<void> _loadCustomModelsFromCache() async {
    // Gunakan data dari cache yang sudah di-fetch saat app start
    final cacheService = DataCacheService();
    
    if (cacheService.hasCustomModels) {
      // Data sudah ada di cache, langsung gunakan tanpa loading
      setState(() {
        _customModels = cacheService.customModels;
        _isLoading = false;
      });
      debugPrint('✅ Upload Model: Loaded ${_customModels.length} custom models from cache (instant!)');
      return;
    }
    
    // Fallback: jika cache kosong, fetch dari Supabase
    await _loadCustomModels();
  }
  
  Future<void> _loadFashionModelsFromCache() async {
    final cacheService = DataCacheService();
    
    if (cacheService.hasFashionModels) {
      setState(() {
        _fashionModels = cacheService.fashionModels;
        _isLoadingFashionModels = false;
      });
      debugPrint('✅ Upload Model: Loaded ${_fashionModels.length} fashion models from cache (instant!)');
      return;
    }
    
    await _loadFashionModels();
  }

  Future<void> _loadCustomModels() async {
    setState(() => _isLoading = true);
    try {
      final models = await _modelService.getCustomModels();
      setState(() {
        _customModels = models;
        _isLoading = false;
      });
      debugPrint('✅ Upload Model: Loaded ${_customModels.length} custom models from Supabase');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error loading models: $e');
    }
  }
  
  Future<void> _loadFashionModels() async {
    setState(() => _isLoadingFashionModels = true);
    try {
      // Import Supabase config
      final supabase = SupabaseConfig.client;
      
      // Get list of files from ar-fashion-glb bucket
      final files = await supabase.storage
          .from('ar-fashion-glb')
          .list();
      
      final models = files
          .where((file) => file.name.endsWith('.glb'))
          .map((file) {
            final url = supabase.storage
                .from('ar-fashion-glb')
                .getPublicUrl(file.name);
            
            // Format display name
            final displayName = file.name
                .replaceAll('.glb', '')
                .replaceAll('_', ' ')
                .split(' ')
                .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
                .join(' ');
            
            return {
              'name': displayName,
              'fileName': file.name,
              'url': url,
              'size': file.metadata?['size']?.toString() ?? '0',
            };
          })
          .toList();
      
      setState(() {
        _fashionModels = models;
        _isLoadingFashionModels = false;
      });
      
      debugPrint('✅ Loaded ${_fashionModels.length} fashion models from ar-fashion-glb');
    } catch (e) {
      setState(() => _isLoadingFashionModels = false);
      debugPrint('❌ Error loading fashion models: $e');
    }
  }

  void _showUploadOptions() {
    // Tampilkan popup untuk pilih file GLB
    _showUploadDialog();
  }
  
  Future<void> _showUploadDialog() async {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _UploadDialogContent(
        isTablet: isTablet,
        onFileSelected: (file, fileName) async {
          Navigator.pop(context);
          await _uploadSelectedFile(file, fileName);
        },
      ),
    );
  }

  Future<void> _uploadSelectedFile(File file, String fileName) async {
    try {
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
        // Upload directly to ar-fashion-glb bucket
        final supabase = SupabaseConfig.client;
        final bytes = await file.readAsBytes();
        
        await supabase.storage
            .from('ar-fashion-glb')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                upsert: false,
              ),
            );

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Refresh fashion models list
        await _loadFashionModels();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Model "$fileName" berhasil diupload!'),
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
      _showErrorDialog('Error processing file: $e');
    }
  }

  Future<void> _deleteModel(CustomModel model) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Model'),
        content: Text('Apakah Anda yakin ingin menghapus "${model.name}"?'),
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

    if (confirm == true) {
      try {
        await _modelService.deleteCustomModel(model.id);
        
        // Hapus dari cache agar langsung hilang tanpa perlu reload
        DataCacheService().removeCustomModelFromCache(model.id);
        
        await _loadCustomModelsFromCache();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Model "${model.name}" berhasil dihapus'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        _showErrorDialog('Error deleting model: $e');
      }
    }
  }
  
  Future<void> _deleteFashionModel(Map<String, String> model) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Model Fashion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menghapus "${model['name']}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'File akan dihapus dari Supabase storage ar-fashion-glb',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

    if (confirm == true) {
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
                Text('Menghapus dari Supabase...'),
              ],
            ),
          ),
        );
      }
      
      try {
        final supabase = SupabaseConfig.client;
        
        // Delete from ar-fashion-glb bucket
        await supabase.storage
            .from('ar-fashion-glb')
            .remove([model['fileName']!]);
        
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }
        
        // Hapus dari cache agar langsung hilang tanpa perlu reload
        DataCacheService().removeFashionModelFromCache(model['fileName']!);
        
        // Reload fashion models dari cache (instant, no loading)
        await _loadFashionModelsFromCache();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Model "${model['name']}" berhasil dihapus dari Supabase'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }
        _showErrorDialog('Error deleting fashion model: $e');
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

  void _showModelInfo(CustomModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(model.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('ID', model.id),
              const SizedBox(height: 8),
              _buildInfoRow('File', model.filePath.split('/').last),
              const SizedBox(height: 8),
              if (model.description != null && model.description!.isNotEmpty) ...[
                _buildInfoRow('Deskripsi', model.description!),
                const SizedBox(height: 8),
              ],
              if (model.fileSize != null) ...[
                _buildInfoRow('Ukuran', '${(model.fileSize! / 1024 / 1024).toStringAsFixed(2)} MB'),
                const SizedBox(height: 8),
              ],
              _buildInfoRow(
                'Diupload',
                '${model.uploadedAt.day}/${model.uploadedAt.month}/${model.uploadedAt.year}',
              ),
              const SizedBox(height: 8),
              if (model.supabaseModelUrl != null) ...[
                _buildInfoRow('Supabase URL', model.supabaseModelUrl!, isUrl: true),
                const SizedBox(height: 8),
              ],
              if (model.imageTargetPath != null) ...[
                _buildInfoRow('Image Target', 'Ada'),
                const SizedBox(height: 8),
              ],
              if (model.supabaseImageUrl != null) ...[
                _buildInfoRow('Image URL', model.supabaseImageUrl!, isUrl: true),
                const SizedBox(height: 8),
              ],
              _buildInfoRow('Local Path', model.filePath),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isUrl = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Model 3D'),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Upload'),
              onPressed: _showUploadOptions,
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
              : _customModels.isEmpty && _fashionModels.isEmpty
                  ? _buildEmptyState(isTablet)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: isTablet ? 24 : 16),
                                
                                // Fashion Models Section (from ar-fashion-glb)
                                if (_isLoadingFashionModels) ...[
                            Padding(
                              padding: EdgeInsets.all(isTablet ? 24 : 16),
                              child: Center(
                                child: Column(
                                  children: [
                                    const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: isTablet ? 16 : 12),
                                    Text(
                                      'Loading fashion models...',
                                      style: TextStyle(
                                        fontSize: isTablet ? 14 : 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else if (_fashionModels.isNotEmpty) ...[
                            // Fashion models list
                            ..._fashionModels.map((model) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: isTablet ? 24 : 16,
                                  right: isTablet ? 24 : 16,
                                  bottom: isTablet ? 12 : 8,
                                ),
                                child: _buildFashionModelCard(model, isTablet),
                              );
                            }),
                            SizedBox(height: isTablet ? 24 : 16),
                          ],
                          
                          // Custom Models Section
                          if (_customModels.isNotEmpty) ...[
                            // Custom models list
                            ..._customModels.map((model) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: isTablet ? 24 : 16,
                                  right: isTablet ? 24 : 16,
                                  bottom: isTablet ? 16 : 12,
                                ),
                                child: _buildModelCard(model, isTablet),
                              );
                            }),
                            SizedBox(height: isTablet ? 24 : 16),
                          ],
                        ],
                      ),
                    ),
                  );
                },
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
            Icons.inventory_2_outlined,
            size: isTablet ? 80 : 64,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Belum ada model yang diupload',
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

  Widget _buildModelCard(CustomModel model, bool isTablet) {
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
      child: ListTile(
        contentPadding: EdgeInsets.all(
          isTablet ? 16 : 12,
        ),
        leading: Container(
          width: isTablet ? 56 : 48,
          height: isTablet ? 56 : 48,
          decoration: BoxDecoration(
            color: const Color(0xFF00796B)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.view_in_ar,
            color: const Color(0xFF00796B),
            size: isTablet ? 32 : 24,
          ),
        ),
        title: Text(
          model.name,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Diupload: ${model.uploadedAt.day}/${model.uploadedAt.month}/${model.uploadedAt.year}',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              color: const Color(0xFF00796B),
              onPressed: () => _showModelInfo(model),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () => _deleteModel(model),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFashionModelCard(Map<String, String> model, bool isTablet) {
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
      child: ListTile(
        contentPadding: EdgeInsets.all(
          isTablet ? 16 : 12,
        ),
        leading: Container(
          width: isTablet ? 56 : 48,
          height: isTablet ? 56 : 48,
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.checkroom,
            color: Colors.purple,
            size: isTablet ? 32 : 24,
          ),
        ),
        title: Text(
          model['name']!,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          model['fileName']!,
          style: TextStyle(
            fontSize: isTablet ? 12 : 11,
            color: Colors.grey[600],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          onPressed: () => _deleteFashionModel(model),
        ),
      ),
    );
  }
}

// Widget untuk dialog upload dengan preview file
class _UploadDialogContent extends StatefulWidget {
  final bool isTablet;
  final Function(File file, String fileName) onFileSelected;

  const _UploadDialogContent({
    required this.isTablet,
    required this.onFileSelected,
  });

  @override
  State<_UploadDialogContent> createState() => _UploadDialogContentState();
}

class _UploadDialogContentState extends State<_UploadDialogContent> {
  File? _selectedFile;
  String? _selectedFileName;
  int? _fileSize;

  Future<void> _pickFile() async {
    try {
      debugPrint('🔵 Opening file picker...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('❌ File picker cancelled or no file selected');
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Path file tidak valid'),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint('❌ File path is null');
        return;
      }

      final file = File(filePath);
      final fileName = result.files.single.name;
      
      // Validate file extension
      if (!fileName.toLowerCase().endsWith('.glb')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Hanya file GLB yang diperbolehkan'),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint('❌ Invalid file extension: $fileName');
        return;
      }

      // Validasi file exists
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: File tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint('❌ File does not exist: $filePath');
        return;
      }

      final fileSize = await file.length();
      debugPrint('✅ File selected: $fileName (${fileSize} bytes)');

      setState(() {
        _selectedFile = file;
        _selectedFileName = fileName;
        _fileSize = fileSize;
      });
    } catch (e) {
      debugPrint('❌ Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 _UploadDialogContent build - _selectedFile: ${_selectedFile != null ? "NOT NULL" : "NULL"}');
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 32 : 20,
            vertical: widget.isTablet ? 24 : 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: widget.isTablet ? 16 : 12),
              Container(
                width: widget.isTablet ? 60 : 40,
                height: widget.isTablet ? 6 : 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              SizedBox(height: widget.isTablet ? 28 : 20),
              Text(
                'Upload Model 3D',
                style: TextStyle(
                  fontSize: widget.isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: widget.isTablet ? 12 : 8),
              Text(
                'Pilih file model 3D dalam format GLB',
                style: TextStyle(
                  fontSize: widget.isTablet ? 16 : 14,
                  color: const Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: widget.isTablet ? 32 : 24),
              
              // File picker button atau preview file
              if (_selectedFile == null)
                InkWell(
                  onTap: () {
                    debugPrint('🔵 File picker button tapped');
                    _pickFile();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(widget.isTablet ? 24 : 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF00796B),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF00796B).withValues(alpha: 0.05),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: widget.isTablet ? 64 : 48,
                          color: const Color(0xFF00796B),
                        ),
                        SizedBox(height: widget.isTablet ? 16 : 12),
                        Text(
                          'Pilih File GLB',
                          style: TextStyle(
                            fontSize: widget.isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00796B),
                          ),
                        ),
                        SizedBox(height: widget.isTablet ? 8 : 6),
                        Text(
                          'Tap untuk memilih file dari perangkat',
                          style: TextStyle(
                            fontSize: widget.isTablet ? 14 : 12,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: widget.isTablet ? 56 : 48,
                            height: widget.isTablet ? 56 : 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00796B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.insert_drive_file,
                              color: const Color(0xFF00796B),
                              size: widget.isTablet ? 32 : 24,
                            ),
                          ),
                          SizedBox(width: widget.isTablet ? 16 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFileName!,
                                  style: TextStyle(
                                    fontSize: widget.isTablet ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF333333),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: widget.isTablet ? 6 : 4),
                                Text(
                                  _formatFileSize(_fileSize!),
                                  style: TextStyle(
                                    fontSize: widget.isTablet ? 14 : 12,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: Colors.red,
                            onPressed: () {
                              setState(() {
                                _selectedFile = null;
                                _selectedFileName = null;
                                _fileSize = null;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: widget.isTablet ? 16 : 12),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: widget.isTablet ? 20 : 16,
                          ),
                          SizedBox(width: widget.isTablet ? 8 : 6),
                          Text(
                            'File siap diupload',
                            style: TextStyle(
                              fontSize: widget.isTablet ? 14 : 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: widget.isTablet ? 28 : 20),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        minimumSize: Size(double.infinity, widget.isTablet ? 56 : 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: widget.isTablet ? 16 : 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: widget.isTablet ? 16 : 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedFile == null
                          ? null
                          : () {
                              debugPrint('✅ Submit button pressed');
                              debugPrint('   File: $_selectedFileName');
                              debugPrint('   Path: ${_selectedFile?.path}');
                              widget.onFileSelected(_selectedFile!, _selectedFileName!);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00796B),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, widget.isTablet ? 56 : 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[500],
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: widget.isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: widget.isTablet ? 16 : 12),
            ],
          ),
        ),
      ),
    );
  }
}
