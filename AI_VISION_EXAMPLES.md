# AI Vision API Examples

## Python Example (Original)

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://router.huggingface.co/v1",
    api_key=os.environ["HF_TOKEN"],
)

completion = client.chat.completions.create(
    model="Qwen/Qwen3.5-35B-A3B:novita",
    messages=[{
        "role": "user",
        "content": [
            {
                "type": "text",
                "text": "Describe this image in one sentence."
            },
            {
                "type": "image_url",
                "image_url": {
                    "url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
                }
            }
        ]
    }],
)

print(completion.choices[0].message)
```

## Dart/Flutter Implementation

### Basic Text Chat

```dart
final service = HuggingFaceService();
final response = await service.sendMessage(
  'Hello, how are you?',
);
print(response);
```

### Image Analysis with URL

```dart
final service = HuggingFaceService();
final response = await service.sendMessage(
  'Describe this image',
  imagePath: 'https://example.com/image.jpg',
);
print(response);
```

### Image Analysis with Local File

```dart
final service = HuggingFaceService();
final response = await service.sendMessage(
  'What color is the dress?',
  imagePath: '/path/to/local/image.jpg',
);
print(response);
```

### With Conversation History

```dart
final service = HuggingFaceService();
final history = [
  'User: Hello',
  'Bot: Hi! How can I help you?',
  'User: I want to analyze an image',
];

final response = await service.sendMessage(
  'What do you see in this picture?',
  conversationHistory: history,
  imagePath: '/path/to/image.jpg',
);
print(response);
```

## cURL Example

```bash
curl https://router.huggingface.co/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $HF_TOKEN" \
  -d '{
    "model": "Qwen/Qwen3.5-35B-A3B:novita",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": "Describe this image"
          },
          {
            "type": "image_url",
            "image_url": {
              "url": "https://example.com/image.jpg"
            }
          }
        ]
      }
    ],
    "max_tokens": 500
  }'
```

## Fashion-Specific Examples

### Outfit Analysis

```dart
final response = await service.sendMessage(
  'Analyze this outfit and suggest what occasions it would be suitable for',
  imagePath: 'assets/images/outfit.jpg',
);
```

### Color Matching

```dart
final response = await service.sendMessage(
  'What colors would complement this dress? Suggest accessories.',
  imagePath: selectedImagePath,
);
```

### Style Identification

```dart
final response = await service.sendMessage(
  'What fashion style is this? Is it casual, formal, or business casual?',
  imagePath: imagePath,
);
```

### Fabric Analysis

```dart
final response = await service.sendMessage(
  'Based on the appearance, what type of fabric might this be? What season is it suitable for?',
  imagePath: imagePath,
);
```

## Response Format

The API returns a JSON response:

```json
{
  "choices": [
    {
      "message": {
        "content": "The image shows the Statue of Liberty standing on Liberty Island in New York Bay."
      }
    }
  ]
}
```

## Error Handling

```dart
try {
  final response = await service.sendMessage(
    'Describe this image',
    imagePath: imagePath,
  );
  
  if (response.startsWith('Error:')) {
    // Handle error
    print('API Error: $response');
  } else {
    // Success
    print('AI Response: $response');
  }
} catch (e) {
  print('Exception: $e');
}
```

## Best Practices

1. **Image Size**: Keep images under 5MB for faster processing
2. **Resolution**: 1024x1024 is optimal for most use cases
3. **Format**: JPEG or PNG recommended
4. **Prompts**: Be specific about what you want to know
5. **Context**: Include conversation history for better responses
6. **Rate Limits**: Implement retry logic for 503 errors

## Testing the Integration

```dart
// Test 1: Text only
final textResponse = await service.sendMessage('Hello!');
assert(textResponse.isNotEmpty);

// Test 2: Image with URL
final urlResponse = await service.sendMessage(
  'What is this?',
  imagePath: 'https://example.com/test.jpg',
);
assert(!urlResponse.startsWith('Error:'));

// Test 3: Local image
final localResponse = await service.sendMessage(
  'Describe this',
  imagePath: '/path/to/local/image.jpg',
);
assert(localResponse.isNotEmpty);
```
