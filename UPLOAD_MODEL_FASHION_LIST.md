# Upload Model Screen - Fashion Models List

## 📋 Overview

Upload Model screen sekarang menampilkan **list model 3D fashion** dari storage `ar-fashion-glb` di Supabase, dengan nama file yang user-friendly.

## ✨ What's New

### Before ❌
- Hanya menampilkan model custom yang diupload user
- Tidak ada informasi tentang model fashion yang tersedia

### After ✅
- Menampilkan **2 section**:
  1. **Model 3D Fashion** (dari `ar-fashion-glb`) ← NEW
  2. **Model Custom Anda** (upload user)
- Nama file ditampilkan dengan format user-friendly
- Badge "Supabase" untuk model fashion
- Loading indicator saat fetch data

## 🎨 UI Layout

```
┌─────────────────────────────────────┐
│  Upload Model 3D          [Upload]  │
├─────────────────────────────────────┤
│  ℹ️ Klik tombol "Upload" di header  │
│                                     │
│  📦 Model 3D Fashion (ar-fashion-glb)│
│  ┌─────────────────────────────┐   │
│  │ 👗 Xavia Blue               │   │
│  │    xavia_blue.glb  [Supabase]│  │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ 👗 Nayra Black              │   │
│  │    nayra_black.glb [Supabase]│  │
│  └─────────────────────────────┘   │
│                                     │
│  ☁️ Model Custom Anda               │
│  ┌─────────────────────────────┐   │
│  │ 🎨 My Custom Model    ℹ️ 🗑️  │   │
│  │    Diupload: 23/4/2026      │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

## 💻 Code Implementation

### 1. State Variables

```dart
class _UploadModelScreenState extends State<UploadModelScreen> {
  final CustomModelService _modelService = CustomModelService();
  List<CustomModel> _customModels = [];
  List<Map<String, String>> _fashionModels = [];  // ← NEW
  bool _isLoading = true;
  bool _isLoadingFashionModels = false;  // ← NEW
}
```

### 2. Load Fashion Models

```dart
Future<void> _loadFashionModels() async {
  setState(() => _isLoadingFashionModels = true);
  try {
    final supabase = SupabaseConfig.client;
    
    // Get list of files from ar-fashion-glb bucket
    final files = await supabase.storage
        .from('ar-fashion-glb')
        .list();
    
    final models = files
        .where((file) => file.name.endsWith('.glb'))
        .map((file) {
          final url = supabase.storage
              .from('ar-fashion-glb')
              .getPublicUrl(file.name);
          
          // Format display name
          final displayName = file.name
              .replaceAll('.glb', '')
              .replaceAll('_', ' ')
              .split(' ')
              .map((word) => word.isEmpty 
                  ? '' 
                  : word[0].toUpperCase() + word.substring(1))
              .join(' ');
          
          return {
            'name': displayName,
            'fileName': file.name,
            'url': url,
            'size': file.metadata?['size']?.toString() ?? '0',
          };
        })
        .toList();
    
    setState(() {
      _fashionModels = models;
      _isLoadingFashionModels = false;
    });
  } catch (e) {
    setState(() => _isLoadingFashionModels = false);
    debugPrint('❌ Error loading fashion models: $e');
  }
}
```

### 3. Display Name Formatting

```dart
// Input: "xavia_blue.glb"
// Output: "Xavia Blue"

final displayName = file.name
    .replaceAll('.glb', '')      // Remove extension
    .replaceAll('_', ' ')         // Replace underscore with space
    .split(' ')                   // Split into words
    .map((word) => word.isEmpty 
        ? '' 
        : word[0].toUpperCase() + word.substring(1))  // Capitalize
    .join(' ');                   // Join back
