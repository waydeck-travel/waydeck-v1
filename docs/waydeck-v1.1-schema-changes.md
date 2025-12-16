# Waydeck v1.1 – Schema Changes

> **Version:** 1.1  
> **Last Updated:** 2025-12-09  
> **Migrations:** 110-180

---

## Summary

This document summarizes all database schema changes introduced in Waydeck v1.1.

### New Enums

| Enum | Values | Purpose |
|------|--------|---------|
| `payment_status` | `not_paid`, `paid`, `partial` | Tracks expense payment state |
| `global_doc_type` | `passport`, `visa`, `travel_insurance`, `health_card`, `id_card`, `vaccination_certificate`, `other` | Types of global travel documents |

### New Tables

| Table | Purpose | RLS |
|-------|---------|-----|
| `trip_expenses` | Custom/miscellaneous expenses per trip | Trip owner only |
| `trip_budgets` | Category-wise budget amounts per trip | Trip owner only |
| `global_documents` | User-level travel documents (passport, visa, etc.) | Document owner only |
| `checklist_templates` | User-defined reusable checklist templates | Template owner only |
| `checklist_template_items` | Items within checklist templates | Template owner only |

### Extended Tables

| Table | New Columns | Purpose |
|-------|-------------|---------|
| `profiles` | `email`, `phone`, `date_of_birth`, `nationality`, `passport_number`, `passport_expiry`, `theme_preference`, `default_currency`, `notification_enabled` | User as traveller + settings |
| `transport_items` | `expense_amount`, `expense_currency`, `payment_status`, `payment_method`, `expense_notes` | Expense tracking |
| `stay_items` | `expense_amount`, `expense_currency`, `payment_status`, `payment_method`, `expense_notes` | Expense tracking |
| `activity_items` | `expense_amount`, `expense_currency`, `payment_status`, `payment_method`, `expense_notes` | Expense tracking |

### New Storage Bucket

| Bucket | Public | Purpose |
|--------|--------|---------|
| `global_documents` | No | Stores global travel documents |

---

## Detailed Changes

### 1. Profiles Extension (110)

```sql
ALTER TABLE public.profiles
ADD COLUMN email TEXT,
ADD COLUMN phone TEXT,
ADD COLUMN date_of_birth DATE,
ADD COLUMN nationality CHAR(2),
ADD COLUMN passport_number TEXT,
ADD COLUMN passport_expiry DATE,
ADD COLUMN theme_preference TEXT DEFAULT 'auto',
ADD COLUMN default_currency CHAR(3),
ADD COLUMN notification_enabled BOOLEAN DEFAULT true;
```

**Purpose:** Allows users to be treated as "self" in passenger pickers by mirroring the `travellers` table structure. Also stores user preferences for theme and notifications.

---

### 2. Payment Status Enum (120)

```sql
CREATE TYPE payment_status AS ENUM ('not_paid', 'paid', 'partial');
```

**Usage:** Used by `transport_items`, `stay_items`, `activity_items`, and `trip_expenses` tables.

---

### 3. Expense Fields on Items (130)

Added to `transport_items`, `stay_items`, and `activity_items`:

| Column | Type | Default | Description |
|--------|------|---------|-------------|
| `expense_amount` | NUMERIC(12,2) | NULL | Actual amount paid |
| `expense_currency` | CHAR(3) | NULL | ISO 4217 currency code |
| `payment_status` | payment_status | 'not_paid' | Payment state |
| `payment_method` | TEXT | NULL | card, cash, UPI, etc. |
| `expense_notes` | TEXT | NULL | Free-form notes |

**Note:** `transport_items` already has `price`/`currency` for listing price. The new expense columns track actual payment.

---

### 4. Trip Expenses Table (140)

```sql
CREATE TABLE public.trip_expenses (
    id UUID PRIMARY KEY,
    trip_id UUID REFERENCES trips(id),
    category TEXT NOT NULL,  -- transport, stay, activity, food, other
    description TEXT NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    payment_status payment_status DEFAULT 'paid',
    payment_method TEXT,
    expense_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);
```

**Purpose:** Stores custom/miscellaneous expenses not tied to specific trip items (e.g., food, tips, souvenirs).

---

### 5. Trip Budgets Table (150)

```sql
CREATE TABLE public.trip_budgets (
    id UUID PRIMARY KEY,
    trip_id UUID REFERENCES trips(id),
    category TEXT NOT NULL,  -- transport, stay, activity, food, other
    budget_amount NUMERIC(12,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    UNIQUE(trip_id, category)
);
```

**Purpose:** Stores category-wise budget for each trip. One budget per category per trip.

---

### 6. Global Documents (160)

```sql
CREATE TYPE global_doc_type AS ENUM (
    'passport', 'visa', 'travel_insurance', 'health_card',
    'id_card', 'vaccination_certificate', 'other'
);

CREATE TABLE public.global_documents (
    id UUID PRIMARY KEY,
    owner_id UUID REFERENCES auth.users(id),
    doc_type global_doc_type NOT NULL,
    title TEXT,
    country_code CHAR(2),  -- For visa: target country
    document_number TEXT,
    file_name TEXT NOT NULL,
    mime_type TEXT,
    storage_path TEXT NOT NULL,
    size_bytes BIGINT,
    issue_date DATE,
    expiry_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ
);
```

**Purpose:** User-level travel documents visible across all trips. Separate from `documents` table which requires `trip_id` or `trip_item_id`.

---

### 7. Checklist Templates (170)

```sql
CREATE TABLE public.checklist_templates (
    id UUID PRIMARY KEY,
    owner_id UUID REFERENCES auth.users(id),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);

CREATE TABLE public.checklist_template_items (
    id UUID PRIMARY KEY,
    template_id UUID REFERENCES checklist_templates(id),
    title TEXT NOT NULL,
    category checklist_category DEFAULT 'custom',
    phase checklist_phase DEFAULT 'before_trip',
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ
);
```

**Purpose:** User-defined reusable checklist templates. Items can be imported into trip checklists.

---

### 8. Global Documents Storage (180)

New storage bucket: `global_documents`

**Settings:**
- Public: false
- File size limit: 10MB
- Allowed MIME types: PDF, JPEG, PNG, WebP

**Path pattern:** `global_documents/{user_id}/{filename}`

---

## Migration Order

Run migrations in numerical order:

1. `110_profile_extensions.sql`
2. `120_payment_status_enum.sql`
3. `130_expense_fields.sql` (depends on 120)
4. `140_trip_expenses.sql` (depends on 120)
5. `150_trip_budgets.sql`
6. `160_global_documents.sql`
7. `170_checklist_templates.sql` (depends on 092 enums)
8. `180_global_documents_storage.sql` (depends on 160)

---

## Backwards Compatibility

All changes are **additive**:
- New columns have `NULL` or sensible defaults
- No existing columns removed or renamed
- No breaking changes to existing queries
- Existing v1 data remains fully accessible

---

## RLS Summary

All new tables have Row Level Security enabled:

| Table | Policy |
|-------|--------|
| `trip_expenses` | Users can only access expenses for trips they own |
| `trip_budgets` | Users can only access budgets for trips they own |
| `global_documents` | Users can only access their own documents |
| `checklist_templates` | Users can only access their own templates |
| `checklist_template_items` | Users can only access items in their own templates |
