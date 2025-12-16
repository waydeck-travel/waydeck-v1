-- =============================================================================
-- Waydeck SQL Migration: 010_enums.sql
-- Purpose: Create enum types for trip items, transport modes, and document types
-- =============================================================================

-- Trip item types: the kind of item in a trip timeline
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'trip_item_type') THEN
        CREATE TYPE trip_item_type AS ENUM ('transport', 'stay', 'activity', 'note');
    END IF;
END
$$;

-- Transport modes: different ways to travel
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'transport_mode') THEN
        CREATE TYPE transport_mode AS ENUM (
            'flight',
            'train',
            'bus',
            'car',
            'bike',
            'cruise',
            'metro',
            'ferry',
            'other'
        );
    END IF;
END
$$;

-- Document types: categorization of attached files
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'document_type') THEN
        CREATE TYPE document_type AS ENUM (
            'ticket',
            'hotel_voucher',
            'activity_voucher',
            'visa',
            'other'
        );
    END IF;
END
$$;
