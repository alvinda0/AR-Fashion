# Delete Fashion Model - Guide

## 📋 Overview

Fitur untuk menghapus model 3D fashion dari Supabase storage `ar-fashion-glb` langsung dari aplikasi.

## ✨ Features

### ✅ Implemented

1. **Delete Button**
   - Tombol delete (🗑️) di setiap fashion model card
   - Warna merah untuk indikasi destructive action

2. **Confirmation Dialog**
   - Dialog konfirmasi sebelum hapus
   - Warning message tentang konsekuensi
   - Badge warning dengan icon ⚠️

3. **Delete from Supabase**
   - Hapus file dari storage `ar-fashion-glb`
   - Loading indicator saat proses delete
   - Success/error message

4. **Auto Reload**
   - List fashion models di-reload otomatis setelah delete
   - UI update langsung

## 🎨 UI Flow

### 1. Fashion Model Card with Delete Button

```
┌─────────────────────────────────────┐
│ 👗 Xavia Blue        [Supabase] 🗑️  │
│    xavia_blue.glb                   │
└─────────────────────────────────────┘
```

### 2. Confirmation Dialog

```
┌─────────────────────────────────────┐
│  Hapus Model Fashion                │
├─────────────────────────────────────┤
│  Apakah Anda yakin ingin menghapus  │
│  "Xavia Blue"?                      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⚠️ File akan dihapus dari    │   │
│  │    Supabase storage          │   │
│  │    ar-fashion-glb            │   │
│  └─────────────────────────────┘   │
│                                     │
│           [Batal]  [Hapus]          │
└─────────────────────────────────────┘
```

### 3. Loading Dialog

```
┌─────────────────────────────────────┐
│  ⏳ Loading...                      │
│                                     │
│  Menghapus dari Supabase...         │
└─────────────────────────────────────┘
```

### 4. Success Message

```
┌─────────────────────────────────────┐
│ ✅ Model "Xavia Blue" berhasil      │
│    dihapus dari Supabase            │
└─────────────────────────────────────┘
```

## 💻 Code Implementation

### 1. Delete Button in Card

```dart
Widget _buildFashionModelCard(Map<String, String> model, bool isTablet) {
  return Container(
    child: ListTile(
      // ... other properties
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Supabase badge
          Container(...),
          
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => _deleteFashionModel(model),
          ),
        ],
      ),
    ),
  );
}
```

### 2. Delete Function

```dart
Future<void> _deleteFashionModel(Map<String, String> model) async {
  // 1. Show confirmation dialog
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Model Fashion'),
      content: Column(
        children: [
          Text('Apakah Anda yakin ingin menghapus "${model['name']}"?'),
          
          // Warning box
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                Text('File akan dihapus dari Supabase storage ar-fashion-glb'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    // 2. Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Menghapus dari Supabase...'),
          ],
        ),
      ),
    );
    
    try {
      // 3. Delete from Supabase
      final supabase = SupabaseConfig.client;
      await supabase.storage
          .from('ar-fashion-glb')
          .remove([model['fileName']!]);
      
      // 4. Close loading
      Navigator.of(context).pop();
      
      // 5. Reload list
      await _loadFashionModels();
      
      // 6. Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Model "${model['name']}" berhasil dihapus dari Supabase'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      // Close loading
      Navigator.of(context).pop();
      
      // Show error
      _showErrorDialog('Error deleting fashion model: $e');
    }
  }
}
```

## 🔄 Data Flow

```
User clicks delete button (🗑️)
    ↓
Show confirmation dialog
    ├─ User clicks "Batal" → Cancel
    └─ User clicks "Hapus" → Continue
        ↓
    Show loading dialog
        ↓
    Delete from Supabase storage
        ↓
    supabase.storage.from('ar-fashion-glb').remove([fileName])
        ↓
    Close loading dialog
        ↓
    Reload fashion models list
        ↓
    Show success message
        ↓
    UI updated (model removed from list)
```

## ⚠️ Warning Dialog

### Warning Box Styling

```dart
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.orange.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.orange),
  ),
  child: Row(
    children: [
      const Icon(
        Icons.warning_amber,
        color: Colors.orange,
        size: 20,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'File akan dihapus dari Supabase storage ar-fashion-glb',
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange[900],
          ),
        ),
      ),
    ],
  ),
)
```

## 🎯 User Experience

### Scenario 1: Successful Delete

```
1. User sees fashion model "Xavia Blue"
2. User clicks delete button (🗑️)
3. Confirmation dialog appears with warning
4. User clicks "Hapus"
5. Loading dialog shows "Menghapus dari Supabase..."
6. File deleted from storage
7. Success message: "Model 'Xavia Blue' berhasil dihapus"
8. Model removed from list
```

### Scenario 2: Cancel Delete

```
1. User clicks delete button (🗑️)
2. Confirmation dialog appears
3. User clicks "Batal"
4. Dialog closes
5. No changes made
```

### Scenario 3: Delete Error

```
1. User clicks delete button (🗑️)
2. Confirmation dialog appears
3. User clicks "Hapus"
4. Loading dialog shows
5. Error occurs (network, permission, etc.)
6. Error dialog shows: "Error deleting fashion model: ..."
7. Model still in list
```

## 🔒 Permissions

### Supabase Storage Policy

Pastikan policy di Supabase storage `ar-fashion-glb` mengizinkan delete:

```sql
-- Allow authenticated users to delete files
CREATE POLICY "Allow delete for authenticated users"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'ar-fashion-glb');

-- Or allow public delete (not recommended for production)
CREATE POLICY "Allow public delete"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'ar-fashion-glb');
```

## 🚀 Testing

### Test Cases

1. **Delete Fashion Model**
   - ✅ Click delete button
   - ✅ Confirmation dialog appears
   - ✅ Warning message visible
   - ✅ Click "Hapus"
   - ✅ Loading dialog shows
   - ✅ File deleted from Supabase
   - ✅ Success message shows
   - ✅ Model removed from list

2. **Cancel Delete**
   - ✅ Click delete button
   - ✅ Click "Batal"
   - ✅ Dialog closes
   - ✅ No changes made

3. **Delete Error**
   - ✅ Simulate network error
   - ✅ Error dialog shows
   - ✅ Model still in list

4. **Permission Error**
   - ✅ Test without proper permissions
   - ✅ Error message shows
   - ✅ Graceful handling

## 📝 Notes

### Important Considerations

1. **Permanent Action**
   - Delete adalah permanent action
   - File tidak bisa di-recover setelah dihapus
   - Warning message harus jelas

2. **Impact on Image Targets**
   - Jika model digunakan di image target, link akan broken
   - Consider checking references before delete
   - Or implement cascade delete

3. **Permissions**
   - Pastikan user memiliki permission untuk delete
   - Handle permission errors dengan baik

4. **Network Errors**
   - Handle network errors gracefully
   - Show clear error messages
   - Don't leave UI in inconsistent state

## 🔮 Future Enhancements

- [ ] Check if model is used in image targets before delete
- [ ] Show warning if model is referenced
- [ ] Implement soft delete (mark as deleted, don't remove file)
- [ ] Add undo delete feature
- [ ] Batch delete multiple models
- [ ] Add delete confirmation with password/PIN
- [ ] Log delete actions for audit trail
- [ ] Add recycle bin feature

---

**Last Updated**: 2026-04-23  
**Version**: 1.0.0  
**Status**: ✅ Completed
