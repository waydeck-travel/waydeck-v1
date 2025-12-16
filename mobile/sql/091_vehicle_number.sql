-- Migration: Add vehicle_number column to transport_items
-- This column stores registration/license plate for Car, Bike, and Bus modes

ALTER TABLE public.transport_items 
ADD COLUMN IF NOT EXISTS vehicle_number TEXT;

COMMENT ON COLUMN public.transport_items.vehicle_number IS 'Vehicle registration/license plate number for Car, Bike, Bus modes';
