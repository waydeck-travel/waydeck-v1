-- =============================================================================
-- Waydeck SQL Migration: 140_trip_expenses.sql
-- Purpose: Create trip_expenses table for custom/miscellaneous expenses
-- Version: 1.1
-- Depends on: 120_payment_status_enum.sql
-- =============================================================================

-- Trip expenses: custom expenses not tied to specific trip items
-- Examples: food, souvenirs, tips, local transport, etc.

CREATE TABLE IF NOT EXISTS public.trip_expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    category TEXT NOT NULL,                -- 'transport', 'stay', 'activity', 'food', 'other'
    description TEXT NOT NULL,             -- What was the expense for
    amount NUMERIC(12, 2) NOT NULL,        -- Expense amount
    currency CHAR(3) NOT NULL,             -- ISO 4217 currency code
    payment_status payment_status DEFAULT 'paid',
    payment_method TEXT,                   -- card, cash, UPI, etc.
    expense_date DATE,                     -- Date of the expense
    notes TEXT,                            -- Additional notes
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add comments for documentation
COMMENT ON TABLE public.trip_expenses IS 'Custom/miscellaneous expenses not tied to specific trip items';
COMMENT ON COLUMN public.trip_expenses.category IS 'Expense category: transport, stay, activity, food, other';
COMMENT ON COLUMN public.trip_expenses.description IS 'Description of what the expense was for';
COMMENT ON COLUMN public.trip_expenses.expense_date IS 'Date when the expense occurred';

-- Add check constraint for valid categories
ALTER TABLE public.trip_expenses
DROP CONSTRAINT IF EXISTS chk_expense_category;

ALTER TABLE public.trip_expenses
ADD CONSTRAINT chk_expense_category
CHECK (category IN ('transport', 'stay', 'activity', 'food', 'other'));

-- Enable Row Level Security
ALTER TABLE public.trip_expenses ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage expenses only for their own trips
DROP POLICY IF EXISTS "Users can manage expenses of own trips" ON public.trip_expenses;
CREATE POLICY "Users can manage expenses of own trips"
    ON public.trip_expenses
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
CREATE INDEX IF NOT EXISTS idx_trip_expenses_trip_id ON public.trip_expenses(trip_id);
CREATE INDEX IF NOT EXISTS idx_trip_expenses_category ON public.trip_expenses(trip_id, category);
CREATE INDEX IF NOT EXISTS idx_trip_expenses_date ON public.trip_expenses(trip_id, expense_date);

-- Add updated_at trigger (reuse existing function from profiles)
DROP TRIGGER IF EXISTS on_trip_expenses_updated ON public.trip_expenses;
CREATE TRIGGER on_trip_expenses_updated
    BEFORE UPDATE ON public.trip_expenses
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
