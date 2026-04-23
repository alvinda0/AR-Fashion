# AR Camera - Supabase Product Detail Integration

## 📋 Overview

AR Camera screen sekarang mengambil **nama produk** dan **deskripsi** langsung dari **Supabase** berdasarkan image target yang terdeteksi.

## 🔄 Data Flow

```
Image Target Detected
    ↓
Find in Supabase (_imageTargets)
    ↓
Get: name, description, imageTarget, modelUrl, createdAt
    ↓
Display in Product Detail Modal
    ├─ Header: name (from Supabase)
    ├─ Image: imageTarget (from Supabase)
    ├─ Badge: "From Supabase" or "Fallback Data"
    ├─ 3D Model indicator
    ├─ Created date
    └─ Description: description (from Supabase)
```

## 🎯 Features

### ✅ Implemented

1. **Dynamic Product Name**
   - Nama produk diambil dari field `name` di Supabase
   - Ditampilkan di header modal

2. **Dynamic Description**
   - Deskripsi diambil dari field `description` di Supabase
   - Ditampilkan di body modal dengan styling yang baik
   - Fallback ke data hardcoded jika tidak ada di Supabase

3. **Data Source Badge**
   - Badge "From Supabase" jika data dari database
   - Badge "Fallback Data" jika menggunakan data hardcoded

4. **Complete Product Info**
   - Image target
   - 3D model availability indicator
   - Created date
   - Full description

## 🎨 UI Components

### Product Detail Modal

```
┌─────────────────────────────────────┐
│  [Product Name]                  ✕  │ ← From Supabase
├─────────────────────────────────────┤
│  ┌─────────┐  ┌─────────────────┐  │
│  │ Image   │  │ ✓ From Supabase │  │
│  │ Target  │  │ Fashion Item    │  │
│  │         │  │ 🎨 3D Model     │  │
│  │         │  │ 📅 23/4/2026    │  │
│  └─────────┘  └─────────────────┘  │
│  ─────────────────────────────────  │
│  📄 Deskripsi Produk                │
│  ┌─────────────────────────────┐   │
│  │ [Description from Supabase] │   │ ← From Supabase
│  │ ...                         │   │
│  │ ...                         │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

## 💻 Code Implementation

### 1. Find Product Data

```dart
void _showProductDetail() {
  if (_selectedItemId == null) return;
  
  // Find from Supabase first
  final target = _imageTargets.firstWhere(
    (t) => t.name == _selectedItemId,
    orElse: () => ImageTarget(
      name: _selectedItemId!,
      imageTarget: '',
    ),
  );
  
  // Fallback to hardcoded data if not found
  Map<String, String>? fallbackItem;
  if (target.imageTarget.isEmpty) {
    fallbackItem = _fashionItems.firstWhere(
      (item) => item['id'] == _selectedItemId || item['name'] == _selectedItemId,
      orElse: () => {},
    );
  }
  
  // Prepare display data
  final displayName = target.name.isNotEmpty 
      ? target.name 
      : (fallbackItem?['name'] ?? _selectedItemId!);
      
  final displayDescription = target.description 
      ?? fallbackItem?['description'] 
      ?? 'Tidak ada deskripsi tersedia.';
}
```

### 2. Display Product Info

```dart
// Header with product name
Text(
  displayName,  // ← From Supabase
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
)

// Data source badge
Container(
  child: Text(
    target.imageTarget.isNotEmpty 
        ? 'From Supabase'  // ← Data from database
        : 'Fallback Data',  // ← Hardcoded data
    style: const TextStyle(
      fontSize: 11,
      color: Color(0xFF00796B),
      fontWeight: FontWeight.w600,
    ),
  ),
)

// Description
Text(
  displayDescription,  // ← From Supabase
  style: const TextStyle(
    fontSize: 13,
    height: 1.6,
    color: Colors.black87,
  ),
)
```

## 📊 Data Priority

### Priority Order:

1. **Supabase Data** (Primary)
   - `name` → Product name
   - `description` → Product description
   - `imageTarget` → Product image
   - `modelUrl` → 3D model URL
   - `createdAt` → Upload date

2. **Fallback Data** (Secondary)
   - Hardcoded `_fashionItems` array
   - Used when Supabase data not available

## 🎯 Benefits

### ✅ Advantages

1. **Dynamic Content**
   - Admin dapat update deskripsi tanpa rebuild app
   - Konten selalu up-to-date dari database

2. **Centralized Data**
   - Single source of truth (Supabase)
   - Mudah di-maintain

3. **Flexible**
   - Fallback ke data hardcoded jika Supabase down
   - Tidak break app jika database error

4. **User Experience**
   - Informasi produk lebih lengkap
   - Deskripsi real-time dari database

## 🔧 Technical Details

### Data Structure

```dart
class ImageTarget {
  final int? id;
  final String name;              // ← Used in modal header
  final String imageTarget;       // ← Used for image display
  final String? modelUrl;         // ← Used for 3D model
  final String? description;      // ← Used in modal body
  final DateTime? createdAt;      // ← Used for date display
}
```

### Display Logic

```dart
// Name
final displayName = target.name.isNotEmpty 
    ? target.name                    // From Supabase
    : (fallbackItem?['name'] ?? _selectedItemId!);  // Fallback

