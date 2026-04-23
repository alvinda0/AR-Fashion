-- ============================================
-- Supabase Storage Setup for AR Fashion App
-- ============================================
-- Run this in Supabase Dashboard → SQL Editor
-- ============================================

-- 1. Create bucket 'images' if not exists (public)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'images', 
  'images', 
  true,
  52428800, -- 50MB
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) 
DO UPDATE SET 
  public = true,
  file_size_limit = 52428800,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];

-- 2. Drop all existing policies on storage.objects
DROP POLICY IF EXISTS "Public can read images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can upload images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can delete images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can update images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;
DROP POLICY IF EXISTS "Allow public upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow public delete" ON storage.objects;
DROP POLICY IF EXISTS "Allow all operations" ON storage.objects;

-- 3. Create new policies for 'images' bucket

-- Policy: Public READ
CREATE POLICY "Public can read images"
ON storage.objects
FOR SELECT
USING (bucket_id = 'images');

-- Policy: Public INSERT (upload)
CREATE POLICY "Anyone can upload images"
ON storage.objects
FOR INSERT
WITH CHECK (bucket_id = 'images');

-- Policy: Public DELETE
CREATE POLICY "Anyone can delete images"
ON storage.objects
FOR DELETE
USING (bucket_id = 'images');

-- Policy: Public UPDATE
CREATE POLICY "Anyone can update images"
ON storage.objects
FOR UPDATE
USING (bucket_id = 'images')
WITH CHECK (bucket_id = 'images');

-- 4. Verify bucket exists
SELECT 
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types,
  created_at
FROM storage.buckets
WHERE id = 'images';

-- 5. Verify policies exist
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'objects'
  AND schemaname = 'storage'
  AND policyname LIKE '%images%';

-- ============================================
-- Expected Output:
-- ============================================
-- Bucket 'images' should show:
--   - public: true
--   - file_size_limit: 52428800
--   - allowed_mime_types: {image/jpeg, image/jpg, image/png, image/gif, image/webp}
--
-- Policies should show 4 rows:
--   1. Public can read images (SELECT)
--   2. Anyone can upload images (INSERT)
--   3. Anyone can delete images (DELETE)
--   4. Anyone can update images (UPDATE)
-- ============================================

-- ============================================
-- OPTIONAL: Create bucket for models (if needed)
-- ============================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'models', 
  'models', 
  true,
  104857600, -- 100MB
  ARRAY['model/gltf-binary', 'model/gltf+json', 'application/octet-stream']
)
ON CONFLICT (id) 
DO UPDATE SET 
  public = true,
  file_size_limit = 104857600;

-- Policies for 'models' bucket
CREATE POLICY "Public can read models"
ON storage.objects
FOR SELECT
USING (bucket_id = 'models');

CREATE POLICY "Anyone can upload models"
ON storage.objects
FOR INSERT
WITH CHECK (bucket_id = 'models');

CREATE POLICY "Anyone can delete models"
ON storage.objects
FOR DELETE
USING (bucket_id = 'models');

CREATE POLICY "Anyone can update models"
ON storage.objects
FOR UPDATE
USING (bucket_id = 'models')
WITH CHECK (bucket_id = 'models');

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
DO $$
BEGIN
  RAISE NOTICE '✅ Storage setup completed successfully!';
  RAISE NOTICE '📦 Bucket "images" is ready';
  RAISE NOTICE '📦 Bucket "models" is ready';
  RAISE NOTICE '🔐 All policies configured';
  RAISE NOTICE '';
  RAISE NOTICE '🚀 You can now upload files from your app!';
END $$;
