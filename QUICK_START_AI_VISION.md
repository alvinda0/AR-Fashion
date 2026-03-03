# Quick Start: AI Vision Chat

## 🚀 Get Started in 3 Steps

### 1. Add Your API Key

Edit `lib/services/huggingface_service.dart`:

```dart
static const String _apiKey = 'hf_your_token_here';
```

Get your token from: https://huggingface.co/settings/tokens

### 2. Add Permissions

**Android** - `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

**iOS** - `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Select images for AI analysis</string>
```

### 3. Run the App

```bash
flutter run
```

## 📱 How to Use

1. Navigate to AI Chat screen
2. Tap the 📷 icon to select an image
3. Type a question or leave blank for general description
4. Press send

## 💡 Example Questions

- "What's in this image?"
- "What color is this dress?"
- "Is this outfit formal or casual?"
- "Suggest accessories for this outfit"

## ✅ What Changed

### Files Modified:
- `lib/models/chat_message.dart` - Added image support
- `lib/services/huggingface_service.dart` - Integrated Qwen vision model
- `lib/screens/ai_chat_screen.dart` - Added image picker UI
- `pubspec.yaml` - Added image_picker dependency

### New Features:
- ✨ Image selection from gallery
- 🖼️ Image preview before sending
- 👁️ AI vision analysis
- 💬 Multimodal conversations (text + images)

## 🔧 Technical Details

- **Model**: Qwen/Qwen3.5-35B-A3B
- **Provider**: Novita (via Hugging Face Router)
- **API**: OpenAI-compatible chat completions
- **Image Support**: Local files and URLs
- **Max Image Size**: Recommended < 5MB

## 📚 More Info

- Full setup: `AI_VISION_SETUP.md`
- Code examples: `AI_VISION_EXAMPLES.md`
- Model docs: https://huggingface.co/Qwen/Qwen3.5-35B-A3B
