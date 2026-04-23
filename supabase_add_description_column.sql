-- ============================================
-- Add Description Column to image_targets Table
-- ============================================
-- 
-- This script adds a 'description' column to the existing
-- image_targets table in Supabase.
--
-- Run this in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/YOUR_PROJECT/editor
--
-- ============================================

-- Add description column (nullable, TEXT type)
ALTER TABLE image_targets 
ADD COLUMN IF NOT EXISTS description TEXT;

-- Add comment to the column
COMMENT ON COLUMN image_targets.description IS 'Optional description for the image target';

-- Verify the column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'image_targets'
ORDER BY ordinal_position;

-- ============================================
-- Expected Result:
-- ============================================
-- column_name    | data_type                   | is_nullable
-- ---------------+-----------------------------+-------------
-- id             | integer                     | NO
-- name           | text                        | NO
-- image_target   | text                        | NO
-- model_url      | text                        | YES
-- description    | text                        | YES  ← NEW
-- created_at     | timestamp with time zone    | YES
-- ============================================
