-- =============================================================================
-- Waydeck SQL Migration: 001_init_extensions.sql
-- Purpose: Enable required PostgreSQL extensions
-- =============================================================================

-- Enable pgcrypto for gen_random_uuid() function
-- This is typically already enabled in Supabase, but we include it for completeness
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Note: Supabase projects usually have pgcrypto enabled by default.
-- If you encounter an error, this extension may already exist.
