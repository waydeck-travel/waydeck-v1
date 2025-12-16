-- =============================================================================
-- Waydeck SQL Migration: 180_global_documents_storage.sql
-- Purpose: Create storage bucket and policies for global documents
-- Version: 1.1
-- Depends on: 160_global_documents.sql
-- =============================================================================

-- ============================================
-- Storage Bucket: global_documents
-- ============================================
-- Purpose: Stores global travel documents (passport, visa, insurance, etc.)
-- Access: Private (only document owner can access)
--
-- Settings (configure in Supabase Dashboard > Storage > New bucket):
--   - Name: global_documents
--   - Public: false
--   - File size limit: 10MB
--   - Allowed MIME types: application/pdf, image/jpeg, image/png, image/webp

-- ============================================
-- Storage Policies for global_documents bucket
-- ============================================

-- Allow authenticated users to upload their own global documents
-- Path pattern: global_documents/{user_id}/{filename}
CREATE POLICY "Users can upload global documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'global_documents' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to view their own global documents
CREATE POLICY "Users can view own global documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'global_documents' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to update their own global documents
CREATE POLICY "Users can update own global documents"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'global_documents' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to delete their own global documents
CREATE POLICY "Users can delete own global documents"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'global_documents' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================
-- Manual Steps Required in Supabase Dashboard:
-- ============================================
-- 1. Go to Storage in your Supabase project
-- 2. Click "New bucket"
-- 3. Create bucket with:
--    - Name: global_documents
--    - Public: false (unchecked)
--    - File size limit: 10485760 (10MB)
--    - Allowed MIME types: application/pdf,image/jpeg,image/png,image/webp
-- 4. The policies above will be automatically applied when you run this SQL
-- ============================================
