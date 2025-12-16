-- Travellers table - stores saved traveller profiles
-- Run in Supabase SQL Editor

DROP TABLE IF EXISTS public.travellers CASCADE;

CREATE TABLE public.travellers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    date_of_birth DATE,
    nationality TEXT,
    passport_number TEXT,
    passport_expiry DATE,
    passport_country TEXT,
    avatar_url TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for faster queries
CREATE INDEX idx_travellers_owner_id ON public.travellers(owner_id);

-- Disable RLS for now (can enable with proper policy later)
ALTER TABLE public.travellers DISABLE ROW LEVEL SECURITY;
