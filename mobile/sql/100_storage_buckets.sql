-- ============================================
-- Waydeck Storage Buckets Setup
-- ============================================
-- Run these commands in Supabase Dashboard → Storage
-- or use Supabase CLI: supabase storage create <bucket-name>

-- ============================================
-- 1. Create traveller-avatars bucket
-- ============================================
-- Purpose: Stores profile photos/avatars for travellers
-- Access: Public (avatars are displayed in the app UI)
-- 
-- Settings:
--   - Name: traveller-avatars
--   - Public: true
--   - File size limit: 5MB
--   - Allowed MIME types: image/jpeg, image/png, image/webp

-- ============================================
-- 2. Create trip_documents bucket  
-- ============================================
-- Purpose: Stores document attachments (tickets, vouchers, etc.)
-- Access: Authenticated (only document owner can access)
--
-- Settings:
--   - Name: trip_documents
--   - Public: false
--   - File size limit: 10MB
--   - Allowed MIME types: application/pdf, image/jpeg, image/png, image/webp

-- ============================================
-- Storage Policies for trip_documents bucket
-- ============================================

-- Allow authenticated users to upload their own documents
CREATE POLICY "Users can upload documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'trip_documents' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to view their own documents
CREATE POLICY "Users can view own documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'trip_documents' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to delete their own documents
CREATE POLICY "Users can delete own documents"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'trip_documents' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================
-- Storage Policies for traveller-avatars bucket
-- ============================================

-- Allow authenticated users to upload their own avatars
CREATE POLICY "Users can upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'traveller-avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow anyone to view avatars (public bucket)
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'traveller-avatars');

-- Allow authenticated users to update their own avatars
CREATE POLICY "Users can update own avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'traveller-avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to delete their own avatars
CREATE POLICY "Users can delete own avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'traveller-avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================
-- Manual Steps in Supabase Dashboard:
-- ============================================
-- 1. Go to Storage in your Supabase project
-- 2. Click "New bucket"
-- 3. Create "traveller-avatars" with Public enabled
-- 4. Create "trip_documents" with Public disabled
-- 5. Run the policies above in SQL Editor
-- ============================================
