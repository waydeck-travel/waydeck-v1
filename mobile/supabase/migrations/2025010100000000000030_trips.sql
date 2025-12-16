-- =============================================================================
-- Waydeck SQL Migration: 030_trips.sql
-- Purpose: Create trips table - the core container for travel itineraries
-- =============================================================================

-- Trips table: each trip represents a complete travel itinerary
CREATE TABLE IF NOT EXISTS public.trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    origin_city TEXT,
    origin_country_code CHAR(2),
    start_date DATE,
    end_date DATE,
    currency CHAR(3),
    notes TEXT,
    archived BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add comments for documentation
COMMENT ON TABLE public.trips IS 'Travel itineraries owned by users';
COMMENT ON COLUMN public.trips.origin_city IS 'Starting city of the trip (e.g., Pune)';
COMMENT ON COLUMN public.trips.origin_country_code IS 'ISO 3166-1 alpha-2 country code (e.g., IN)';
COMMENT ON COLUMN public.trips.currency IS 'ISO 4217 currency code for trip expenses (e.g., USD, INR)';

-- Enable Row Level Security
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Separate policies for each operation
DROP POLICY IF EXISTS "Users can select own trips" ON public.trips;
CREATE POLICY "Users can select own trips"
    ON public.trips
    FOR SELECT
    USING (owner_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert own trips" ON public.trips;
CREATE POLICY "Users can insert own trips"
    ON public.trips
    FOR INSERT
    WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own trips" ON public.trips;
CREATE POLICY "Users can update own trips"
    ON public.trips
    FOR UPDATE
    USING (owner_id = auth.uid())
    WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete own trips" ON public.trips;
CREATE POLICY "Users can delete own trips"
    ON public.trips
    FOR DELETE
    USING (owner_id = auth.uid());

-- Create indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_trips_owner_id ON public.trips(owner_id);
CREATE INDEX IF NOT EXISTS idx_trips_owner_archived ON public.trips(owner_id, archived);
CREATE INDEX IF NOT EXISTS idx_trips_start_date ON public.trips(start_date DESC NULLS LAST);

-- Add updated_at trigger
DROP TRIGGER IF EXISTS on_trips_updated ON public.trips;
CREATE TRIGGER on_trips_updated
    BEFORE UPDATE ON public.trips
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
