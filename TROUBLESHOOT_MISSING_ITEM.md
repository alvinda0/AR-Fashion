# Troubleshooting: Item "Dress Tes Custom" Tidak Muncul

## 🔍 **Status Debug:**

### ✅ **Yang Sudah Dikonfirmasi Benar:**
- File GLB ada di: `assets/models/clothing/dresses/tes.glb`
- Data service sudah diupdate dengan item `dress_tes`
- Debug test menunjukkan 3 dress items termasuk "Dress Tes Custom"
- Kategori "dresses" ada dalam list categories

### 🐛 **Kemungkinan Penyebab:**

#### **1. Hot Reload Issue**
Flutter hot reload mungkin tidak mengupdate singleton data service.

**Solusi:**
```bash
# Stop aplikasi dan restart penuh
flutter clean
flutter pub get
flutter run
```

#### **2. Cache Issue**
Build cache mungkin masih menggunakan data lama.

**Solusi:**
```bash
# Clear semua cache
flutter clean
rm -rf .dart_tool
flutter pub get
flutter run
```

#### **3. Singleton Pattern Issue**
Data service singleton mungkin tidak ter-refresh.

**Solusi:** Restart aplikasi penuh (bukan hot reload).

## 🚀 **Langkah Troubleshooting:**

### **Step 1: Restart Aplikasi Penuh**
```bash
# Stop aplikasi yang sedang running
# Kemudian jalankan:
flutter clean
flutter pub get
flutter run
```

### **Step 2: Check Debug Output**
Setelah restart, lihat console output untuk debug messages:
```
🔍 DEBUG: Categories found: [shirts, jackets, dresses]
🔍 DEBUG: Category "dresses" has 3 items
🔍 DEBUG: Dress item: Dress Musim Panas (dress_001)
🔍 DEBUG: Dress item: Dress Malam Elegan (dress_002)
🔍 DEBUG: Dress item: Dress Tes Custom (dress_tes)
```

### **Step 3: Test di Aplikasi**
1. Buka aplikasi
2. Tap "Mulai AR Try-On"
3. Tap tombol fashion selector (👔)
4. Pilih tab "Dress"
5. Cari "Dress Tes Custom"

### **Step 4: Jika Masih Tidak Muncul**

#### **Cek File GLB Exists:**
```bash
# Windows
dir assets\models\clothing\dresses\tes.glb

# Linux/macOS
ls -la assets/models/clothing/dresses/tes.glb
```

#### **Validate GLB File:**
Test file di online viewer:
- https://gltf-viewer.donmccurdy.com/
- Drag & drop file `tes.glb`

#### **Check pubspec.yaml:**
Pastikan assets terdaftar:
```yaml
flutter:
  assets:
    - assets/models/
    - assets/textures/
    - assets/images/
```

## 🔧 **Alternative Solutions:**

### **Solution 1: Force Refresh Data Service**
Tambahkan method refresh di data service:

```dart
// Di fashion_data_service.dart
void refreshData() {
  // Force refresh singleton
  print('🔄 Refreshing fashion data...');
}
```

### **Solution 2: Add Debug Button**
Tambahkan debug button di UI untuk test data:

```dart
// Di ar_camera_screen.dart
FloatingActionButton(
  onPressed: () {
    final service = FashionDataService();
    final dresses = service.getItemsByCategory('dresses');
    print('Debug: Found ${dresses.length} dresses');
    for (final dress in dresses) {
      print('- ${dress.name}');
    }
  },
  child: Icon(Icons.bug_report),
),
```

### **Solution 3: Hardcode Test**
Sementara untuk testing, tambahkan item langsung di widget:

```dart
// Di fashion_selector.dart, tambahkan manual item
final testItem = FashionItem(
  id: 'dress_tes_manual',
  name: 'Dress Tes Manual',
  category: 'dresses',
  modelPath: 'assets/models/clothing/dresses/tes.glb',
  thumbnailPath: 'assets/images/dress_tes_thumb.jpg',
  description: 'Manual test item',
  colors: ['Test'],
  sizes: ['S'],
  price: 100000,
);
```

## 📱 **Expected Behavior:**

Setelah restart penuh, Anda harus melihat:

### **Di Tab "Dress":**
1. Dress Musim Panas
2. Dress Malam Elegan  
3. **Dress Tes Custom** ← Item Anda

### **Debug Console Output:**
```
🔍 DEBUG: Categories found: [shirts, jackets, dresses]
🔍 DEBUG: Category "dresses" has 3 items
🔍 DEBUG: Dress item: Dress Tes Custom (dress_tes)
🔍 DEBUG: _buildItemGrid called with 3 items
🔍 DEBUG: Item in grid: Dress Tes Custom
```

## ⚡ **Quick Fix Commands:**

```bash
# Stop aplikasi, clean, dan restart
flutter clean
flutter pub get
flutter run

# Jika masih tidak muncul, coba:
flutter clean
rm -rf .dart_tool
rm -rf build
flutter pub get
flutter run
```

## 🎯 **Next Steps:**

1. **Restart aplikasi penuh** (paling penting!)
2. Check debug output di console
3. Test di tab "Dress"
4. Jika masih tidak muncul, laporkan debug output yang muncul

**Kemungkinan besar masalahnya adalah hot reload yang tidak mengupdate data service singleton. Restart penuh akan menyelesaikan masalah ini! 🚀**