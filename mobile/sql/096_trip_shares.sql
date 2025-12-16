-- Migration: Create trip_shares table for sharing trips with others
-- Allows trip owners to share read access with other users

-- Create trip_shares table
CREATE TABLE public.trip_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  share_code TEXT NOT NULL UNIQUE,  -- Unique shareable code
  shared_by UUID NOT NULL REFERENCES auth.users(id),
  shared_with_email TEXT,  -- Email of invitee (optional)
  shared_with_user_id UUID REFERENCES auth.users(id),  -- User ID if they've claimed the share
  permission TEXT NOT NULL DEFAULT 'view' CHECK (permission IN ('view', 'edit')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  claimed_at TIMESTAMPTZ  -- When the invitee claimed the share
);

-- Enable RLS
ALTER TABLE public.trip_shares ENABLE ROW LEVEL SECURITY;

-- Policy: Trip owners can manage their shares
CREATE POLICY "Trip owners can manage shares"
  ON public.trip_shares
  FOR ALL
  USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE owner_id = auth.uid()
    )
    OR shared_with_user_id = auth.uid()
  )
  WITH CHECK (
    trip_id IN (
      SELECT id FROM public.trips WHERE owner_id = auth.uid()
    )
  );

-- Policy: Users can view trips shared with them
CREATE POLICY "Users can view shared trips"
  ON public.trips
  FOR SELECT
  USING (
    owner_id = auth.uid()
    OR id IN (
      SELECT trip_id FROM public.trip_shares 
      WHERE shared_with_user_id = auth.uid() 
      AND is_active = true
    )
  );

-- Create indexes
CREATE INDEX idx_trip_shares_trip ON public.trip_shares(trip_id);
CREATE INDEX idx_trip_shares_code ON public.trip_shares(share_code);
CREATE INDEX idx_trip_shares_user ON public.trip_shares(shared_with_user_id);
