# Quick Start: Description Field

## 🚀 Setup (5 menit)

### Step 1: Update Database

Buka Supabase SQL Editor dan jalankan:

```sql
ALTER TABLE image_targets 
ADD COLUMN IF NOT EXISTS description TEXT;
```

**URL**: https://supabase.com/dashboard/project/qerzhadqtgkckrejxcqg/editor

### Step 2: Rebuild App

```bash
flutter clean
flutter pub get
flutter run
```

### Step 3: Test

1. Buka app
2. Klik "Upload" di Image Target screen
3. Isi nama dan deskripsi
4. Upload gambar
5. Lihat deskripsi muncul di card dan preview

## ✅ Done!

---

## 📱 Cara Pakai

### Upload dengan Deskripsi

1. **Klik** tombol "Upload" di header
2. **Isi** nama (wajib)
3. **Isi** deskripsi (opsional) - contoh: "Sepatu hitam dengan sol putih"
4. **Pilih** model 3D (opsional)
5. **Klik** "Pilih Gambar"
6. **Pilih** file gambar
7. **Selesai** - deskripsi akan muncul di card

### Lihat Deskripsi

- **Di Card**: Deskripsi muncul di bawah nama (max 2 baris)
- **Di Preview**: Klik card → lihat deskripsi lengkap

---

## 🎯 Tips

✅ **Good**: "Sepatu olahraga Nike warna hitam dengan sol putih"  
❌ **Bad**: "Bagus" (terlalu singkat)

✅ **Good**: "Tas kulit coklat dengan tali panjang"  
❌ **Bad**: "..." (tidak informatif)

---

## 🔧 Troubleshooting

### Deskripsi tidak muncul?

1. Pastikan kolom `description` sudah ada di database
2. Restart app
3. Upload image target baru dengan deskripsi

### Error saat upload?

1. Check internet connection
2. Check Supabase credentials
3. Check database permissions

---

## 📚 Dokumentasi Lengkap

- [DESCRIPTION_FIELD_GUIDE.md](./DESCRIPTION_FIELD_GUIDE.md) - Guide lengkap
- [CHANGELOG_ADD_DESCRIPTION.md](./CHANGELOG_ADD_DESCRIPTION.md) - Changelog detail

---

**Last Updated**: 2026-04-23
