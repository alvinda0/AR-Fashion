class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imagePath; // Local file path or URL
  
  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.imagePath,
  }) : timestamp = timestamp ?? DateTime.now();
}
