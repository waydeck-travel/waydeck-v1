-- =============================================================================
-- Waydeck SQL Migration: 110_profile_extensions.sql
-- Purpose: Extend profiles table with traveller-like fields and user settings
-- Version: 1.1
-- =============================================================================

-- Add traveller-like fields to profiles (mirrors travellers table structure)
-- This allows users to be treated as "self" in passenger pickers

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS email TEXT;

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS phone TEXT;

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS date_of_birth DATE;

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS nationality CHAR(2);

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS passport_number TEXT;

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS passport_expiry DATE;

-- Add user settings columns
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS theme_preference TEXT DEFAULT 'auto';

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS default_currency CHAR(3);

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS notification_enabled BOOLEAN DEFAULT true;

-- Add comments for documentation
COMMENT ON COLUMN public.profiles.email IS 'User email (may be synced from auth.users)';
COMMENT ON COLUMN public.profiles.phone IS 'User phone number';
COMMENT ON COLUMN public.profiles.date_of_birth IS 'User date of birth';
COMMENT ON COLUMN public.profiles.nationality IS 'ISO 3166-1 alpha-2 country code';
COMMENT ON COLUMN public.profiles.passport_number IS 'User passport number';
COMMENT ON COLUMN public.profiles.passport_expiry IS 'Passport expiry date';
COMMENT ON COLUMN public.profiles.theme_preference IS 'UI theme: auto, light, or dark';
COMMENT ON COLUMN public.profiles.default_currency IS 'ISO 4217 currency code for default currency';
COMMENT ON COLUMN public.profiles.notification_enabled IS 'Whether push notifications are enabled';

-- Add check constraint for theme_preference
ALTER TABLE public.profiles
DROP CONSTRAINT IF EXISTS chk_theme_preference;

ALTER TABLE public.profiles
ADD CONSTRAINT chk_theme_preference
CHECK (theme_preference IS NULL OR theme_preference IN ('auto', 'light', 'dark'));

-- Create index for nationality (for filtering by country if needed)
CREATE INDEX IF NOT EXISTS idx_profiles_nationality ON public.profiles(nationality) WHERE nationality IS NOT NULL;
