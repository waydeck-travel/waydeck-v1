-- =============================================================================
-- Waydeck SQL Migration: 120_payment_status_enum.sql
-- Purpose: Create payment_status enum for expense tracking
-- Version: 1.1
-- =============================================================================

-- Payment status enum for tracking expense payment state
-- Used by: transport_items, stay_items, activity_items, trip_expenses

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
        CREATE TYPE payment_status AS ENUM ('not_paid', 'paid', 'partial');
    END IF;
END
$$;

COMMENT ON TYPE payment_status IS 'Payment state for expenses: not_paid, paid, or partial';
