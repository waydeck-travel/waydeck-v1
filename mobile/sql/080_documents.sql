-- =============================================================================
-- Waydeck SQL Migration: 080_documents.sql
-- Purpose: Create documents table for file attachments (tickets, vouchers, etc.)
-- =============================================================================

-- Documents table: metadata for files stored in Supabase Storage
-- Documents can be attached to a trip (general) or a specific trip item
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    trip_item_id UUID REFERENCES public.trip_items(id) ON DELETE CASCADE,
    doc_type document_type NOT NULL DEFAULT 'other',
    file_name TEXT NOT NULL,
    mime_type TEXT,
    storage_path TEXT NOT NULL,           -- Path in Supabase Storage bucket
    size_bytes BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add comments for documentation
COMMENT ON TABLE public.documents IS 'Metadata for documents stored in Supabase Storage';
COMMENT ON COLUMN public.documents.storage_path IS 'Full path within the trip_documents bucket';
COMMENT ON COLUMN public.documents.trip_id IS 'Optional: attach document to entire trip (e.g., visa)';
COMMENT ON COLUMN public.documents.trip_item_id IS 'Optional: attach document to specific item (e.g., flight ticket)';

-- Add constraint: document must be attached to either trip or trip_item (or both)
ALTER TABLE public.documents DROP CONSTRAINT IF EXISTS chk_document_attachment;
ALTER TABLE public.documents ADD CONSTRAINT chk_document_attachment
    CHECK (trip_id IS NOT NULL OR trip_item_id IS NOT NULL);

-- Enable Row Level Security
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only manage their own documents
DROP POLICY IF EXISTS "Users can manage own documents" ON public.documents;
CREATE POLICY "Users can manage own documents"
    ON public.documents
    FOR ALL
    USING (owner_id = auth.uid())
    WITH CHECK (owner_id = auth.uid());

-- Create indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_documents_owner_id ON public.documents(owner_id);
CREATE INDEX IF NOT EXISTS idx_documents_trip_id ON public.documents(trip_id) WHERE trip_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_documents_trip_item_id ON public.documents(trip_item_id) WHERE trip_item_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_documents_doc_type ON public.documents(doc_type);
