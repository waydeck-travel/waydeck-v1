-- =============================================================================
-- Waydeck SQL Migration: 130_expense_fields.sql
-- Purpose: Add expense tracking columns to transport, stay, and activity items
-- Version: 1.1
-- Depends on: 120_payment_status_enum.sql
-- =============================================================================

-- =============================================================================
-- Add expense columns to transport_items
-- =============================================================================
-- Note: transport_items already has price/currency for listing price.
-- expense_* columns track actual payment which may differ (discounts, upgrades, etc.)

ALTER TABLE public.transport_items
ADD COLUMN IF NOT EXISTS expense_amount NUMERIC(12, 2);

ALTER TABLE public.transport_items
ADD COLUMN IF NOT EXISTS expense_currency CHAR(3);

ALTER TABLE public.transport_items
ADD COLUMN IF NOT EXISTS payment_status payment_status DEFAULT 'not_paid';

ALTER TABLE public.transport_items
ADD COLUMN IF NOT EXISTS payment_method TEXT;

ALTER TABLE public.transport_items
ADD COLUMN IF NOT EXISTS expense_notes TEXT;

COMMENT ON COLUMN public.transport_items.expense_amount IS 'Actual amount paid for this transport';
COMMENT ON COLUMN public.transport_items.expense_currency IS 'ISO 4217 currency code for expense';
COMMENT ON COLUMN public.transport_items.payment_status IS 'Payment state: not_paid, paid, partial';
COMMENT ON COLUMN public.transport_items.payment_method IS 'Payment method: card, cash, UPI, etc.';
COMMENT ON COLUMN public.transport_items.expense_notes IS 'Free-form notes about the expense';

-- =============================================================================
-- Add expense columns to stay_items
-- =============================================================================

ALTER TABLE public.stay_items
ADD COLUMN IF NOT EXISTS expense_amount NUMERIC(12, 2);

ALTER TABLE public.stay_items
ADD COLUMN IF NOT EXISTS expense_currency CHAR(3);

ALTER TABLE public.stay_items
ADD COLUMN IF NOT EXISTS payment_status payment_status DEFAULT 'not_paid';

ALTER TABLE public.stay_items
ADD COLUMN IF NOT EXISTS payment_method TEXT;

ALTER TABLE public.stay_items
ADD COLUMN IF NOT EXISTS expense_notes TEXT;

COMMENT ON COLUMN public.stay_items.expense_amount IS 'Actual amount paid for this stay';
COMMENT ON COLUMN public.stay_items.expense_currency IS 'ISO 4217 currency code for expense';
COMMENT ON COLUMN public.stay_items.payment_status IS 'Payment state: not_paid, paid, partial';
COMMENT ON COLUMN public.stay_items.payment_method IS 'Payment method: card, cash, UPI, etc.';
COMMENT ON COLUMN public.stay_items.expense_notes IS 'Free-form notes about the expense';

-- =============================================================================
-- Add expense columns to activity_items
-- =============================================================================

ALTER TABLE public.activity_items
ADD COLUMN IF NOT EXISTS expense_amount NUMERIC(12, 2);

ALTER TABLE public.activity_items
ADD COLUMN IF NOT EXISTS expense_currency CHAR(3);

ALTER TABLE public.activity_items
ADD COLUMN IF NOT EXISTS payment_status payment_status DEFAULT 'not_paid';

ALTER TABLE public.activity_items
ADD COLUMN IF NOT EXISTS payment_method TEXT;

ALTER TABLE public.activity_items
ADD COLUMN IF NOT EXISTS expense_notes TEXT;

COMMENT ON COLUMN public.activity_items.expense_amount IS 'Actual amount paid for this activity';
COMMENT ON COLUMN public.activity_items.expense_currency IS 'ISO 4217 currency code for expense';
COMMENT ON COLUMN public.activity_items.payment_status IS 'Payment state: not_paid, paid, partial';
COMMENT ON COLUMN public.activity_items.payment_method IS 'Payment method: card, cash, UPI, etc.';
COMMENT ON COLUMN public.activity_items.expense_notes IS 'Free-form notes about the expense';

-- =============================================================================
-- Create indexes for expense queries
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_transport_items_payment_status 
ON public.transport_items(payment_status) 
WHERE payment_status IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_stay_items_payment_status 
ON public.stay_items(payment_status) 
WHERE payment_status IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_activity_items_payment_status 
ON public.activity_items(payment_status) 
WHERE payment_status IS NOT NULL;
