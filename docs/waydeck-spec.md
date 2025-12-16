# Waydeck – Travel Management App (Flutter + Supabase + TDesign)

## 0. Meta

- **App name:** Waydeck
- **Platforms:** iOS & Android (Flutter)
- **Backend:** Supabase (Postgres, Auth, Storage)
- **UI Library:** [TDesign Flutter](https://pub.dev/packages/tdesign_flutter)
- **Goal:** A single app to view and manage complete trip itineraries – including all transport legs, hotels, activities, tickets, and comments – without searching emails or multiple apps.

The canonical source for this spec in the repo should be:

> `waydeck-v1/docs/waydeck-spec.md`

This file is the master product & technical specification for Waydeck v1.

---

## 1. Product Overview

### 1.1 Problem

Travelers frequently have:

- Flights in email inboxes
- Hotel bookings in another app
- Activity tickets as PDFs on cloud drives
- Notes in random apps

This makes it hard to see:

- The **full, ordered itinerary**
- **Layovers** and waiting times
- **Which document** is for which segment

### 1.2 Solution

Waydeck provides:

- A **trip-centric** view: every journey is a Trip.
- A **timeline** of **Trip Items**:
  - Transport (flight, train, car, bus, bike, cruise, metro, ferry, etc.)
  - Stays (hotels / hostels / apartments)
  - Activities (tours, attractions, events)
  - Notes
- **File attachments** (PDFs / images) per trip or per item.
- **Comments** on segments (e.g. “Check-in took time”, “Take left exit at BKK”).

### 1.3 Example Use Case

Trip: **India → Vietnam & Thailand**

- User lives in Pune.
- Starts trip in **Pune**, travels to **Mumbai** (cab / own car / bus / train / flight).
- Flight: **Mumbai → Bangkok (BKK)**.
- Flight: **Bangkok → Da Nang (DAD)**.
- In Da Nang:
  - Transport to hotel (cab / bus / metro / train).
  - Hotel (check-in/out, breakfast info).
  - City activities with tickets.
- Then **Da Nang → Hanoi**, with hotels & activities.
- Then **Hanoi → Phu Quoc**, then **Phu Quoc → Bangkok → Phuket → Mumbai → Pune**.

User wants one app to show:

- For each leg:
  - Mode (flight/train/etc.), times, origin/destination (with airport codes), **passenger count**, layover time.
  - Ticket files (PDF/e-ticket screenshot).
- For each hotel:
  - Name, location, check-in/out, breakfast flag, comments.
- For each city:
  - Activities, tickets, notes.

---

## 2. Functional Requirements (MVP)

### 2.1 User & Auth

- Users can sign up / sign in with email + password.
- Users can reset password.
- All data is **per-user** – no shared trips in MVP.

### 2.2 Trip Management

- Create a **trip** with:
  - Name
  - Origin city/country (e.g. Pune, India)
  - Start/end dates (optional; can be inferred from items)
  - Notes (optional)
- View a list of trips (most recent first).
- Edit trip name, notes, and dates.
- Archive/delete trip.

### 2.3 Timeline & Trip Items

Each trip has ordered **Trip Items**. Each item has:

- A base row in `trip_items`:
  - `type`: `transport` | `stay` | `activity` | `note`
  - `start_time_utc` / `end_time_utc`
  - `local_tz` (e.g., `Asia/Kolkata`, `Asia/Bangkok`)
  - `title` (short label)
  - `description` (optional long notes)
  - `day_index` (computed, but stored for quick grouping)
  - `sort_index` for ordering within the day

App shows a **timeline**:

- Group items by date (according to local time).
- For each item, show:
  - Icon by type.
  - Title & location.
  - Local time range (e.g. “08:30 → 11:15 (local)”).
  - Badges: transport mode, “Ticket attached”, “Breakfast included”.

### 2.4 Transport Items

Transport item includes:

- Mode: `flight`, `train`, `bus`, `car`, `bike`, `cruise`, `metro`, `ferry`, `other`.
- Carrier name/code (e.g., “IndiGo”, “6E”).
- Transport number (e.g., flight number).
- Booking reference / PNR.
- Origin:
  - City name
  - Country code (2 letters)
  - Airport/station code (IATA for airports, optional for others)
- Destination:
  - City name
  - Country code
  - Airport/station code
- Departure:
  - Local datetime
  - Terminal (optional)
- Arrival:
  - Local datetime
  - Terminal (optional)
- Passenger count.
- Optional free-form passenger details (names, etc.).
- Price (optional).
- Comments (optional).

**Layovers:**  
The app computes layover/wait time **between consecutive transport items** where:

- Destination city of item A == origin city of item B,
- And start/stop times are contiguous (arrival before next departure).

It shows “Layover: Xh Ym” on the timeline.

### 2.5 Stay Items (Hotels etc.)

Stay item includes:

- Hotel/accommodation name.
- Address.
- City, country.
- Check-in datetime.
- Check-out datetime.
- `has_breakfast` (boolean).
- Confirmation number (optional).
- URL (booking site, e.g., Booking.com link).
- Comments/notes.

Waydeck should display:

- A card in the timeline between transport items.
- Hotel details with an embedded map later (out of scope for MVP, but structure for lat/lng is included).

### 2.6 Activity Items

Activity item includes:

- Name (e.g., “Ba Na Hills Day Tour”).
- Category (e.g., “tour”, “museum”, “food”, “nightlife”).
- Location: city/country, address.
- Start/end datetime.
- Ticket/booking code (optional).
- Comments (e.g., “Arrive 30 mins early”).

### 2.7 Note Items

Note item includes:

- Title
- Free-form text (e.g., “Remember to buy SIM at BKK airport”).
- Optional link to map/location.

### 2.8 Documents (Tickets/Vouchers)

- User can **attach documents** (PDF or images) to:
  - A **Trip** (e.g., visa, passport copy).
  - A **Trip Item** (e.g., specific flight ticket).
- Documents stored in **Supabase Storage** in a bucket named `trip_documents` (configurable).
- Metadata stored in `documents` table:
  - File name.
  - MIME type.
  - Storage path.
  - Document type: `ticket`, `hotel_voucher`, `activity_voucher`, `visa`, `other`.
- App allows viewing the document with platform viewer or webview.

### 2.9 Comments

- Each Trip and Trip Item can have a **comment text** (single field).
- Future: separate comment thread; MVP: just text fields.

---

## 3. Non-Functional Requirements

- **Offline-friendly** basic:
  - Cache last loaded trip data locally (e.g., using `hive` or `shared_preferences`).
  - Read cached data when offline.
  - Changes while offline can be a later phase.
- **Performance:** trip list and timeline should remain smooth up to at least 300 trip items.
- **Security:**
  - Use Supabase RLS to ensure users access only their own rows.
  - Never hard-code DB passwords / service keys in the app.
- **Config:**
  - Use `.env` / build-time secrets for Supabase URL and anon key.

---

## 4. Architecture & Tech Stack

### 4.1 Flutter

- Create a Flutter app (latest stable).
- Use:
  - `supabase_flutter` for Supabase integration.
  - `flutter_riverpod` (or `riverpod`) for state management.
  - `go_router` for navigation.
  - `freezed` + `json_serializable` for data models.
  - `intl` for date formatting.
  - `file_picker` or `image_picker` for document uploads.
  - `cached_network_image` for any remote images.

### 4.2 UI: TDesign Flutter & Waydeck Design System

Waydeck uses **TDesign Flutter** as the primary component library.

- Wrap the app in `TDTheme` and use TDesign widgets (`TDButton`, `TDCard`, `TDInput`, `TDCell`, dialogs, etc.) wherever possible.
- Lightly customize the TDesign theme (colors, radii, typography) to create a **Waydeck design system** with these characteristics:
  - Neutral, slightly warm base background.
  - Clear primary accent color (e.g., teal/blue) for main actions.
  - Rounded cards (12–16 px), subtle shadows, thin borders.
  - Chips/badges for modes (“Flight”, “Train”, etc.) and states (“Ticket attached”, “Breakfast included”).
  - Plenty of whitespace and clear hierarchy.
- For things TDesign doesn’t provide (e.g., the actual vertical timeline rail), implement lightweight custom widgets but still compose with TDesign components where possible.

Suggested folder structure:

```text
lib/
  app/
    app.dart
    router.dart
    theme.dart
  core/
    env/
    supabase_client.dart
  features/
    auth/
    trips/
    trip_items/
    documents/
  shared/
    ui/      # Waydeck-specific wrapper widgets around TDesign
    models/  # freezed data models
    utils/
```

### 4.3 Supabase

- Use the existing Supabase project.
- Use:
  - Postgres DB
  - Supabase Auth
  - Supabase Storage

- DB access is **from app via `supabase_flutter`** using the **anon key**.
- RLS must be enabled and configured for all app tables.

**Important:**  
Do **not** use the Postgres password or service role key in the Flutter app. Those are only for server-side or the Supabase dashboard.

---

## 5. Database Schema (Postgres / Supabase)

> All tables in `public` schema.  
> Use `gen_random_uuid()` as default for UUID PKs.  
> Enable RLS on all tables that contain user data.

Before creating tables, ensure `pgcrypto` (or equivalent) is enabled for `gen_random_uuid()` (if not already):

```sql
create extension if not exists "pgcrypto";
```

### 5.1 `profiles` (optional but recommended)

Supabase automatically creates `auth.users`. Use `profiles` for app-level user data.

```sql
create table public.profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade unique,
  full_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can manage their profile"
  on public.profiles
  for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
```

### 5.2 `trips`

```sql
create table public.trips (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  origin_city text,
  origin_country_code char(2),
  start_date date,
  end_date date,
  currency char(3),
  notes text,
  archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.trips enable row level security;

create policy "Users can select own trips"
  on public.trips
  for select
  using (owner_id = auth.uid());

create policy "Users can insert own trips"
  on public.trips
  for insert
  with check (owner_id = auth.uid());

create policy "Users can update own trips"
  on public.trips
  for update
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy "Users can delete own trips"
  on public.trips
  for delete
  using (owner_id = auth.uid());
```

### 5.3 `trip_items` (base table)

```sql
create type trip_item_type as enum ('transport', 'stay', 'activity', 'note');

create table public.trip_items (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  type trip_item_type not null,
  title text not null,
  description text,
  start_time_utc timestamptz,  -- nullable for pure notes
  end_time_utc timestamptz,
  local_tz text,
  day_index int,               -- computed by backend/app, stored for quick queries
  sort_index int not null default 0,
  comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.trip_items enable row level security;

create policy "Users can manage items of own trips"
  on public.trip_items
  for all
  using (
    trip_id in (
      select id from public.trips where owner_id = auth.uid()
    )
  )
  with check (
    trip_id in (
      select id from public.trips where owner_id = auth.uid()
    )
  );
```

### 5.4 `transport_items`

Additional details for transport-type trip items.

```sql
create type transport_mode as enum (
  'flight', 'train', 'bus', 'car', 'bike', 'cruise', 'metro', 'ferry', 'other'
);

create table public.transport_items (
  trip_item_id uuid primary key references public.trip_items(id) on delete cascade,
  mode transport_mode not null,
  carrier_name text,
  carrier_code text,
  transport_number text,              -- flight number, train number, etc.
  booking_reference text,             -- PNR / booking code

  origin_city text,
  origin_country_code char(2),
  origin_airport_code text,
  origin_terminal text,

  destination_city text,
  destination_country_code char(2),
  destination_airport_code text,
  destination_terminal text,

  departure_local timestamptz,
  arrival_local timestamptz,

  passenger_count int,
  passenger_details jsonb,            -- optional list of passenger objects
  price numeric(12,2),
  currency char(3),

  extra jsonb
);

alter table public.transport_items enable row level security;

create policy "Users can manage transport of own trips"
  on public.transport_items
  for all
  using (
    trip_item_id in (
      select ti.id
      from public.trip_items ti
      join public.trips t on t.id = ti.trip_id
      where t.owner_id = auth.uid()
    )
  )
  with check (
    trip_item_id in (
      select ti.id
      from public.trip_items ti
      join public.trips t on t.id = ti.trip_id
      where t.owner_id = auth.uid()
    )
  );
```

### 5.5 `stay_items`

```sql
create table public.stay_items (
  trip_item_id uuid primary key references public.trip_items(id) on delete cascade,
  accommodation_name text not null,
  address text,
  city text,
  country_code char(2),
  checkin_local timestamptz,
  checkout_local timestamptz,
  has_breakfast boolean not null default false,
  confirmation_number text,
  booking_url text,
  latitude double precision,
  longitude double precision,
  extra jsonb
);

alter table public.stay_items enable row level security;

create policy "Users can manage stays of own trips"
  on public.stay_items
  for all
  using (
    trip_item_id in (
      select ti.id
      from public.trip_items ti
      join public.trips t on t.id = ti.trip_id
      where t.owner_id = auth.uid()
    )
  )
  with check (
    trip_item_id in (
      select ti.id
      from public.trip_items ti
      join public.trips t on t.id = ti.trip_id
      where t.owner_id = auth.uid()
    )
  );
```

### 5.6 `activity_items`

```sql
create table public.activity_items (
  trip_item_id uuid primary key references public.trip_items(id) on delete cascade,
  category text,
  location_name text,
  address text,
  city text,
  country_code char(2),
  start_local timestamptz,
  end_local timestamptz,
  booking_code text,
  booking_url text,
  latitude double precision,
  longitude double precision,
  extra jsonb
);

alter table public.activity_items enable row level security;

create policy "Users can manage activities of own trips"
  on public.activity_items
  for all
  using (
    trip_item_id in (
      select ti.id
      from public.trip_items ti
      join public.trips t on t.id = ti.trip_id
      where t.owner_id = auth.uid()
    )
  )
  with check (
    trip_item_id in (
      select ti.id
      from public.trip_items ti
      join public.trips t on t.id = ti.trip_id
      where t.owner_id = auth.uid()
    )
  );
```

### 5.7 `documents`

```sql
create type document_type as enum (
  'ticket',
  'hotel_voucher',
  'activity_voucher',
  'visa',
  'other'
);

create table public.documents (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  trip_id uuid references public.trips(id) on delete cascade,
  trip_item_id uuid references public.trip_items(id) on delete cascade,
  doc_type document_type not null default 'other',
  file_name text not null,
  mime_type text,
  storage_path text not null,   -- path in Supabase Storage
  size_bytes bigint,
  created_at timestamptz not null default now()
);

alter table public.documents enable row level security;

create policy "Users can manage own documents"
  on public.documents
  for all
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());
```

---

## 6. App Screens & UX

### 6.1 Auth Flow

- **Splash screen**
  - Checks Supabase session.
- **Sign In screen**
  - Email + password fields.
  - “Forgot password?” link.
- **Sign Up screen**
  - Email + password + confirm.
- After login: navigate to **Trip List**.

### 6.2 Trip List Screen

- Shows list of trips as cards (using TDesign list/cell/card components):
  - Trip name.
  - Origin city/country.
  - Start → end dates (if present).
  - Count of items (transport, stays).
- Actions:
  - Add new trip (FAB or primary button).
  - Tap card → open Trip Overview.
  - Long press or overflow menu → Edit / Archive / Delete.

### 6.3 Trip Overview & Timeline

- At top: Trip summary card:
  - Trip name.
  - Origin.
  - Date range.
  - Icons showing counts: e.g. ✈ flights, 🏨 stays, 🎟 activities.
- Below: **Timeline** (scrollable vertically):
  - Grouped by day: “Mon, 1 Dec 2025”.
  - Each `trip_item` card:
    - Left: icon by type (transport, stay, activity, note).
    - Main: title (e.g., “Flight BOM → BKK”).
    - Subtitle:
      - For transport: “08:30 – 11:15 (local) • 3 passengers”.
      - For stay: “Check-in 14:00, Check-out 11:00”.
      - For activity: “09:00 – 14:00 • City centre”.
    - Badges:
      - Mode ("Flight", "Train", etc.).
      - “Ticket attached” if any document of type `ticket`.
      - “Breakfast included” for stays if `has_breakfast = true`.
- Between compatible transport segments, show a **Layover chip**:
  - e.g., “Layover: 2h 35m at BKK”.

### 6.4 Trip Item Detail Screens

- **Transport detail**
  - All data fields from `transport_items`.
  - Show origin/destination with airport codes and icons.
  - Show local times and optionally UTC time in smaller text.
  - Show passenger count, PNR, comments.
  - List of attached documents (tap to open).

- **Stay detail**
  - Hotel name, address, city, country.
  - Check-in/out times, `has_breakfast`.
  - Confirmation number, booking URL.
  - Comments.
  - Documents (vouchers).

- **Activity detail**
  - Name, category, location, time range.
  - Booking code, URL.
  - Comments.
  - Documents (tickets).

- **Note detail**
  - Title, full text.

### 6.5 Create / Edit Flows

Each type has a dedicated form (use TDesign form/field components):

- **Create Trip**
  - Name (required).
  - Origin city/country (optional).
  - Start/end dates (optional).
  - Notes (optional).

- **Add Transport**
  - Mode (selector with icons/chips).
  - Carrier, transport number, PNR.
  - Origin / destination city & codes.
  - Departure/arrival local date & time.
  - Passenger count.
  - Comment.
  - Option to attach ticket immediately.

- **Add Stay**
  - Hotel name, address, city/country.
  - Check-in/out local date & time.
  - Has breakfast (toggle).
  - Confirmation number, booking URL.
  - Comment.
  - Option to attach voucher.

- **Add Activity**
  - Name, category.
  - Location (city, address).
  - Start/end local date & time.
  - Booking code, URL.
  - Comment.
  - Option to attach voucher.

- **Add Note**
  - Title, text.

---

## 7. Data & Time Handling

- Store all primary times in **UTC** (`timestamptz`) in `trip_items`.
- For each item, also store:
  - Local dates/times in the detail tables (`departure_local`, `checkin_local`, etc.).
  - `local_tz` in `trip_items`.
- The app uses:
  - `start_time_utc` / `end_time_utc` for sorting and cross-timezone reasoning.
  - Local fields for display.

---

## 8. Supabase Storage Design

- Bucket: `trip_documents`.
- Object path pattern:  
  `trip_documents/{user_id}/{trip_id}/{trip_item_id_or_root}/{uuid_filename.ext}`

Metadata in DB:

- `storage_path` stores full path inside the bucket.
- When deleting a document row, the app also calls Supabase Storage to delete the file.

---

## 9. Implementation Phases (Waydeck v1)

### Phase 1 – Foundation

- Set up Flutter project `waydeck-v1`.
- Integrate `supabase_flutter` and connect to Supabase using URL + anon key from env.
- Implement auth (sign-up/in/sign-out).
- Implement `profiles` table and basic profile fetching.

### Phase 2 – Backend Schema & RLS

- Create SQL migrations for:
  - `trips`
  - `trip_items`
  - `transport_items`
  - `stay_items`
  - `activity_items`
  - `documents`
- Apply RLS policies as defined above.
- Seed with minimal sample data (for dev only).

### Phase 3 – Core App Screens

- Trip List:
  - Fetch trips for current user.
  - Basic CRUD (create, update, delete/archival).
- Trip Overview & Timeline:
  - Query `trip_items` joined with type-specific tables.
  - Group by date, sort by `day_index`, `sort_index`, `start_time_utc`.
  - Layover calculation on the client side.

### Phase 4 – Detail Screens & Forms

- Implement detail pages for each type.
- Implement Create/Edit forms for each type.
- Implement comments fields.

### Phase 5 – Documents

- Set up Supabase Storage bucket.
- Implement document upload:
  - Pick file/image.
  - Upload to Storage.
  - Create row in `documents` table.
- Implement viewing documents.

### Phase 6 – Polish & UX

- Apply TDesign theming & design polish for a cohesive Waydeck look.
- Add icons for modes, chips, badges.
- Improve error handling and loading states.
- Add simple offline cache for last active trip.

---

## 10. Summary

- This file (`waydeck-v1/docs/waydeck-spec.md`) is the **single source of truth** for v1 of Waydeck.
- Tech stack: Flutter + Supabase + TDesign Flutter.
- Core concepts: Trips, Trip Items (transport/stay/activity/note), Documents, Comments.
- Primary value: a clean, unified itinerary view with tickets and notes in one place.
