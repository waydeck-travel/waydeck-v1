-- Migration: Add status column to trips table
-- Status: planned (default), active, completed

-- Create trip_status enum
CREATE TYPE trip_status AS ENUM ('planned', 'active', 'completed');

-- Add status column to trips
ALTER TABLE public.trips
ADD COLUMN status trip_status NOT NULL DEFAULT 'planned';

-- Add started_at and completed_at timestamps
ALTER TABLE public.trips
ADD COLUMN started_at TIMESTAMPTZ,
ADD COLUMN completed_at TIMESTAMPTZ;

-- Create index for status queries
CREATE INDEX idx_trips_status ON public.trips(status);

-- Optional: Add is_completed to trip_items for tracking individual items
ALTER TABLE public.trip_items
ADD COLUMN is_completed BOOLEAN DEFAULT false;
