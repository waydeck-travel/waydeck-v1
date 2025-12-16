-- =============================================================================
-- Waydeck SQL Migration: 050_transport_items.sql
-- Purpose: Create transport_items table for transport-type trip items
-- =============================================================================

-- Transport items: additional details for transport-type trip items
-- Linked 1:1 with trip_items where type = 'transport'
CREATE TABLE IF NOT EXISTS public.transport_items (
    trip_item_id UUID PRIMARY KEY REFERENCES public.trip_items(id) ON DELETE CASCADE,
    mode transport_mode NOT NULL,
    carrier_name TEXT,                    -- e.g., "IndiGo", "Indian Railways"
    carrier_code TEXT,                    -- e.g., "6E", "IR"
    transport_number TEXT,                -- Flight number, train number, etc.
    booking_reference TEXT,               -- PNR / booking code

    -- Origin details
    origin_city TEXT,
    origin_country_code CHAR(2),
    origin_airport_code TEXT,             -- IATA code for airports (e.g., BOM, BKK)
    origin_terminal TEXT,

    -- Destination details
    destination_city TEXT,
    destination_country_code CHAR(2),
    destination_airport_code TEXT,
    destination_terminal TEXT,

    -- Times (stored with timezone for local display)
    departure_local TIMESTAMPTZ,
    arrival_local TIMESTAMPTZ,

    -- Passenger information
    passenger_count INT,
    passenger_details JSONB,              -- Optional: [{name: "John", seat: "12A"}, ...]

    -- Pricing
    price NUMERIC(12, 2),
    currency CHAR(3),

    -- Additional data
    extra JSONB                           -- For any additional unstructured data
);

-- Add comments for documentation
COMMENT ON TABLE public.transport_items IS 'Transport details for trip items of type transport';
COMMENT ON COLUMN public.transport_items.origin_airport_code IS 'IATA airport code or station code';
COMMENT ON COLUMN public.transport_items.passenger_details IS 'JSON array of passenger objects with name, seat, etc.';
COMMENT ON COLUMN public.transport_items.extra IS 'Additional unstructured data for future extensibility';

-- Enable Row Level Security
ALTER TABLE public.transport_items ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage transport items only for their own trips
DROP POLICY IF EXISTS "Users can manage transport of own trips" ON public.transport_items;
CREATE POLICY "Users can manage transport of own trips"
    ON public.transport_items
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
CREATE INDEX IF NOT EXISTS idx_transport_items_mode ON public.transport_items(mode);
CREATE INDEX IF NOT EXISTS idx_transport_items_origin ON public.transport_items(origin_city, origin_airport_code);
CREATE INDEX IF NOT EXISTS idx_transport_items_destination ON public.transport_items(destination_city, destination_airport_code);
CREATE INDEX IF NOT EXISTS idx_transport_items_booking_ref ON public.transport_items(booking_reference) WHERE booking_reference IS NOT NULL;
