# Chat History Persistence

## Fitur: Riwayat Chat Tersimpan

Chat history sekarang tersimpan secara otomatis dan tidak hilang saat keluar dari halaman chat!

## Fitur yang Ditambahkan

### 1. ✅ Auto-Save Chat History
- Setiap pesan (user & AI) otomatis tersimpan ke local storage
- Menggunakan `shared_preferences` untuk persistent storage
- Data tersimpan dalam format JSON

### 2. ✅ Auto-Load Chat History
- Saat buka chat lagi, history otomatis di-load
- Percakapan sebelumnya tetap ada
- Scroll otomatis ke pesan terakhir

### 3. ✅ Button "New Chat"
- Icon `+` di AppBar untuk mulai chat baru
- Konfirmasi dialog sebelum hapus history
- Welcome message muncul setelah clear

## Cara Kerja

### Save History
```dart
Future<void> _saveChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final historyJson = jsonEncode(
    _messages.map((msg) => msg.toJson()).toList(),
  );
  await prefs.setString(_storageKey, historyJson);
}
```

History disimpan setiap kali:
- User mengirim pesan
- AI memberikan response

### Load History
```dart
Future<void> _loadChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final historyJson = prefs.getString(_storageKey);
  
  if (historyJson != null) {
    final List<dynamic> decoded = jsonDecode(historyJson);
    _messages.addAll(
      decoded.map((json) => ChatMessage.fromJson(json)).toList(),
    );
  }
}
```

History di-load saat:
- `initState()` - Pertama kali buka chat screen
- Otomatis restore semua pesan

### Clear History
```dart
Future<void> _clearChatHistory() async {
  // Konfirmasi dialog
  final confirmed = await showDialog<bool>(...);
  
  if (confirmed) {
    await prefs.remove(_storageKey);
    _messages.clear();
    // Add welcome message
  }
}
```

## ChatMessage Model Update

Tambahan method untuk serialization:

```dart
class ChatMessage {
  // ... existing fields
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
    };
  }
  
  // Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      imagePath: json['imagePath'],
    );
  }
}
```

## User Experience

### Sebelum (❌):
1. User chat dengan AI
2. User keluar dari halaman
3. User buka chat lagi
4. ❌ History hilang, harus mulai dari awal

### Sesudah (✅):
1. User chat dengan AI
2. User keluar dari halaman
3. User buka chat lagi
4. ✅ History masih ada, bisa lanjut percakapan
5. Kalau mau mulai baru, klik icon `+` di AppBar

## Storage Key

```dart
static const String _storageKey = 'ai_chat_history';
```

Data disimpan dengan key ini di SharedPreferences.

## Limitasi & Considerations

### Storage Size
- SharedPreferences cocok untuk chat history yang tidak terlalu besar
- Jika chat sangat panjang (>1000 pesan), pertimbangkan:
  - Limit jumlah pesan yang disimpan
  - Gunakan database (SQLite/Hive) untuk storage yang lebih besar

### Image Paths
- Image paths (local file) disimpan sebagai string
- Jika file dihapus dari device, image tidak akan muncul
- Untuk production, pertimbangkan:
  - Upload image ke server
  - Atau simpan image sebagai base64 (tapi akan besar)

### Multiple Conversations
- Saat ini hanya support 1 conversation thread
- Untuk multiple threads, bisa tambahkan:
  - Conversation ID
  - List of conversations
  - Switch between conversations

## Future Improvements

### 1. Multiple Conversation Threads
```dart
// Save dengan conversation ID
await prefs.setString('chat_$conversationId', historyJson);

// List conversations
final conversations = prefs.getKeys()
  .where((key) => key.startsWith('chat_'))
  .toList();
```

### 2. Export Chat History
```dart
// Export ke file
Future<void> exportChat() async {
  final file = File('chat_export.json');
  await file.writeAsString(historyJson);
}
```

### 3. Search in History
```dart
List<ChatMessage> searchMessages(String query) {
  return _messages.where((msg) => 
    msg.text.toLowerCase().contains(query.toLowerCase())
  ).toList();
}
```

### 4. Auto-Delete Old Messages
```dart
// Hapus pesan lebih dari 30 hari
void cleanOldMessages() {
  final cutoff = DateTime.now().subtract(Duration(days: 30));
  _messages.removeWhere((msg) => msg.timestamp.isBefore(cutoff));
}
```

### 5. Cloud Sync
- Sync chat history ke Firebase/backend
- Akses dari multiple devices
- Backup otomatis

## Testing

### Test Persistence:
1. ✅ Buka AI Chat
2. ✅ Kirim beberapa pesan
3. ✅ Keluar dari chat (back button)
4. ✅ Buka AI Chat lagi
5. ✅ Verify: History masih ada

### Test New Chat:
1. ✅ Buka AI Chat dengan history
2. ✅ Klik icon `+` di AppBar
3. ✅ Konfirmasi "Hapus"
4. ✅ Verify: History terhapus, welcome message muncul

### Test Image Persistence:
1. ✅ Kirim pesan dengan gambar
2. ✅ Keluar dan buka lagi
3. ✅ Verify: Gambar masih muncul (jika file masih ada)

## Troubleshooting

### History tidak tersimpan
- Cek apakah `_saveChatHistory()` dipanggil setelah kirim pesan
- Cek permission storage (Android)
- Cek error di console

### History tidak ter-load
- Cek apakah `_loadChatHistory()` dipanggil di `initState()`
- Cek format JSON valid
- Cek error di console

### App crash saat load history
- Kemungkinan data corrupt
- Clear storage: `prefs.remove(_storageKey)`
- Atau clear app data dari settings

## Dependencies

```yaml
dependencies:
  shared_preferences: ^2.2.2
```

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web (localStorage)
- ✅ Windows
- ✅ macOS
- ✅ Linux

SharedPreferences support semua platform Flutter!
