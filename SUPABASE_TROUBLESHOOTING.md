# Supabase Troubleshooting Guide

## ❌ Error: "Supabase not initialized"

### Penyebab:
Supabase belum di-initialize sebelum digunakan.

### Solusi:

#### 1. Cek Console Logs

Saat app start, harus ada log:
```
✅ Supabase initialized successfully
✅ Supabase initialized with URL: https://qerzhadqtgkckrejxcqg.supabase.co
```

Jika ada error:
```
❌ Error initializing Supabase: [error message]
⚠️ App will continue with limited functionality
```

#### 2. Cek Internet Connection

- Pastikan device terhubung ke internet
- Test dengan buka browser
- Coba ping supabase.co

#### 3. Cek Supabase Credentials

File: `lib/config/supabase_config.dart`

```dart
static const String supabaseUrl = 'https://qerzhadqtgkckrejxcqg.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

Pastikan:
- ✅ URL benar (tidak ada typo)
- ✅ Anon key lengkap (tidak terpotong)
- ✅ Tidak ada spasi di awal/akhir

#### 4. Restart Aplikasi

```bash
# Stop app
flutter run --stop

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run again
flutter run
```

#### 5. Hot Restart (bukan Hot Reload)

Di VS Code/Android Studio:
- Press `Shift + R` (hot restart)
- Atau klik icon restart

## ❌ Error: "Failed to initialize Supabase"

### Kemungkinan Penyebab:

#### 1. Network Error

**Symptoms:**
```
SocketException: Failed host lookup
```

**Solution:**
- Cek internet connection
- Cek firewall/proxy settings
- Try different network (WiFi/Mobile data)

#### 2. Invalid Credentials

**Symptoms:**
```
Invalid API key
401 Unauthorized
```

**Solution:**
- Verify URL dan anon key di Supabase Dashboard
- Copy paste ulang (jangan ketik manual)
- Pastikan menggunakan **anon public** key, bukan service_role

#### 3. Supabase Project Paused

**Symptoms:**
```
Project is paused
```

**Solution:**
- Login ke Supabase Dashboard
- Unpause project
- Wait 1-2 minutes
- Restart app

## ❌ Error: "Bucket not found"

### Solusi:

1. **Buka Supabase Dashboard** → **Storage**

2. **Create bucket `images`**:
   - Name: `images`
   - Public: ✅
   - Click "Create bucket"

3. **Verify bucket exists**:
   ```sql
   SELECT * FROM storage.buckets WHERE name = 'images';
   ```

## ❌ Error: "Table does not exist"

### Solusi:

1. **Buka Supabase Dashboard** → **SQL Editor**

2. **Run SQL**:
   ```sql
   CREATE TABLE IF NOT EXISTS image_target (
     id SERIAL PRIMARY KEY,
     name VARCHAR NOT NULL,
     image_target TEXT NOT NULL,
     created_at TIMESTAMPTZ DEFAULT NOW()
   );
   ```

3. **Verify table exists**:
   ```sql
   SELECT * FROM image_target LIMIT 1;
   ```

## ❌ Error: "Row Level Security policy violation"

### Solusi:

1. **Disable RLS (Development Only)**:
   ```sql
   ALTER TABLE image_target DISABLE ROW LEVEL SECURITY;
   ```

2. **Or create allow-all policy**:
   ```sql
   CREATE POLICY "Allow all" ON image_target
     FOR ALL
     USING (true)
     WITH CHECK (true);
   ```

## ❌ Upload Gagal

### Kemungkinan Penyebab:

#### 1. File Too Large

**Solution:**
- Compress image
- Max recommended: 5MB

#### 2. Invalid File Format

**Solution:**
- Use JPG, PNG, or GIF
- Avoid HEIC, WEBP (convert first)

#### 3. Storage Quota Exceeded

**Solution:**
- Check Supabase Dashboard → Settings → Usage
- Upgrade plan or delete old files

## 🔍 Debug Mode

### Enable Verbose Logging

File: `lib/config/supabase_config.dart`

```dart
static Future<void> initialize() async {
  if (_isInitialized) {
    print('⚠️ Supabase already initialized');
    return;
  }
  
  try {
    print('🔄 Initializing Supabase...');
    print('📍 URL: $supabaseUrl');
    print('🔑 Key: ${supabaseAnonKey.substring(0, 20)}...');
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Enable debug mode
    );
    
    _isInitialized = true;
    print('✅ Supabase initialized successfully');
  } catch (e, stackTrace) {
    print('❌ Failed to initialize Supabase: $e');
    print('📚 Stack trace: $stackTrace');
    rethrow;
  }
}
```

### Check Initialization Status

```dart
// In any screen
@override
void initState() {
  super.initState();
  print('Supabase initialized: ${SupabaseConfig.isInitialized}');
  _loadData();
}
```

## 🧪 Test Connection

### Manual Test

```dart
// Add this button to test screen
ElevatedButton(
  onPressed: () async {
    try {
      print('Testing Supabase connection...');
      
      final response = await SupabaseConfig.client
          .from('image_target')
          .select()
          .limit(1);
      
      print('✅ Connection successful!');
      print('Response: $response');
    } catch (e) {
      print('❌ Connection failed: $e');
    }
  },
  child: Text('Test Supabase'),
)
```

## 📱 Platform-Specific Issues

### Android

#### Internet Permission

File: `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

#### Cleartext Traffic (HTTP)

If using HTTP (not recommended):

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

### iOS

#### App Transport Security

File: `ios/Runner/Info.plist`

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🔄 Reset Everything

### Complete Reset

```bash
# 1. Clean Flutter
flutter clean
rm -rf build/
rm -rf .dart_tool/

# 2. Get dependencies
flutter pub get

# 3. Rebuild
flutter run
```

### Reset Supabase Client

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force re-initialize
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e) {
    print('Error: $e');
  }
  
  runApp(const FashionARApp());
}
```

## 📞 Get Help

### Check Logs

1. **Flutter Console**: Check terminal output
2. **Supabase Logs**: Dashboard → Logs
3. **Network Tab**: Chrome DevTools

### Common Log Messages

```
✅ Good:
- "Supabase initialized successfully"
- "Connection successful"
- "Upload complete"

❌ Bad:
- "Supabase not initialized"
- "SocketException"
- "401 Unauthorized"
- "Bucket not found"
```

### Contact Support

If masih error:
1. Copy full error message
2. Copy console logs
3. Screenshot Supabase Dashboard
4. Hubungi developer: Alvinda Shahrul

---

**Last Updated**: April 23, 2026
