import '../models/chat_message.dart';

/// Simple in-memory chat storage
/// Data bertahan selama app running, hilang saat app ditutup
class ChatStorageService {
  static final ChatStorageService _instance = ChatStorageService._internal();
  factory ChatStorageService() => _instance;
  ChatStorageService._internal();
  
  // In-memory storage
  final List<ChatMessage> _messages = [];
  
  // Get all messages
  List<ChatMessage> getMessages() {
    return List.from(_messages);
  }
  
  // Add message
  void addMessage(ChatMessage message) {
    _messages.add(message);
  }
  
  // Clear all messages
  void clearMessages() {
    _messages.clear();
  }
  
  // Check if has messages
  bool get hasMessages => _messages.isNotEmpty;
  
  // Get message count
  int get messageCount => _messages.length;
}
