import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/custom_model_service.dart';

class UploadModelScreen extends StatefulWidget {
  const UploadModelScreen({super.key});

  @override
  State<UploadModelScreen> createState() => _UploadModelScreenState();
}

class _UploadModelScreenState extends State<UploadModelScreen> {
  final CustomModelService _modelService = CustomModelService();
  List<CustomModel> _customModels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomModels();
  }

  Future<void> _loadCustomModels() async {
    setState(() => _isLoading = true);
    try {
      final models = await _modelService.getCustomModels();
      setState(() {
        _customModels = models;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error loading models: $e');
    }
  }

  void _showUploadOptions() {
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
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 20,
              vertical: isTablet ? 24 : 16,
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
                  'Upload Model 3D',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Text(
                  'Pilih file model 3D dalam format GLB atau GLTF',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: const Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 32 : 24),
                _buildUploadOption(
                  icon: Icons.insert_drive_file,
                  title: 'GLB File',
                  subtitle: 'Binary format (Recommended)',
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadModel(['glb']);
                  },
                  isTablet: isTablet,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                _buildUploadOption(
                  icon: Icons.code,
                  title: 'GLTF File',
                  subtitle: 'JSON format',
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadModel(['gltf']);
                  },
                  isTablet: isTablet,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                _buildUploadOption(
                  icon: Icons.folder_open,
                  title: 'Semua Format',
                  subtitle: 'GLB atau GLTF',
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadModel(['glb', 'gltf']);
                  },
                  isTablet: isTablet,
                ),
                SizedBox(height: isTablet ? 28 : 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
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

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    final iconSize = isTablet ? 56.0 : 48.0;
    final titleSize = isTablet ? 18.0 : 16.0;
    final subtitleSize = isTablet ? 14.0 : 12.0;
    final arrowSize = isTablet ? 20.0 : 16.0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: const Color(0xFF00796B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
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
                    subtitle,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: arrowSize,
              color: const Color(0xFF666666),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadModel(List<String> extensions) async {
    try {
      // Pick GLB/GLTF file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      // Show dialog to enter model name
      final modelName = await _showNameDialog(fileName);
      if (modelName == null || modelName.isEmpty) {
        return;
      }

      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Copy file to app directory
      final newPath = await _modelService.copyFileToAppDirectory(
        file,
        '${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );

      // Create custom model
      final customModel = CustomModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: modelName,
        filePath: newPath,
        uploadedAt: DateTime.now(),
      );

      // Save to storage
      await _modelService.saveCustomModel(customModel);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Reload models
      await _loadCustomModels();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Model "$modelName" berhasil diupload!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) {
        Navigator.of(context).pop();
      }
      _showErrorDialog('Error uploading model: $e');
    }
  }

  Future<String?> _showNameDialog(String defaultName) async {
    final controller = TextEditingController(
      text: defaultName.replaceAll(RegExp(r'\.(glb|gltf)$'), ''),
    );

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nama Model'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Masukkan nama model',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
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
        await _loadCustomModels();
        
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('ID', model.id),
            const SizedBox(height: 8),
            _buildInfoRow('File', model.filePath.split('/').last),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Diupload',
              '${model.uploadedAt.day}/${model.uploadedAt.month}/${model.uploadedAt.year}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Path', model.filePath),
          ],
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

  Widget _buildInfoRow(String label, String value) {
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
              : _customModels.isEmpty
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
                                  'Klik tombol "Upload" di header untuk menambah model baru',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Models list
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 16,
                            ),
                            itemCount: _customModels.length,
                            itemBuilder: (context, index) {
                              final model = _customModels[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: isTablet ? 16 : 12,
                                ),
                                child: _buildModelCard(model, isTablet),
                              );
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
}
