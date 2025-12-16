-- Migration: Create checklist_items table for trip checklists
-- Categories: packing, shopping, documents, food, health, bookings, transport, custom
-- Phases: before_trip, during_trip, after_trip

-- Create enums
CREATE TYPE checklist_category AS ENUM (
  'packing', 'shopping', 'documents', 'food', 
  'health', 'bookings', 'transport', 'custom'
);

CREATE TYPE checklist_phase AS ENUM ('before_trip', 'during_trip', 'after_trip');

-- Create checklist_items table
CREATE TABLE public.checklist_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  category checklist_category NOT NULL DEFAULT 'custom',
  phase checklist_phase NOT NULL DEFAULT 'before_trip',
  is_checked BOOLEAN DEFAULT false,
  due_date DATE,
  notes TEXT,
  sort_index INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.checklist_items ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage checklist items for their own trips
CREATE POLICY "Users can manage checklist items of own trips"
  ON public.checklist_items
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

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_checklist_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_checklist_updated_at
  BEFORE UPDATE ON public.checklist_items
  FOR EACH ROW
  EXECUTE FUNCTION update_checklist_updated_at();

-- Create index for fast queries
CREATE INDEX idx_checklist_items_trip_id ON public.checklist_items(trip_id);
CREATE INDEX idx_checklist_items_phase ON public.checklist_items(phase);
