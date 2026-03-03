# Alternatif Model AI untuk Chat

## Model Hugging Face yang Bisa Digunakan

### 1. DialoGPT (Microsoft) - Recommended ✅

**Small** - Cepat, ringan
```dart
static const String _model = 'microsoft/DialoGPT-small';
```
- Size: ~350MB
- Speed: ⚡⚡⚡
- Quality: ⭐⭐⭐

**Medium** - Balanced (Default)
```dart
static const String _model = 'microsoft/DialoGPT-medium';
```
- Size: ~800MB
- Speed: ⚡⚡
- Quality: ⭐⭐⭐⭐

**Large** - Paling akurat
```dart
static const String _model = 'microsoft/DialoGPT-large';
```
- Size: ~1.5GB
- Speed: ⚡
- Quality: ⭐⭐⭐⭐⭐

### 2. Blenderbot (Facebook)

**400M Distilled**
```dart
static const String _model = 'facebook/blenderbot-400M-distill';
```
- Conversational AI yang natural
- Good for casual chat
- Balanced speed & quality

**1B Distilled**
```dart
static const String _model = 'facebook/blenderbot-1B-distill';
```
- Lebih akurat dari 400M
- Lebih lambat
- Better context understanding

### 3. GPT-2 (OpenAI)

**Base**
```dart
static const String _model = 'gpt2';
```
- Text generation
- Fast response
- Less conversational

**Medium**
```dart
static const String _model = 'gpt2-medium';
```
- Better quality
- Slower than base

**Large**
```dart
static const String _model = 'gpt2-large';
```
- High quality
- Slower inference

### 4. BLOOM (BigScience)

**560M**
```dart
static const String _model = 'bigscience/bloom-560m';
```
- Multilingual support
- Good for Indonesian
- Moderate speed

**1B7**
```dart
static const String _model = 'bigscience/bloom-1b7';
```
- Better multilingual
- Slower but more accurate

### 5. Flan-T5 (Google)

**Small**
```dart
static const String _model = 'google/flan-t5-small';
```
- Instruction-following
- Fast
- Good for Q&A

**Base**
```dart
static const String _model = 'google/flan-t5-base';
```
- Better understanding
- Balanced performance

**Large**
```dart
static const String _model = 'google/flan-t5-large';
```
- Best quality
- Slower inference

## Perbandingan Model

| Model | Speed | Quality | Size | Best For |
|-------|-------|---------|------|----------|
| DialoGPT-small | ⚡⚡⚡ | ⭐⭐⭐ | 350MB | Quick testing |
| DialoGPT-medium | ⚡⚡ | ⭐⭐⭐⭐ | 800MB | Production |
| DialoGPT-large | ⚡ | ⭐⭐⭐⭐⭐ | 1.5GB | High quality |
| Blenderbot-400M | ⚡⚡ | ⭐⭐⭐⭐ | 400MB | Casual chat |
| GPT-2 | ⚡⚡⚡ | ⭐⭐⭐ | 500MB | Text generation |
| BLOOM-560m | ⚡⚡ | ⭐⭐⭐ | 560MB | Multilingual |
| Flan-T5-base | ⚡⚡ | ⭐⭐⭐⭐ | 250MB | Q&A |

## Cara Mengganti Model

### Langkah 1: Edit Service File

Buka `lib/services/huggingface_service.dart`

### Langkah 2: Ganti Model

```dart
// Ganti baris ini
static const String _model = 'microsoft/DialoGPT-medium';

// Dengan model pilihan Anda
static const String _model = 'facebook/blenderbot-400M-distill';
```

### Langkah 3: Adjust Parameters (Optional)

```dart
'parameters': {
  'max_length': 100,      // Sesuaikan dengan model
  'temperature': 0.7,     // 0.1-1.0
  'top_p': 0.9,          // 0.1-1.0
  'do_sample': true,
},
```

### Langkah 4: Test

```bash
flutter run
```

## Rekomendasi Berdasarkan Use Case

### 1. Testing & Development
**Recommended**: DialoGPT-small atau GPT-2
- Cepat
- Ringan
- Cukup untuk testing

### 2. Production (Bahasa Inggris)
**Recommended**: DialoGPT-medium atau Blenderbot-400M
- Balanced speed & quality
- Good conversational ability
- Reliable

### 3. Production (Multilingual/Indonesian)
**Recommended**: BLOOM-560m atau BLOOM-1b7
- Support bahasa Indonesia
- Good quality
- Multilingual

### 4. High Quality (No Budget Limit)
**Recommended**: DialoGPT-large atau Flan-T5-large
- Best quality
- Most accurate
- Slower but worth it

### 5. Q&A / Customer Support
**Recommended**: Flan-T5-base atau Flan-T5-large
- Instruction-following
- Good for specific questions
- Accurate answers

## Custom Implementation untuk Model Tertentu

### Untuk Blenderbot

```dart
Future<String> sendMessageBlenderbot(String message) async {
  const model = 'facebook/blenderbot-400M-distill';
  const url = 'https://api-inference.huggingface.co/models/$model';
  
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'inputs': message,
      'parameters': {
        'max_length': 128,
        'min_length': 20,
        'temperature': 0.8,
      },
    }),
  );
  
  // Process response...
}
```

### Untuk BLOOM (Multilingual)

```dart
Future<String> sendMessageBloom(String message) async {
  const model = 'bigscience/bloom-560m';
  const url = 'https://api-inference.huggingface.co/models/$model';
  
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'inputs': message,
      'parameters': {
        'max_new_tokens': 100,
        'temperature': 0.7,
        'top_p': 0.95,
      },
    }),
  );
  
  // Process response...
}
```

### Untuk Flan-T5 (Q&A)

```dart
Future<String> sendMessageFlanT5(String message) async {
  const model = 'google/flan-t5-base';
  const url = 'https://api-inference.huggingface.co/models/$model';
  
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'inputs': 'Question: $message\nAnswer:',
      'parameters': {
        'max_length': 100,
        'temperature': 0.5,
      },
    }),
  );
  
  // Process response...
}
```

## Tips Memilih Model

1. **Start Small**: Mulai dengan model kecil untuk testing
2. **Test Multiple**: Coba beberapa model untuk compare
3. **Monitor Performance**: Check response time & quality
4. **Consider Users**: Pilih berdasarkan target audience
5. **Budget**: Free tier punya limit, plan accordingly

## Troubleshooting per Model

### DialoGPT
- **Issue**: Respons terlalu pendek
- **Fix**: Increase `max_length` parameter

### Blenderbot
- **Issue**: Loading lama
- **Fix**: Model besar, tunggu warm-up

### GPT-2
- **Issue**: Tidak conversational
- **Fix**: Normal, GPT-2 untuk text generation

### BLOOM
- **Issue**: Mixed language response
- **Fix**: Specify language in prompt

### Flan-T5
- **Issue**: Respons terlalu formal
- **Fix**: Adjust temperature higher (0.7-0.9)

## Resources

- [Hugging Face Models](https://huggingface.co/models)
- [Model Cards](https://huggingface.co/docs/hub/model-cards)
- [Inference API Docs](https://huggingface.co/docs/api-inference/index)

## Kesimpulan

**Untuk aplikasi AR Fashion ini, rekomendasi:**

1. **Development**: DialoGPT-small
2. **Production**: DialoGPT-medium atau Blenderbot-400M
3. **Indonesian Support**: BLOOM-560m
4. **Best Quality**: DialoGPT-large

Pilih sesuai kebutuhan speed vs quality!