```

### 4. Fashion Model Card

```dart
Widget _buildFashionModelCard(Map<String, String> model, bool isTablet) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [...],
    ),
    child: ListTile(
      leading: Container(
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.checkroom,  // Fashion icon
          color: Colors.purple,
        ),
      ),
      title: Text(model['name']!),  // Display name
      subtitle: Text(model['fileName']!),  // File name
      trailing: Container(
        child: Row(
          children: [
            Icon(Icons.cloud, color: Colors.purple),
            Text('Supabase'),  // Badge
          ],
        ),
      ),
    ),
  );
}
```

## 📊 Data Structure

### Fashion Model Map

```dart
{
  'name': 'Xavia Blue',           // Display name (formatted)
  'fileName': 'xavia_blue.glb',   // Original file name
  'url': 'https://...',           // Public URL
  'size': '1234567',              // File size in bytes
}
```

## 🎯 Features

### ✅ Implemented

1. **Fetch from Supabase**
   - Load model list from `ar-fashion-glb` bucket
   - Filter only `.glb` files
   - Get public URL for each model

2. **User-Friendly Display**
   - Format file name: `xavia_blue.glb` → `Xavia Blue`
   - Show original file name as subtitle
   - Purple color scheme for fashion models

3. **Visual Distinction**
   - Fashion models: Purple icon (👗 checkroom)
   - Custom models: Teal icon (🎨 view_in_ar)
   - Badge "Supabase" for fashion models

4. **Loading State**
   - Show loading indicator while fetching
   - Graceful error handling

5. **Two Sections**
   - "Model 3D Fashion (ar-fashion-glb)"
   - "Model Custom Anda"

## 🎨 Styling

### Fashion Model Card

```dart
// Icon container
Container(
  decoration: BoxDecoration(
    color: Colors.purple.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(
    Icons.checkroom,
    color: Colors.purple,
  ),
)

// Badge
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.purple.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.purple),
  ),
  child: Row(
    children: [
      Icon(Icons.cloud, size: 14, color: Colors.purple),
      SizedBox(width: 4),
      Text('Supabase', style: TextStyle(color: Colors.purple)),
    ],
  ),
)
```

### Custom Model Card

```dart
// Icon container
Container(
  decoration: BoxDecoration(
    color: Color(0xFF00796B).withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(
    Icons.view_in_ar,
    color: Color(0xFF00796B),
  ),
)
```

## 📝 Example Data

### Input (Supabase Storage)

```
ar-fashion-glb/
├── xavia_blue.glb
├── nayra_black.glb
├── dayana_blue.glb
├── sabrina_white.glb
└── valerya_pink.glb
```

### Output (Display)

```
Model 3D Fashion (ar-fashion-glb)
├── Xavia Blue (xavia_blue.glb) [Supabase]
├── Nayra Black (nayra_black.glb) [Supabase]
├── Dayana Blue (dayana_blue.glb) [Supabase]
├── Sabrina White (sabrina_white.glb) [Supabase]
└── Valerya Pink (valerya_pink.glb) [Supabase]
```

## 🔄 Data Flow

```
App Start
    ↓
initState()
    ├─ _loadCustomModels()
    └─ _loadFashionModels()  ← NEW
           ↓
    Supabase.storage.from('ar-fashion-glb').list()
           ↓
    Filter .glb files
           ↓
    Format display names
           ↓
    setState(_fashionModels)
           ↓
    Display in UI
```

## 🎯 Benefits

### ✅ Advantages

1. **Visibility**
   - User dapat melihat semua model fashion yang tersedia
   - Tidak perlu buka Supabase dashboard

2. **User-Friendly**
   - Nama file diformat dengan baik
   - Mudah dibaca dan dipahami

3. **Clear Distinction**
   - Fashion models vs custom models jelas terpisah
   - Visual cues (icon, color, badge)

4. **Informative**
   - Tampilkan nama display dan file name
   - Badge menunjukkan sumber (Supabase)

## 🚀 Testing

### Test Cases

1. **Load Fashion Models**
   - ✅ Fetch from ar-fashion-glb bucket
   - ✅ Display formatted names
   - ✅ Show file names as subtitle
   - ✅ Badge "Supabase" visible

2. **Loading State**
   - ✅ Show loading indicator
   - ✅ Hide after data loaded

3. **Empty State**
   - ✅ Handle no fashion models
   - ✅ Handle no custom models
   - ✅ Show empty state message

4. **Error Handling**
   - ✅ Handle Supabase error
   - ✅ Don't crash app
   - ✅ Log error to console

## 📱 User Experience

### Scenario 1: View Available Models

```
User opens Upload Model screen
    ↓
Sees "Model 3D Fashion" section
    ↓
Sees list of available fashion models
    ├─ Xavia Blue
    ├─ Nayra Black
    └─ ...
    ↓
Can reference these models when uploading image targets
```

### Scenario 2: Upload Custom Model

```
User clicks "Upload" button
    ↓
Uploads custom model
    ↓
Model appears in "Model Custom Anda" section
    ↓
Clearly separated from fashion models
```

## 🔮 Future Enhancements

- [ ] Add tap to view model details
- [ ] Add copy URL button
- [ ] Add file size display
- [ ] Add upload date for fashion models
- [ ] Add search/filter functionality
- [ ] Add model preview (thumbnail)
- [ ] Add download model option
- [ ] Add share model URL

---

**Last Updated**: 2026-04-23  
**Version**: 1.0.0  
**Status**: ✅ Completed
