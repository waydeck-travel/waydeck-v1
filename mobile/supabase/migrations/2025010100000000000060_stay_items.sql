-- =============================================================================
-- Waydeck SQL Migration: 060_stay_items.sql
-- Purpose: Create stay_items table for accommodation-type trip items
-- =============================================================================

-- Stay items: additional details for stay-type trip items (hotels, hostels, etc.)
-- Linked 1:1 with trip_items where type = 'stay'
CREATE TABLE IF NOT EXISTS public.stay_items (
    trip_item_id UUID PRIMARY KEY REFERENCES public.trip_items(id) ON DELETE CASCADE,
    accommodation_name TEXT NOT NULL,     -- Hotel/hostel/apartment name
    address TEXT,
    city TEXT,
    country_code CHAR(2),

    -- Check-in/out times
    checkin_local TIMESTAMPTZ,
    checkout_local TIMESTAMPTZ,

    -- Amenities
    has_breakfast BOOLEAN NOT NULL DEFAULT false,

    -- Booking information
    confirmation_number TEXT,
    booking_url TEXT,                     -- Link to booking site

    -- Location coordinates (for future map integration)
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,

    -- Additional data
    extra JSONB
);

-- Add comments for documentation
COMMENT ON TABLE public.stay_items IS 'Accommodation details for trip items of type stay';
COMMENT ON COLUMN public.stay_items.has_breakfast IS 'Whether breakfast is included in the stay';
COMMENT ON COLUMN public.stay_items.booking_url IS 'URL to the booking confirmation (e.g., Booking.com link)';

-- Enable Row Level Security
ALTER TABLE public.stay_items ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage stay items only for their own trips
DROP POLICY IF EXISTS "Users can manage stays of own trips" ON public.stay_items;
CREATE POLICY "Users can manage stays of own trips"
    ON public.stay_items
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
CREATE INDEX IF NOT EXISTS idx_stay_items_city ON public.stay_items(city);
CREATE INDEX IF NOT EXISTS idx_stay_items_confirmation ON public.stay_items(confirmation_number) WHERE confirmation_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_stay_items_location ON public.stay_items(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
