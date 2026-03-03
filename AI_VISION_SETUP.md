# AI Vision Chat Setup Guide

This guide explains how to set up and use the vision-enabled AI chat feature using Qwen3.5-35B-A3B model.

## Features

- Text-based chat with AI
- Image analysis and description
- Multimodal conversations (text + images)
- Support for both local images and URLs

## Setup Steps

### 1. Get Hugging Face API Token

1. Go to https://huggingface.co/settings/tokens
2. Create a new token with read permissions
3. Copy the token

### 2. Configure API Key

Open `lib/services/huggingface_service.dart` and replace:

```dart
static const String _apiKey = 'YOUR_HUGGINGFACE_API_KEY';
```

With your actual token:

```dart
static const String _apiKey = 'hf_xxxxxxxxxxxxxxxxxxxxx';
```

### 3. Install Dependencies

Run:

```bash
flutter pub get
```

### 4. Platform-Specific Setup

#### Android

Add to `android/app/src/main/AndroidManifest.xml` (inside `<manifest>` tag):

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

#### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select images for AI analysis</string>
```

## Usage

### Text-Only Chat

1. Open the AI Chat screen
2. Type your message
3. Press send

### Image Analysis

1. Tap the image icon (📷) in the input area
2. Select an image from your gallery
3. Optionally add a text prompt (e.g., "What's in this image?")
4. Press send

The AI will analyze the image and respond with a description or answer your question about it.

## Example Prompts

### Image Description
- "Describe this image in detail"
- "What do you see in this picture?"
- "Analyze this fashion item"

### Specific Questions
- "What color is the dress in this image?"
- "Is this suitable for formal occasions?"
- "What style is this outfit?"

### Fashion-Specific
- "Suggest accessories that would match this outfit"
- "What season is this clothing appropriate for?"
- "Describe the fabric and texture"

## Model Information

- Model: Qwen/Qwen3.5-35B-A3B (via Novita provider)
- API: Hugging Face Router (OpenAI-compatible)
- Endpoint: https://router.huggingface.co/v1
- Capabilities: Text generation, image understanding, multimodal reasoning

## Troubleshooting

### "Model is loading" Error
The model may need to warm up. Wait 10-20 seconds and try again.

### Image Not Sending
- Check file size (should be < 5MB)
- Ensure image format is supported (JPEG, PNG)
- Verify permissions are granted

### API Errors
- Verify your API token is valid
- Check your internet connection
- Ensure you have API quota remaining

## Cost Considerations

Hugging Face Inference API has:
- Free tier with rate limits
- Pay-as-you-go pricing for higher usage
- Check https://huggingface.co/pricing for current rates

## Alternative Models

You can switch to other vision models by changing the model name in `huggingface_service.dart`:

```dart
static const String _visionModel = 'Qwen/Qwen3.5-35B-A3B:novita';
```

Other options:
- `meta-llama/Llama-3.2-11B-Vision-Instruct`
- `microsoft/Phi-3.5-vision-instruct`
- Check Hugging Face Router docs for available models

## Privacy Note

Images are sent to Hugging Face servers for processing. Do not send sensitive or private images.