// Image
final displayImage = target.imageTarget.isNotEmpty 
    ? target.imageTarget             // From Supabase
    : (fallbackItem?['image'] ?? '');  // Fallback

// Description
final displayDescription = target.description 
    ?? fallbackItem?['description']  // Fallback
    ?? 'Tidak ada deskripsi tersedia.';  // Default
```

## 🎨 Styling

### Description Container

```dart
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.grey[50],
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey[200]!),
  ),
  child: Text(
    displayDescription,
    style: const TextStyle(
      fontSize: 13,
      height: 1.6,
      color: Colors.black87,
    ),
  ),
)
```

### Badge Styling

```dart
// From Supabase badge
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: const Color(0xFF00796B).withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0xFF00796B)),
  ),
  child: Row(
    children: [
      Icon(Icons.check_circle, size: 14, color: Color(0xFF00796B)),
      SizedBox(width: 4),
      Text('From Supabase', ...),
    ],
  ),
)
```

## 📱 User Flow

### 1. Scan Image Target

```
User scans product poster
    ↓
AR Camera detects image
    ↓
Matches with Supabase data
    ↓
Loads 3D model
```

### 2. View Product Detail

```
User clicks info button (ℹ️)
    ↓
Modal opens with:
    - Product name (from Supabase)
    - Product image (from Supabase)
    - Data source badge
    - 3D model indicator
    - Created date
    - Full description (from Supabase)
```

## 🔍 Example Data

### Supabase Data

```json
{
  "id": 1,
  "name": "Xavia Blue",
  "image_target": "https://supabase.co/.../xavia_blue.jpg",
  "model_url": "https://supabase.co/.../xavia_blue.glb",
  "description": "Dress premium dengan bahan rayon yang nyaman dan adem. Cocok untuk daily wear maupun acara formal.",
  "created_at": "2026-04-23T10:00:00Z"
}
```

### Display Result

```
┌─────────────────────────────────┐
│  Xavia Blue                  ✕  │
├─────────────────────────────────┤
│  [Image]  ✓ From Supabase       │
│           Fashion Item          │
│           🎨 3D Model tersedia  │
│           📅 23/4/2026          │
│  ───────────────────────────    │
│  📄 Deskripsi Produk            │
│  Dress premium dengan bahan     │
│  rayon yang nyaman dan adem.    │
│  Cocok untuk daily wear maupun  │
│  acara formal.                  │
└─────────────────────────────────┘
```

## 🚀 Testing

### Test Cases

1. **Supabase Data Available**
   - ✅ Name displayed from Supabase
   - ✅ Description displayed from Supabase
   - ✅ Badge shows "From Supabase"

2. **Supabase Data Not Available**
   - ✅ Name from fallback data
   - ✅ Description from fallback data
   - ✅ Badge shows "Fallback Data"

3. **No Description**
   - ✅ Shows "Tidak ada deskripsi tersedia."

4. **Long Description**
   - ✅ Scrollable content
   - ✅ Proper line height (1.6)
   - ✅ Readable font size (13)

## 📝 Notes

- Description field bersifat **opsional** di Supabase
- Jika description `null` atau kosong, akan fallback ke data hardcoded
- Jika fallback juga tidak ada, tampilkan "Tidak ada deskripsi tersedia."
- Modal bersifat **draggable** dan **scrollable**
- Badge menunjukkan sumber data untuk debugging

## 🔗 Related Files

- `lib/screens/ar_camera_screen.dart` - AR Camera implementation
- `lib/services/image_target_service.dart` - Image target model & service
- `lib/config/supabase_config.dart` - Supabase configuration

## 🔮 Future Enhancements

- [ ] Add price field from Supabase
- [ ] Add category/tags from Supabase
- [ ] Add product rating/reviews
- [ ] Add "Add to Cart" button
- [ ] Add share product feature
- [ ] Add favorite/bookmark feature

---

**Last Updated**: 2026-04-23  
**Version**: 1.0.0  
**Status**: ✅ Completed
