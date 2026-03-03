import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import '../models/chat_message.dart';
import '../services/huggingface_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final HuggingFaceService _aiService = HuggingFaceService();
  final ImagePicker _imagePicker = ImagePicker();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _selectedImagePath;
  String _loadingMessage = 'AI sedang mengetik...';
  static const String _storageKey = 'ai_chat_history';

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }
  
  // Load chat history dari storage
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_storageKey);
      
      print('Loading chat history...');
      print('History JSON: $historyJson');
      
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        print('Decoded ${decoded.length} messages');
        
        setState(() {
          _messages.clear();
          _messages.addAll(
            decoded.map((json) => ChatMessage.fromJson(json)).toList(),
          );
        });
        
        print('Loaded ${_messages.length} messages from storage');
      } else {
        print('No history found, adding welcome message');
        // Welcome message jika belum ada history
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Halo! Saya adalah AI assistant untuk AR Fashion. Ada yang bisa saya bantu?',
              isUser: false,
            ),
          );
        });
      }
      
      // Scroll ke bawah setelah load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error loading chat history: $e');
      // Fallback ke welcome message
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Halo! Saya adalah AI assistant untuk AR Fashion. Ada yang bisa saya bantu?',
            isUser: false,
          ),
        );
      });
    }
  }
  
  // Save chat history ke storage
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Filter out messages dengan imagePath yang tidak valid (file sudah dihapus)
      final messagesToSave = _messages.map((msg) {
        // Jika ada imagePath dan itu local file, cek apakah masih ada
        if (msg.imagePath != null && 
            !msg.imagePath!.startsWith('http') &&
            !File(msg.imagePath!).existsSync()) {
          // File sudah tidak ada, jangan simpan imagePath
          return ChatMessage(
            text: msg.text,
            isUser: msg.isUser,
            timestamp: msg.timestamp,
            imagePath: null,
          );
        }
        return msg;
      }).toList();
      
      final historyJson = jsonEncode(
        messagesToSave.map((msg) => msg.toJson()).toList(),
      );
      
      await prefs.setString(_storageKey, historyJson);
      print('Saved ${messagesToSave.length} messages to storage');
      print('Saved JSON length: ${historyJson.length} characters');
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }
  
  // Clear chat history
  Future<void> _clearChatHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat Chat?'),
        content: const Text('Semua percakapan akan dihapus. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_storageKey);
        print('Chat history cleared');
        
        setState(() {
          _messages.clear();
          _messages.add(
            ChatMessage(
              text: 'Halo! Saya adalah AI assistant untuk AR Fashion. Ada yang bisa saya bantu?',
              isUser: false,
            ),
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Riwayat chat berhasil dihapus')),
        );
      } catch (e) {
        print('Error clearing chat history: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memilih gambar: $e')),
      );
    }
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty && _selectedImagePath == null) return;

    final imagePath = _selectedImagePath;
    
    setState(() {
      _messages.add(ChatMessage(
        text: message.isEmpty ? 'Gambar' : message,
        isUser: true,
        imagePath: imagePath,
      ));
      _isLoading = true;
      _selectedImagePath = null;
      _loadingMessage = imagePath != null 
          ? 'AI sedang menganalisis gambar...' 
          : 'AI sedang mengetik...';
    });

    _messageController.clear();
    _scrollToBottom();
    
    // Save history setelah user kirim pesan
    await _saveChatHistory();

    // Get conversation history
    final history = _messages
        .map((m) => '${m.isUser ? "User" : "Bot"}: ${m.text}')
        .toList();

    // Update loading message setelah 10 detik
    Future.delayed(const Duration(seconds: 10), () {
      if (_isLoading) {
        setState(() {
          _loadingMessage = 'Model sedang memproses, mohon tunggu...';
        });
      }
    });

    // Send to AI with image if available
    final response = await _aiService.sendMessage(
      message.isEmpty ? 'Jelaskan gambar ini secara detail' : message,
      conversationHistory: history,
      imagePath: imagePath,
    );

    setState(() {
      _messages.add(ChatMessage(text: response, isUser: false));
      _isLoading = false;
      _loadingMessage = 'AI sedang mengetik...';
    });

    _scrollToBottom();
    
    // Save history setelah AI response
    await _saveChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Assistant'),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Debug button (bisa dihapus nanti)
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Info',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final historyJson = prefs.getString(_storageKey);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Debug Info'),
                  content: SingleChildScrollView(
                    child: Text(
                      'Messages in memory: ${_messages.length}\n\n'
                      'Storage key: $_storageKey\n\n'
                      'Stored data exists: ${historyJson != null}\n\n'
                      'Stored data length: ${historyJson?.length ?? 0} chars\n\n'
                      'First 200 chars:\n${historyJson?.substring(0, historyJson.length > 200 ? 200 : historyJson.length) ?? "null"}',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          // Button New Chat
          IconButton(
            icon: const Icon(Icons.add_comment),
            tooltip: 'Chat Baru',
            onPressed: _clearChatHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF00796B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      _loadingMessage,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image preview
                  if (_selectedImagePath != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedImagePath!),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: _clearSelectedImage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Input row
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Image picker button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.image),
                            color: const Color(0xFF00796B),
                            onPressed: _isLoading ? null : _pickImage,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Ketik pesan...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00796B),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF00796B),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            color: Colors.white,
                            onPressed: _isLoading ? null : _sendMessage,
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
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFF00796B),
              radius: 16,
              child: const Icon(
                Icons.smart_toy,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF00796B)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display image if available
                  if (message.imagePath != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: message.imagePath!.startsWith('http')
                          ? Image.network(
                              message.imagePath!,
                              width: 200,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(message.imagePath!),
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Display text
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 16,
              child: Icon(
                Icons.person,
                size: 18,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
