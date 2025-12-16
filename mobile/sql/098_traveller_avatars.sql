-- Migration: Add avatar support to travellers
-- Adds avatar_url column and creates storage bucket

-- Add avatar_url column to travellers
ALTER TABLE public.travellers 
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Note: Storage bucket 'traveller-avatars' needs to be created in Supabase Dashboard
-- Storage > New Bucket > Name: traveller-avatars, Public: true

-- Storage policy for traveller avatars (run in Storage > Policies)
-- Users can upload their own traveller avatars:
-- INSERT: (bucket_id = 'traveller-avatars') AND (auth.uid()::text = (storage.foldername(name))[1])
-- SELECT: (bucket_id = 'traveller-avatars')
-- DELETE: (bucket_id = 'traveller-avatars') AND (auth.uid()::text = (storage.foldername(name))[1])
