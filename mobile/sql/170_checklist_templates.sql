-- =============================================================================
-- Waydeck SQL Migration: 170_checklist_templates.sql
-- Purpose: Create checklist_templates and checklist_template_items tables
-- Version: 1.1
-- Depends on: 092_checklist_items.sql (for checklist_category, checklist_phase enums)
-- =============================================================================

-- =============================================================================
-- Create checklist_templates table
-- =============================================================================

-- Checklist templates: user-defined reusable checklist templates
-- Users can create templates and import them into trips

CREATE TABLE IF NOT EXISTS public.checklist_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,                    -- Template name
    description TEXT,                      -- Optional description
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add comments for documentation
COMMENT ON TABLE public.checklist_templates IS 'User-defined reusable checklist templates';
COMMENT ON COLUMN public.checklist_templates.name IS 'Template name (e.g., "Standard Packing List")';
COMMENT ON COLUMN public.checklist_templates.description IS 'Optional description of what this template is for';

-- Enable Row Level Security
ALTER TABLE public.checklist_templates ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only manage their own templates
DROP POLICY IF EXISTS "Users can manage own templates" ON public.checklist_templates;
CREATE POLICY "Users can manage own templates"
    ON public.checklist_templates
    FOR ALL
    USING (owner_id = auth.uid())
    WITH CHECK (owner_id = auth.uid());

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_checklist_templates_owner_id ON public.checklist_templates(owner_id);

-- Add updated_at trigger
DROP TRIGGER IF EXISTS on_checklist_templates_updated ON public.checklist_templates;
CREATE TRIGGER on_checklist_templates_updated
    BEFORE UPDATE ON public.checklist_templates
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- =============================================================================
-- Create checklist_template_items table
-- =============================================================================

-- Template items: items within a checklist template
-- These are copied to trip checklists when a template is imported

CREATE TABLE IF NOT EXISTS public.checklist_template_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id UUID NOT NULL REFERENCES public.checklist_templates(id) ON DELETE CASCADE,
    title TEXT NOT NULL,                   -- Item title
    category checklist_category NOT NULL DEFAULT 'custom',  -- Reuse existing enum
    phase checklist_phase NOT NULL DEFAULT 'before_trip',   -- Reuse existing enum
    sort_order INT DEFAULT 0,              -- Sort order within the template
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add comments for documentation
COMMENT ON TABLE public.checklist_template_items IS 'Items within a checklist template';
COMMENT ON COLUMN public.checklist_template_items.title IS 'Item title (e.g., "Pack passport")';
COMMENT ON COLUMN public.checklist_template_items.category IS 'Item category from checklist_category enum';
COMMENT ON COLUMN public.checklist_template_items.phase IS 'Trip phase: before_trip, during_trip, after_trip';
COMMENT ON COLUMN public.checklist_template_items.sort_order IS 'Display order within the template';

-- Enable Row Level Security
ALTER TABLE public.checklist_template_items ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage items only for their own templates
DROP POLICY IF EXISTS "Users can manage items of own templates" ON public.checklist_template_items;
CREATE POLICY "Users can manage items of own templates"
    ON public.checklist_template_items
    FOR ALL
    USING (
        template_id IN (
            SELECT id FROM public.checklist_templates WHERE owner_id = auth.uid()
        )
    )
    WITH CHECK (
        template_id IN (
            SELECT id FROM public.checklist_templates WHERE owner_id = auth.uid()
        )
    );

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_checklist_template_items_template_id 
    ON public.checklist_template_items(template_id);
CREATE INDEX IF NOT EXISTS idx_checklist_template_items_sort 
    ON public.checklist_template_items(template_id, sort_order);
