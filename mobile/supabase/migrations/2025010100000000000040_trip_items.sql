-- =============================================================================
-- Waydeck SQL Migration: 040_trip_items.sql
-- Purpose: Create trip_items base table for all timeline items
-- =============================================================================

-- Trip items: base table for all items in a trip's timeline
-- Each item has a type (transport, stay, activity, note) with details in related tables
CREATE TABLE IF NOT EXISTS public.trip_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    type trip_item_type NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    start_time_utc TIMESTAMPTZ,      -- Nullable for pure notes
    end_time_utc TIMESTAMPTZ,
    local_tz TEXT,                    -- IANA timezone (e.g., 'Asia/Kolkata', 'Asia/Bangkok')
    day_index INT,                    -- Computed, stored for quick grouping by day
    sort_index INT NOT NULL DEFAULT 0,-- For manual ordering within a day
    comment TEXT,                     -- User notes/comments on this item
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add comments for documentation
COMMENT ON TABLE public.trip_items IS 'Base table for all trip timeline items';
COMMENT ON COLUMN public.trip_items.type IS 'Item type: transport, stay, activity, or note';
COMMENT ON COLUMN public.trip_items.local_tz IS 'IANA timezone identifier for local time display';
COMMENT ON COLUMN public.trip_items.day_index IS 'Day number in trip (0-indexed), computed from start_time_utc';
COMMENT ON COLUMN public.trip_items.sort_index IS 'Manual sort order within a day';

-- Enable Row Level Security
ALTER TABLE public.trip_items ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage items only for their own trips
DROP POLICY IF EXISTS "Users can manage items of own trips" ON public.trip_items;
CREATE POLICY "Users can manage items of own trips"
    ON public.trip_items
    FOR ALL
    USING (
        trip_id IN (
            SELECT id FROM public.trips WHERE owner_id = auth.uid()
        )
    )
    WITH CHECK (
        trip_id IN (
            SELECT id FROM public.trips WHERE owner_id = auth.uid()
        )
    );

-- Create indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_trip_items_trip_id ON public.trip_items(trip_id);
CREATE INDEX IF NOT EXISTS idx_trip_items_trip_day ON public.trip_items(trip_id, day_index, sort_index);
CREATE INDEX IF NOT EXISTS idx_trip_items_start_time ON public.trip_items(start_time_utc);
CREATE INDEX IF NOT EXISTS idx_trip_items_type ON public.trip_items(trip_id, type);

-- Add updated_at trigger
DROP TRIGGER IF EXISTS on_trip_items_updated ON public.trip_items;
CREATE TRIGGER on_trip_items_updated
    BEFORE UPDATE ON public.trip_items
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
