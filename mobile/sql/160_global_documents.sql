-- =============================================================================
-- Waydeck SQL Migration: 160_global_documents.sql
-- Purpose: Create global_documents table for user-level travel documents
-- Version: 1.1
-- =============================================================================

-- =============================================================================
-- Create global_doc_type enum
-- =============================================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'global_doc_type') THEN
        CREATE TYPE global_doc_type AS ENUM (
            'passport',
            'visa',
            'travel_insurance',
            'health_card',
            'id_card',
            'vaccination_certificate',
            'other'
        );
    END IF;
END
$$;

COMMENT ON TYPE global_doc_type IS 'Types of global travel documents';

-- =============================================================================
-- Create global_documents table
-- =============================================================================

-- Global documents: user-level documents visible across all trips
-- Examples: passport, visa, travel insurance, vaccination certificates
-- These are NOT tied to specific trips (unlike the documents table)

CREATE TABLE IF NOT EXISTS public.global_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    doc_type global_doc_type NOT NULL,
    title TEXT,                            -- Optional custom title/label
    country_code CHAR(2),                  -- For visa: which country it's for
    document_number TEXT,                  -- Passport number, policy number, etc.
    file_name TEXT NOT NULL,               -- Original file name
    mime_type TEXT,                        -- MIME type of the file
    storage_path TEXT NOT NULL,            -- Path in Supabase Storage
    size_bytes BIGINT,                     -- File size in bytes
    issue_date DATE,                       -- Document issue date
    expiry_date DATE,                      -- Document expiry date
    notes TEXT,                            -- Additional notes
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add comments for documentation
COMMENT ON TABLE public.global_documents IS 'User-level travel documents visible across all trips';
COMMENT ON COLUMN public.global_documents.doc_type IS 'Type of document: passport, visa, insurance, etc.';
COMMENT ON COLUMN public.global_documents.country_code IS 'ISO 3166-1 alpha-2 code; for visa = target country';
COMMENT ON COLUMN public.global_documents.document_number IS 'Document identifier (passport #, policy #, etc.)';
COMMENT ON COLUMN public.global_documents.storage_path IS 'Path in Supabase Storage: global_documents/{user_id}/{filename}';
COMMENT ON COLUMN public.global_documents.expiry_date IS 'Document expiry date for tracking validity';

-- Enable Row Level Security
ALTER TABLE public.global_documents ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only manage their own global documents
DROP POLICY IF EXISTS "Users can manage own global documents" ON public.global_documents;
CREATE POLICY "Users can manage own global documents"
    ON public.global_documents
    FOR ALL
    USING (owner_id = auth.uid())
    WITH CHECK (owner_id = auth.uid());

-- Create indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_global_documents_owner_id ON public.global_documents(owner_id);
CREATE INDEX IF NOT EXISTS idx_global_documents_doc_type ON public.global_documents(owner_id, doc_type);
CREATE INDEX IF NOT EXISTS idx_global_documents_expiry ON public.global_documents(owner_id, expiry_date) 
    WHERE expiry_date IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_global_documents_country ON public.global_documents(owner_id, country_code) 
    WHERE country_code IS NOT NULL;
