-- FIX: Remove infinite recursion in trips RLS policy
-- The policy "Users can view shared trips" causes circular dependency

-- Drop the problematic policy that was added in 096_trip_shares.sql
DROP POLICY IF EXISTS "Users can view shared trips" ON public.trips;

-- Update trip_shares policy to use shared_by directly (avoids trips subquery)
DROP POLICY IF EXISTS "Trip owners can manage shares" ON public.trip_shares;

CREATE POLICY "Trip owners can manage shares"
  ON public.trip_shares
  FOR ALL
  USING (
    shared_by = auth.uid()
    OR shared_with_user_id = auth.uid()
  )
  WITH CHECK (
    shared_by = auth.uid()
  );

-- Create a SECURITY DEFINER function to check if user has access to trip
-- This bypasses RLS and prevents recursion
CREATE OR REPLACE FUNCTION public.user_can_access_trip(trip_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM trips WHERE id = trip_uuid AND owner_id = auth.uid()
  )
  OR EXISTS (
    SELECT 1 FROM trip_shares 
    WHERE trip_id = trip_uuid 
    AND shared_with_user_id = auth.uid() 
    AND is_active = true
  );
$$;

-- Note: The existing trips policy should work fine on its own
-- The share access check can be done at app level when claiming a share
