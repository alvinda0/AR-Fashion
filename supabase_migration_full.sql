-- ============================================================
-- FULL MIGRATION: AR Fashion App
-- Jalankan di Supabase Dashboard → SQL Editor
-- https://supabase.com/dashboard/project/qerzhadqtgkckrejxcqg/editor
-- ============================================================

-- ============================================================
-- PART 1: TABEL image_target
-- ============================================================

CREATE TABLE IF NOT EXISTS image_target (
  id          BIGSERIAL PRIMARY KEY,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  name        VARCHAR NOT NULL,
  image_target TEXT NOT NULL,
  model_url   TEXT,
  description TEXT
);

-- Enable Row Level Security
ALTER TABLE image_target ENABLE ROW LEVEL SECURITY;

-- Drop existing policies dulu biar tidak conflict
DROP POLICY IF EXISTS "Allow all operations on image_target" ON image_target;

-- Policy: allow semua operasi (public, tanpa auth)
CREATE POLICY "Allow all operations on image_target"
ON image_target
FOR ALL
USING (true)
WITH CHECK (true);

-- ============================================================
-- PART 2: STORAGE BUCKET image_target
-- ============================================================

-- Buat bucket 'image_target' (public)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'image_target',
  'image_target',
  true,
  52428800, -- 50MB
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id)
DO UPDATE SET
  public = true,
  file_size_limit = 52428800,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];

-- Drop existing storage policies dulu
DROP POLICY IF EXISTS "Public read image_target bucket"   ON storage.objects;
DROP POLICY IF EXISTS "Public upload image_target bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public delete image_target bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public update image_target bucket" ON storage.objects;

-- Policy: READ
CREATE POLICY "Public read image_target bucket"
ON storage.objects FOR SELECT
USING (bucket_id = 'image_target');

-- Policy: INSERT (upload)
CREATE POLICY "Public upload image_target bucket"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'image_target');

-- Policy: DELETE
CREATE POLICY "Public delete image_target bucket"
ON storage.objects FOR DELETE
USING (bucket_id = 'image_target');

-- Policy: UPDATE
CREATE POLICY "Public update image_target bucket"
ON storage.objects FOR UPDATE
USING (bucket_id = 'image_target')
WITH CHECK (bucket_id = 'image_target');

-- ============================================================
-- PART 3: VERIFIKASI
-- ============================================================

-- Cek tabel
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'image_target'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- Cek bucket
SELECT id, name, public, file_size_limit
FROM storage.buckets
WHERE id = 'image_target';

-- ============================================================
-- SELESAI
-- ============================================================
DO $$
BEGIN
  RAISE NOTICE '✅ Migration completed!';
  RAISE NOTICE '📋 Table "image_target" is ready';
  RAISE NOTICE '📦 Bucket "image_target" is ready';
  RAISE NOTICE '🔐 RLS policies configured';
END $$;
