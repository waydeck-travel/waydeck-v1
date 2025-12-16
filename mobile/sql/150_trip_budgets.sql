-- =============================================================================
-- Waydeck SQL Migration: 150_trip_budgets.sql
-- Purpose: Create trip_budgets table for category-wise budget tracking
-- Version: 1.1
-- =============================================================================

-- Trip budgets: category-wise budget for each trip
-- Allows users to set spending limits and compare against actual expenses

CREATE TABLE IF NOT EXISTS public.trip_budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    category TEXT NOT NULL,                -- 'transport', 'stay', 'activity', 'food', 'other'
    budget_amount NUMERIC(12, 2) NOT NULL, -- Budget for this category
    currency CHAR(3) NOT NULL,             -- ISO 4217 currency code
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add comments for documentation
COMMENT ON TABLE public.trip_budgets IS 'Category-wise budget amounts per trip';
COMMENT ON COLUMN public.trip_budgets.category IS 'Budget category: transport, stay, activity, food, other';
COMMENT ON COLUMN public.trip_budgets.budget_amount IS 'Planned budget amount for this category';

-- Add unique constraint: one budget per category per trip
ALTER TABLE public.trip_budgets
DROP CONSTRAINT IF EXISTS uq_trip_budgets_trip_category;

ALTER TABLE public.trip_budgets
ADD CONSTRAINT uq_trip_budgets_trip_category UNIQUE (trip_id, category);

-- Add check constraint for valid categories
ALTER TABLE public.trip_budgets
DROP CONSTRAINT IF EXISTS chk_budget_category;

ALTER TABLE public.trip_budgets
ADD CONSTRAINT chk_budget_category
CHECK (category IN ('transport', 'stay', 'activity', 'food', 'other'));

-- Ensure budget amount is positive
ALTER TABLE public.trip_budgets
DROP CONSTRAINT IF EXISTS chk_budget_amount_positive;

ALTER TABLE public.trip_budgets
ADD CONSTRAINT chk_budget_amount_positive
CHECK (budget_amount >= 0);

-- Enable Row Level Security
ALTER TABLE public.trip_budgets ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage budgets only for their own trips
DROP POLICY IF EXISTS "Users can manage budgets of own trips" ON public.trip_budgets;
CREATE POLICY "Users can manage budgets of own trips"
    ON public.trip_budgets
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

-- Create indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_trip_budgets_trip_id ON public.trip_budgets(trip_id);

-- Add updated_at trigger
DROP TRIGGER IF EXISTS on_trip_budgets_updated ON public.trip_budgets;
CREATE TRIGGER on_trip_budgets_updated
    BEFORE UPDATE ON public.trip_budgets
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
