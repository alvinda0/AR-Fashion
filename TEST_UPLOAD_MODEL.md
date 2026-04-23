# Testing Upload Model Feature

## 🧪 Test Cases

### 1. Upload Model - Happy Path
**Steps:**
1. Buka aplikasi
2. Klik "Upload Model"
3. Klik "Pilih File"
4. Pilih file GLB valid
5. Masukkan nama "Test Model"
6. Klik "Simpan"

**Expected Result:**
- ✅ File berhasil diupload
- ✅ Muncul di list dengan nama "Test Model"
- ✅ SnackBar success muncul
- ✅ File tersimpan di app directory

### 2. Upload Model - Cancel
**Steps:**
1. Klik "Upload Model"
2. Klik "Pilih File"
3. Cancel file picker

**Expected Result:**
- ✅ Tidak ada perubahan
- ✅ Tetap di halaman upload

### 3. Upload Model - Cancel Name Dialog
**Steps:**
1. Klik "Pilih File"
2. Pilih file GLB
3. Klik "Batal" di dialog nama

**Expected Result:**
- ✅ Upload dibatalkan
- ✅ File tidak tersimpan

### 4. View Model Info
**Steps:**
1. Upload model
2. Klik icon info pada model

**Expected Result:**
- ✅ Dialog muncul dengan info:
  - ID
  - Nama file
  - Tanggal upload
  - Path lengkap

### 5. Delete Model
**Steps:**
1. Upload model
2. Klik icon delete
3. Klik "Hapus" di confirmation dialog

**Expected Result:**
- ✅ Model hilang dari list
- ✅ File terhapus dari storage
- ✅ SnackBar konfirmasi muncul

### 6. Delete Model - Cancel
**Steps:**
1. Klik icon delete
2. Klik "Batal"

**Expected Result:**
- ✅ Model tetap ada
- ✅ Tidak ada perubahan

### 7. Empty State
**Steps:**
1. Buka upload screen tanpa model

**Expected Result:**
- ✅ Icon inventory muncul
- ✅ Text "Belum ada model yang diupload"

### 8. Multiple Models
**Steps:**
1. Upload 3 model berbeda

**Expected Result:**
- ✅ Semua model muncul di list
- ✅ Sorted by upload date (newest first)
- ✅ Setiap model punya action buttons

### 9. Large File
**Steps:**
1. Upload file >50MB

**Expected Result:**
- ✅ Loading indicator muncul
- ✅ Upload berhasil (mungkin lambat)
- ⚠️ Atau error jika terlalu besar

### 10. Invalid File Type
**Steps:**
1. Coba pilih file .obj atau .fbx

**Expected Result:**
- ✅ File picker tidak menampilkan file tersebut
- ✅ Hanya GLB/GLTF yang bisa dipilih

## 📱 Responsive Testing

### Tablet Mode (width > 600px)
- [ ] Padding lebih besar
- [ ] Font size lebih besar
- [ ] Icon size lebih besar
- [ ] Layout tetap rapi

### Landscape Mode
- [ ] Content tidak terpotong
- [ ] Scrollable jika perlu
- [ ] Button tetap accessible

### Small Screen
- [ ] Content tidak overflow
- [ ] Text readable
- [ ] Button tidak terlalu kecil

## 🔄 State Management Testing

### Loading State
- [ ] Muncul saat pertama load
- [ ] Muncul saat upload
- [ ] CircularProgressIndicator visible

### Empty State
- [ ] Muncul saat tidak ada model
- [ ] Icon dan text centered
- [ ] Warna sesuai theme

### Error State
- [ ] Dialog error muncul
- [ ] Message jelas dan helpful
- [ ] User bisa close dialog

## 💾 Data Persistence Testing

### After Upload
1. Upload model
2. Close app
3. Reopen app
4. Check model masih ada

**Expected:**
- ✅ Model tetap ada di list
- ✅ File masih ada di storage

### After Delete
1. Delete model
2. Close app
3. Reopen app
4. Check model tidak ada

**Expected:**
- ✅ Model tidak muncul
- ✅ File terhapus dari storage

## 🐛 Error Scenarios

### No Storage Space
**Simulate:**
- Device storage penuh

**Expected:**
- ❌ Error dialog muncul
- ❌ Upload gagal
- ✅ App tidak crash

### Corrupted File
**Simulate:**
- Upload file GLB yang corrupt

**Expected:**
- ⚠️ File tetap tersimpan (no validation yet)
- ⚠️ Error saat render (future feature)

### Permission Denied
**Simulate:**
- Revoke storage permission

**Expected:**
- ❌ File picker error
- ❌ Upload gagal
- ✅ Error message muncul

## 📊 Performance Testing

### Upload Speed
- Small file (<5MB): < 2 seconds
- Medium file (5-20MB): < 5 seconds
- Large file (20-50MB): < 15 seconds

### List Performance
- 10 models: Smooth scrolling
- 50 models: Still smooth
- 100+ models: May need pagination

### Memory Usage
- Monitor memory saat upload
- Check for memory leaks
- Profile dengan DevTools

## 🔐 Security Testing

### File Path Injection
- Try upload dengan nama file aneh
- Check path sanitization

### Storage Access
- Verify file hanya accessible oleh app
- Check permission requirements

## ✅ Checklist Sebelum Release

### Functionality
- [x] Upload GLB works
- [x] Upload GLTF works
- [x] Delete works
- [x] View info works
- [x] List display works
- [x] Empty state works
- [x] Loading state works
- [x] Error handling works

### UI/UX
- [x] Responsive design
- [x] Consistent theme
- [x] Clear feedback
- [x] Intuitive navigation

### Code Quality
- [x] No lint errors
- [x] No diagnostics errors
- [x] Proper error handling
- [x] Clean code structure

### Documentation
- [x] User guide created
- [x] Developer docs created
- [x] Code comments added
- [x] README updated

## 🎯 Test Data

### Sample GLB Files
Untuk testing, gunakan file dari:
1. `assets/glb/` (jika ada)
2. Download dari Sketchfab
3. Convert dari FBX di `assets/fbx/`

### Test File Sizes
- Small: < 5MB
- Medium: 5-20MB
- Large: 20-50MB
- Very Large: > 50MB

## 📝 Test Results Template

```
Date: ___________
Tester: ___________
Device: ___________
OS Version: ___________

Test Case | Status | Notes
----------|--------|-------
Upload Happy Path | ☐ Pass ☐ Fail | 
Upload Cancel | ☐ Pass ☐ Fail |
View Info | ☐ Pass ☐ Fail |
Delete Model | ☐ Pass ☐ Fail |
Empty State | ☐ Pass ☐ Fail |
Multiple Models | ☐ Pass ☐ Fail |
Tablet Mode | ☐ Pass ☐ Fail |
Landscape Mode | ☐ Pass ☐ Fail |
Data Persistence | ☐ Pass ☐ Fail |

Overall: ☐ Pass ☐ Fail

Issues Found:
1. 
2. 
3. 
```

## 🚀 Next Steps After Testing

1. Fix any bugs found
2. Optimize performance issues
3. Add missing features
4. Update documentation
5. Prepare for release

---

**Test Plan Version**: 1.0  
**Created**: April 23, 2026  
**Last Updated**: April 23, 2026
