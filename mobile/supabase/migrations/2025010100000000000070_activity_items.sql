-- =============================================================================
-- Waydeck SQL Migration: 070_activity_items.sql
-- Purpose: Create activity_items table for activity-type trip items
-- =============================================================================

-- Activity items: additional details for activity-type trip items (tours, events, etc.)
-- Linked 1:1 with trip_items where type = 'activity'
CREATE TABLE IF NOT EXISTS public.activity_items (
    trip_item_id UUID PRIMARY KEY REFERENCES public.trip_items(id) ON DELETE CASCADE,
    category TEXT,                        -- e.g., "tour", "museum", "food", "nightlife"
    location_name TEXT,                   -- e.g., "Ba Na Hills", "War Remnants Museum"
    address TEXT,
    city TEXT,
    country_code CHAR(2),

    -- Times (stored with timezone for local display)
    start_local TIMESTAMPTZ,
    end_local TIMESTAMPTZ,

    -- Booking information
    booking_code TEXT,                    -- Ticket/booking reference
    booking_url TEXT,                     -- Link to booking confirmation

    -- Location coordinates (for future map integration)
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,

    -- Additional data
    extra JSONB
);

-- Add comments for documentation
COMMENT ON TABLE public.activity_items IS 'Activity details for trip items of type activity';
COMMENT ON COLUMN public.activity_items.category IS 'Activity category: tour, museum, food, nightlife, etc.';
COMMENT ON COLUMN public.activity_items.location_name IS 'Name of the venue or attraction';

-- Enable Row Level Security
ALTER TABLE public.activity_items ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage activity items only for their own trips
DROP POLICY IF EXISTS "Users can manage activities of own trips" ON public.activity_items;
CREATE POLICY "Users can manage activities of own trips"
    ON public.activity_items
    FOR ALL
    USING (
        trip_item_id IN (
            SELECT ti.id
            FROM public.trip_items ti
            JOIN public.trips t ON t.id = ti.trip_id
            WHERE t.owner_id = auth.uid()
        )
    )
    WITH CHECK (
        trip_item_id IN (
            SELECT ti.id
            FROM public.trip_items ti
            JOIN public.trips t ON t.id = ti.trip_id
            WHERE t.owner_id = auth.uid()
        )
    );

-- Create indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_activity_items_category ON public.activity_items(category);
CREATE INDEX IF NOT EXISTS idx_activity_items_city ON public.activity_items(city);
CREATE INDEX IF NOT EXISTS idx_activity_items_booking ON public.activity_items(booking_code) WHERE booking_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_activity_items_location ON public.activity_items(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
