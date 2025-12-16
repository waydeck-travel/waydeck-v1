-- Checklist items table for trip packing/task list
-- RLS: Users can only access checklist items in trips they own

CREATE TABLE IF NOT EXISTS public.checklist_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    is_checked BOOLEAN NOT NULL DEFAULT FALSE,
    group_name TEXT DEFAULT 'General',
    sort_index INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for faster trip-based queries
CREATE INDEX IF NOT EXISTS idx_checklist_items_trip_id ON public.checklist_items(trip_id);

-- Enable RLS
ALTER TABLE public.checklist_items ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access checklist items in their own trips
CREATE POLICY "Users can manage checklist items in own trips"
    ON public.checklist_items
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.trips
            WHERE trips.id = checklist_items.trip_id
            AND trips.owner_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.trips
            WHERE trips.id = checklist_items.trip_id
            AND trips.owner_id = auth.uid()
        )
    );

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_checklist_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_checklist_items_updated_at
    BEFORE UPDATE ON public.checklist_items
    FOR EACH ROW
    EXECUTE FUNCTION update_checklist_items_updated_at();
