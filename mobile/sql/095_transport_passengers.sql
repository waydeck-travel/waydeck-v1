-- Migration: Create transport_passengers junction table
-- Links travellers to transport items as passengers

-- Create transport_passengers table
CREATE TABLE public.transport_passengers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transport_item_id UUID NOT NULL REFERENCES public.transport_items(trip_item_id) ON DELETE CASCADE,
  traveller_id UUID NOT NULL REFERENCES public.travellers(id) ON DELETE CASCADE,
  seat_number TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(transport_item_id, traveller_id)
);

-- Enable RLS
ALTER TABLE public.transport_passengers ENABLE ROW LEVEL SECURITY;

-- Policy: Users can manage passengers for transport items on their trips
CREATE POLICY "Users can manage transport passengers"
  ON public.transport_passengers
  FOR ALL
  USING (
    transport_item_id IN (
      SELECT ti.trip_item_id FROM public.transport_items ti
      JOIN public.trip_items item ON ti.trip_item_id = item.id
      JOIN public.trips t ON item.trip_id = t.id
      WHERE t.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    transport_item_id IN (
      SELECT ti.trip_item_id FROM public.transport_items ti
      JOIN public.trip_items item ON ti.trip_item_id = item.id
      JOIN public.trips t ON item.trip_id = t.id
      WHERE t.owner_id = auth.uid()
    )
  );

-- Create indexes
CREATE INDEX idx_transport_passengers_transport ON public.transport_passengers(transport_item_id);
CREATE INDEX idx_transport_passengers_traveller ON public.transport_passengers(traveller_id);

