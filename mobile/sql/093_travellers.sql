-- Migration: Create travellers and trip_travellers tables
-- Travellers are people who travel on trips (stored per user)
-- Trip travellers links travellers to specific trips

-- Create travellers table (master list per user)
CREATE TABLE public.travellers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  passport_number TEXT,
  passport_expiry DATE,
  nationality TEXT,
  date_of_birth DATE,
  notes TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create trip_travellers junction table
CREATE TABLE public.trip_travellers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  traveller_id UUID NOT NULL REFERENCES public.travellers(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(trip_id, traveller_id)
);

-- Enable RLS on travellers
ALTER TABLE public.travellers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own travellers"
  ON public.travellers
  FOR ALL
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

-- Enable RLS on trip_travellers
ALTER TABLE public.trip_travellers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage trip travellers of own trips"
  ON public.trip_travellers
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

-- Create updated_at trigger for travellers
CREATE TRIGGER trigger_travellers_updated_at
  BEFORE UPDATE ON public.travellers
  FOR EACH ROW
  EXECUTE FUNCTION update_checklist_updated_at();

-- Create indexes
CREATE INDEX idx_travellers_owner_id ON public.travellers(owner_id);
CREATE INDEX idx_trip_travellers_trip_id ON public.trip_travellers(trip_id);
CREATE INDEX idx_trip_travellers_traveller_id ON public.trip_travellers(traveller_id);
