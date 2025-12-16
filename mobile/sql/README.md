# Waydeck SQL Migrations

This folder contains SQL migrations for the Waydeck travel management app's Supabase (Postgres) backend.

## Migration Files

### v1.0 Core Schema

| File | Description |
|------|-------------|
| `001_init_extensions.sql` | Enable required PostgreSQL extensions (pgcrypto) |
| `010_enums.sql` | Create enum types: trip_item_type, transport_mode, document_type |
| `020_profiles.sql` | User profiles table with RLS |
| `030_trips.sql` | Trips table with RLS policies |
| `040_trip_items.sql` | Base trip items table with RLS |
| `050_transport_items.sql` | Transport details table with RLS |
| `060_stay_items.sql` | Stay/hotel details table with RLS |
| `070_activity_items.sql` | Activity details table with RLS |
| `080_documents.sql` | Document metadata table with RLS |
| `090_seed_example.sql` | Sample data for development (DO NOT use in production) |
| `091_vehicle_number.sql` | Add vehicle_number column to transport_items |
| `092_checklist_items.sql` | Trip checklists with category/phase enums |
| `093_travellers.sql` | Travellers and trip_travellers tables |
| `094_trip_status.sql` | Trip status enum and columns |
| `095_transport_passengers.sql` | Transport passengers junction table |
| `096_trip_shares.sql` | Trip sharing mechanism |
| `097_fix_trip_shares_recursion.sql` | Fix for trip shares RLS recursion |
| `098_traveller_avatars.sql` | Avatar support for travellers |
| `100_storage_buckets.sql` | Storage bucket policies |

### v1.1 Schema Extensions

| File | Description |
|------|-------------|
| `110_profile_extensions.sql` | Extend profiles with traveller fields + theme/settings |
| `120_payment_status_enum.sql` | Create payment_status enum for expenses |
| `130_expense_fields.sql` | Add expense columns to item tables |
| `140_trip_expenses.sql` | Custom/miscellaneous expenses per trip |
| `150_trip_budgets.sql` | Category-wise budget per trip |
| `160_global_documents.sql` | Global documents table + enum |
| `170_checklist_templates.sql` | Checklist templates for reuse |
| `180_global_documents_storage.sql` | Storage bucket for global documents |


## How to Apply

### Option 1: Supabase Dashboard (Recommended for first-time setup)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Run each file **in numerical order** (001 → 010 → 020 → ... → 080)
4. Optionally run `090_seed_example.sql` for development testing

> ⚠️ **Important**: Files must be run in order due to dependencies (e.g., enums before tables, trips before trip_items).

### Option 2: Supabase CLI

If you're using the [Supabase CLI](https://supabase.com/docs/guides/cli):

```bash
# Initialize Supabase in your project (if not already done)
supabase init

# Link to your remote project
supabase link --project-ref your-project-ref

# Apply migrations
supabase db push
```

To use these files with the CLI, move them to `supabase/migrations/` with timestamps:

```bash
mkdir -p supabase/migrations
cp sql/001_init_extensions.sql supabase/migrations/20250101000001_init_extensions.sql
cp sql/010_enums.sql supabase/migrations/20250101000010_enums.sql
# ... and so on
```

### Option 3: Direct psql Connection

```bash
# Connect to your Supabase database
psql "postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres"

# Run migrations
\i sql/001_init_extensions.sql
\i sql/010_enums.sql
# ... and so on
```

## Supabase Storage Setup

After applying the SQL migrations, set up the storage bucket:

1. Go to **Storage** in Supabase Dashboard
2. Create a new bucket named `trip_documents`
3. Configure RLS policies for the bucket:

```sql
-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload own documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'trip_documents' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to view their own documents
CREATE POLICY "Users can view own documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'trip_documents' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to delete their own documents
CREATE POLICY "Users can delete own documents"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'trip_documents' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
```

## Verification

After applying all migrations, verify the setup:

```sql
-- Check RLS is enabled on all tables
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- Check all tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check enums exist
SELECT typname 
FROM pg_type 
WHERE typtype = 'e';
```

## Schema Diagram

```
auth.users
    │
    ├──< profiles (1:1, extended in v1.1)
    │
    ├──< travellers
    │       │
    │       └──< trip_travellers ──> trips
    │
    ├──< global_documents (v1.1)
    │
    ├──< checklist_templates (v1.1)
    │       │
    │       └──< checklist_template_items (v1.1)
    │
    └──< trips
           │
           ├──< trip_items
           │       │
           │       ├── transport_items (1:1, expense cols in v1.1)
           │       │       │
           │       │       └──< transport_passengers ──> travellers
           │       │
           │       ├── stay_items (1:1, expense cols in v1.1)
           │       │
           │       └── activity_items (1:1, expense cols in v1.1)
           │
           ├──< documents
           │       │
           │       └── (optional) trip_items
           │
           ├──< checklist_items
           │
           ├──< trip_expenses (v1.1)
           │
           ├──< trip_budgets (v1.1)
           │
           └──< trip_shares
```

## Notes

- All `id` columns use `gen_random_uuid()` for UUID generation
- RLS (Row Level Security) is enabled on ALL tables
- Cascading deletes are configured: deleting a trip removes all its items and documents
- The `handle_updated_at()` trigger automatically updates `updated_at` columns
- Timestamps use `TIMESTAMPTZ` (timestamp with timezone) for proper UTC storage
- v1.1 additions marked with "(v1.1)"

