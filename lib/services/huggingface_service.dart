import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'fashion_context_service.dart';

class HuggingFaceService {
  // Get API key from .env file (AMAN untuk GitHub)
  static String get _apiKey => dotenv.env['HF_TOKEN'] ?? '';
  
  // Using Hugging Face Router (OpenAI-compatible API)
  static const String _baseUrl = 'https://router.huggingface.co/v1';
  
  // Model untuk text chat (cepat dan gratis)
  static const String _textModel = 'meta-llama/Llama-3.2-3B-Instruct';
  
  // Model untuk vision (lebih lambat, butuh waktu warm-up)
  static const String _visionModel = 'Qwen/Qwen3.5-35B-A3B:novita';
  
  Future<String> sendMessage(
    String message, {
    List<String>? conversationHistory,
    String? imagePath,
    int maxRetries = 2,
  }) async {
    // Jika ada gambar, gunakan vision model
    if (imagePath != null && imagePath.isNotEmpty) {
      return _sendVisionMessage(message, imagePath, conversationHistory, maxRetries);
    }
    
    // Jika text saja, gunakan model yang lebih cepat
    return _sendTextMessage(message, conversationHistory, maxRetries);
  }
  
  // Text-only chat (cepat dan stabil)
  Future<String> _sendTextMessage(
    String message,
    List<String>? conversationHistory,
    int maxRetries,
  ) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        // Build messages array (format OpenAI)
        final messages = <Map<String, dynamic>>[];
        
        // System message dengan fashion context
        final fashionContext = FashionContextService.getFashionContext();
        messages.add({
          'role': 'system',
          'content': '''$fashionContext

Kamu adalah AI assistant untuk aplikasi AR Fashion. 
- Jawab dengan ramah dan membantu dalam bahasa Indonesia
- Gunakan informasi produk di atas untuk memberikan rekomendasi
- Jika ditanya tentang produk tertentu, sebutkan detail harga, bahan, warna, dan ukuran
- Jika customer bertanya "ada dress apa?", "rekomendasi dong", atau sejenisnya, sebutkan beberapa pilihan produk
- Berikan saran yang sesuai dengan kebutuhan customer''',
        });
        
        // Add conversation history
        if (conversationHistory != null && conversationHistory.isNotEmpty) {
          final recentHistory = conversationHistory.length > 6
              ? conversationHistory.sublist(conversationHistory.length - 6)
              : conversationHistory;
              
          for (var msg in recentHistory) {
            if (msg.startsWith('User: ')) {
              messages.add({
                'role': 'user',
                'content': msg.substring(6),
              });
            } else if (msg.startsWith('Bot: ')) {
              messages.add({
                'role': 'assistant',
                'content': msg.substring(5),
              });
            }
          }
        }
        
        // Current message
        messages.add({
          'role': 'user',
          'content': message,
        });
        
        final response = await http
            .post(
              Uri.parse('$_baseUrl/chat/completions'),
              headers: {
                'Authorization': 'Bearer $_apiKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': _textModel,
                'messages': messages,
                'max_tokens': 300,
                'temperature': 0.7,
              }),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception('Request timeout');
              },
            );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices']?[0]?['message']?['content'];
          
          return content?.toString().trim() ?? 
              'Maaf, saya tidak mengerti. Bisa diulang?';
        } else if (response.statusCode == 503) {
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: 3 * (attempt + 1)));
            continue;
          }
          return 'Model sedang loading. Tunggu 10 detik dan coba lagi.';
        } else if (response.statusCode == 401) {
          return 'Error: API key tidak valid. Periksa token di huggingface_service.dart';
        } else if (response.statusCode == 429) {
          return 'Error: Terlalu banyak request. Tunggu sebentar.';
        } else {
          return 'Error ${response.statusCode}: ${response.body}';
        }
      } on http.ClientException catch (e) {
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
          continue;
        }
        return 'Error koneksi: Periksa internet Anda.';
      } catch (e) {
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
          continue;
        }
        return 'Error: ${e.toString()}';
      }
    }
    
    return 'Gagal setelah beberapa percobaan.';
  }
  
  // Vision chat (lebih lambat, butuh waktu)
  Future<String> _sendVisionMessage(
    String message,
    String imagePath,
    List<String>? conversationHistory,
    int maxRetries,
  ) async {
    // Retry logic untuk handle connection issues
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        // Build messages array
        final messages = <Map<String, dynamic>>[];
        
        // Add conversation history if available (batasi hanya 5 pesan terakhir)
        if (conversationHistory != null && conversationHistory.isNotEmpty) {
          final recentHistory = conversationHistory.length > 10 
              ? conversationHistory.sublist(conversationHistory.length - 10)
              : conversationHistory;
              
          for (var msg in recentHistory.take(recentHistory.length - 1)) {
            if (msg.startsWith('User: ')) {
              messages.add({
                'role': 'user',
                'content': msg.substring(6),
              });
            } else if (msg.startsWith('Bot: ')) {
              messages.add({
                'role': 'assistant',
                'content': msg.substring(5),
              });
            }
          }
        }
        
        // Build current message content
        if (imagePath != null && imagePath.isNotEmpty) {
          // Vision message with image
          String imageUrl;
          
          if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
            imageUrl = imagePath;
          } else {
            // Convert local file to base64 dengan kompresi
            final imageBytes = await File(imagePath).readAsBytes();
            
            // Cek ukuran file
            if (imageBytes.length > 5 * 1024 * 1024) {
              return 'Error: Ukuran gambar terlalu besar. Maksimal 5MB.';
            }
            
            final base64Image = base64Encode(imageBytes);
            imageUrl = 'data:image/jpeg;base64,$base64Image';
          }
          
          messages.add({
            'role': 'user',
            'content': [
              {'type': 'text', 'text': message},
              {
                'type': 'image_url',
                'image_url': {'url': imageUrl}
              }
            ]
          });
        } else {
          // Text-only message
          messages.add({
            'role': 'user',
            'content': message,
          });
        }
        
        // Kirim request dengan timeout yang lebih panjang
        final response = await http
            .post(
              Uri.parse('$_baseUrl/chat/completions'),
              headers: {
                'Authorization': 'Bearer $_apiKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': _visionModel,
                'messages': messages,
                'max_tokens': 500,
                'temperature': 0.7,
              }),
            )
            .timeout(
              const Duration(seconds: 60), // Timeout 60 detik
              onTimeout: () {
                throw Exception('Request timeout. Model mungkin sedang cold start.');
              },
            );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices']?[0]?['message']?['content'];
          
          return content?.toString().trim() ?? 
              'Maaf, saya tidak dapat memahami pertanyaan Anda.';
        } else if (response.statusCode == 503) {
          if (attempt < maxRetries) {
            // Tunggu sebelum retry
            await Future.delayed(Duration(seconds: 5 * (attempt + 1)));
            continue; // Retry
          }
          return 'Model sedang loading. Silakan tunggu 30 detik dan coba lagi.';
        } else if (response.statusCode == 401) {
          return 'Error: API key tidak valid. Periksa token Hugging Face Anda.';
        } else if (response.statusCode == 429) {
          return 'Error: Terlalu banyak request. Tunggu sebentar dan coba lagi.';
        } else {
          return 'Error ${response.statusCode}: ${response.body}';
        }
      } on http.ClientException catch (e) {
        if (attempt < maxRetries) {
          // Tunggu sebelum retry
          await Future.delayed(Duration(seconds: 3 * (attempt + 1)));
          continue; // Retry
        }
        return 'Error koneksi: ${e.message}. Periksa koneksi internet Anda.';
      } on Exception catch (e) {
        if (attempt < maxRetries && e.toString().contains('timeout')) {
          // Retry untuk timeout
          await Future.delayed(Duration(seconds: 5 * (attempt + 1)));
          continue;
        }
        return 'Error: ${e.toString()}';
      } catch (e) {
        return 'Error tidak terduga: $e';
      }
    }
    
    return 'Gagal setelah beberapa percobaan. Silakan coba lagi nanti.';
  }
}
