# Waydeck v1.1 – Product & Spec Addendum

> **Version:** 1.1  
> **Last Updated:** 2025-12-09  
> **Status:** Draft – Pending Development  
> **Base Spec:** [waydeck-spec.md](./waydeck-spec.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Feature Groups](#2-feature-groups)
   - [2.1 Profile & Travellers](#21-profile--travellers)
   - [2.2 Theming & Dark Mode](#22-theming--dark-mode)
   - [2.3 Expenses & Budget](#23-expenses--budget)
   - [2.4 Documents (Global & Trip)](#24-documents-global--trip)
   - [2.5 Checklists (Global & Trip)](#25-checklists-global--trip)
   - [2.6 Locations & Google API Enhancements](#26-locations--google-api-enhancements)
   - [2.7 Notifications & Sharing](#27-notifications--sharing)
   - [2.8 Landing & Auth UX](#28-landing--auth-ux)
   - [2.9 UI/UX Polish & Fixes](#29-uiux-polish--fixes)
3. [Data Schema Changes](#3-data-schema-changes)
4. [Implementation Priority](#4-implementation-priority)
5. [Traceability Matrix](#5-traceability-matrix)

---

## 1. Overview

This addendum specifies enhancements for **Waydeck v1.1** building on top of the v1.0 spec. All changes are backwards-compatible with existing data unless specifically noted.

### Goals

- Enhanced user identity and traveller management
- Complete expense tracking and budgeting
- Improved document organization (global + per-trip)
- Modern UI with theme support
- Reliability fixes for existing features
- Pre-auth landing page for onboarding

---

## 2. Feature Groups

### 2.1 Profile & Travellers

> **Related Requirements:** #1, #2, #18

#### 2.1.1 Profile as Traveller (REQ #1)

**Problem:** Users cannot manage their own profile details (passport number, expiry, nationality, etc.) like they can for other travellers.

**Solution:**

- **Profile Screen Enhancement:**
  - Add a "My Details" section to the Profile screen
  - Include all fields available to travellers:
    - Full name (already exists)
    - Email (read-only, from auth)
    - Phone number
    - Date of birth
    - Nationality (country picker)
    - Passport number
    - Passport expiry date
    - Avatar photo (already exists)
  
- **UI Layout:**
  ```
  ┌────────────────────────────────────────┐
  │  ← Profile                             │
  ├────────────────────────────────────────┤
  │  ┌──────┐                              │
  │  │ 📷   │  John Doe                    │
  │  │Avatar│  john@example.com            │
  │  └──────┘                              │
  ├────────────────────────────────────────┤
  │  ─── Personal Details ───              │
  │  Phone          +91 98765 43210        │
  │  Date of Birth  15 Mar 1990            │
  │  Nationality    🇮🇳 India              │
  ├────────────────────────────────────────┤
  │  ─── Travel Documents ───              │
  │  Passport #     A1234567               │
  │  Expiry         15 Mar 2030            │
  │  ⚠️ Valid for 5 years                  │
  ├────────────────────────────────────────┤
  │  ─── Settings ───                      │
  │  My Travellers                      →  │
  │  My Documents                       →  │
  │  Theme                          Auto ▼ │
  │  Notifications                   ON    │
  ├────────────────────────────────────────┤
  │  [Sign Out]                            │
  └────────────────────────────────────────┘
  ```

**Schema Impact:**
- Extend `profiles` table with new columns (see [Section 3](#3-data-schema-changes))

---

#### 2.1.2 Add Self as Passenger (REQ #2)

**Problem:** When creating a trip, the user cannot add themselves as a passenger quickly.

**Solution:**

- In the **Passenger Picker** (used in Transport/Activity/Stay forms):
  - Add a pinned "Me" option at the top of the traveller list
  - "Me" fetches data from the user's profile
  - If profile travel details are incomplete, show a prompt to complete them

- **Passenger Picker UI:**
  ```
  ┌────────────────────────────────────────┐
  │  Select Passengers                  ✕  │
  ├────────────────────────────────────────┤
  │  [✓] 👤 Me (John Doe)                  │  ← Always first
  │      Passport: A1234567                │
  ├────────────────────────────────────────┤
  │  [ ] 👤 Jane Doe                       │
  │      Passport: B7654321                │
  │  [ ] 👤 Child 1                        │
  │      Passport: C1111111                │
  ├────────────────────────────────────────┤
  │  [+ Add New Traveller]                 │
  └────────────────────────────────────────┘
  ```

---

#### 2.1.3 Fix "Add New Traveller" from Picker (REQ #18)

**Problem:** Clicking "Add new traveller" from the passenger picker opens a loader that never completes.

**Solution:**

- When tapping "Add New Traveller" from the picker:
  1. Navigate to `/travellers/new` with a `returnTo` parameter
  2. After saving the new traveller, navigate back to the picker
  3. Auto-select the newly created traveller
  4. Refresh the traveller list in the picker

- **Navigation Flow:**
  ```
  Transport Form → Passenger Picker → [+ Add New]
                                          ↓
                              New Traveller Form
                                          ↓ (Save)
                              ← Passenger Picker (refreshed, new traveller selected)
  ```

---

### 2.2 Theming & Dark Mode

> **Related Requirements:** #3

#### 2.2.1 Theme Support

**Problem:** App currently has no dark mode support.

**Solution:**

- **Theme Options:**
  - `auto` (default) – Follow system/device theme
  - `light` – Force light mode
  - `dark` – Force dark mode

- **Settings UI:**
  - Add "Theme" dropdown in Profile/Settings screen
  - Options: "Auto (System)", "Light", "Dark"
  - Persist user preference in local storage AND sync to `profiles.theme_preference`

- **Implementation:**
  - Wrap app in `TDTheme` with dynamic theme data
  - Use `MediaQuery.platformBrightnessOf(context)` for system detection
  - Create dark variants of existing Waydeck design tokens:
    - Background: `#121212` (dark) vs `#FAFAFA` (light)
    - Surface: `#1E1E1E` (dark) vs `#FFFFFF` (light)
    - Primary accent: Keep consistent teal/blue
    - Text: Invert for contrast

- **Theme Selection UI:**
  ```
  ┌─────────────────────────────────┐
  │  Theme                          │
  │  ┌───────────────────────────┐  │
  │  │ ◉ Auto (System)          │  │
  │  │ ○ Light                  │  │
  │  │ ○ Dark                   │  │
  │  └───────────────────────────┘  │
  └─────────────────────────────────┘
  ```

**Schema Impact:**
- Add `theme_preference` column to `profiles` table

---

### 2.3 Expenses & Budget

> **Related Requirements:** #4, #5, #6

#### 2.3.1 Expense Fields on Items (REQ #4)

**Problem:** No way to track money spent on transport, hotels, or activities.

**Solution:**

- Add an **Expense Section** to all item forms (Transport, Stay, Activity):

  ```
  ─────────── Expense ───────────
  
  Amount Paid     [1500.00      ]  [INR ▼]
  Payment Status  [○ Not Paid] [◉ Paid] [○ Partial]
  Payment Method  [Card ▼]
  Notes           [Paid via HDFC card  ]
  ```

- **Fields:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `expense_amount` | `numeric(12,2)` | Amount paid |
  | `expense_currency` | `char(3)` | ISO currency code |
  | `payment_status` | `enum` | `not_paid`, `paid`, `partial` |
  | `payment_method` | `text` | Optional (card, cash, UPI, etc.) |
  | `expense_notes` | `text` | Free-form notes |

- **Display on Item Cards:**
  - Show badge: "💰 ₹1,500" if expense is set
  - Show icon: 🟢 (paid), 🟡 (partial), 🔴 (not paid)

**Schema Impact:**
- Add expense columns to `transport_items`, `stay_items`, `activity_items`
- Create `payment_status` enum

---

#### 2.3.2 Trip Expense Summary View (REQ #5)

**Problem:** No consolidated view of trip expenses.

**Solution:**

- Add an **"Expenses"** button/tab to Trip Overview:
  
  ```
  ┌────────────────────────────────────────┐
  │  ←  Trip Expenses                      │
  ├────────────────────────────────────────┤
  │  ─── Summary ───                       │
  │                                        │
  │  Total Expenses         ₹ 1,25,000     │
  │  Currency: INR (primary)               │
  │                                        │
  │  ┌────────────────────────────────┐    │
  │  │ 🛫 Transport     ₹ 45,000      │    │
  │  │ 🏨 Stays         ₹ 55,000      │    │
  │  │ 🎟 Activities    ₹ 15,000      │    │
  │  │ 📦 Other         ₹ 10,000      │    │
  │  └────────────────────────────────┘    │
  ├────────────────────────────────────────┤
  │  ─── Breakdown ───                     │
  │                                        │
  │  ✈ Flight BOM → BKK         ₹ 25,000  │
  │  ✈ Flight BKK → DAD         ₹ 12,000  │
  │  🚕 Cab to Airport           ₹ 1,500  │
  │  🏨 Grand Mercure (3 nights) ₹ 35,000  │
  │  🏨 Hanoi Hotel (2 nights)   ₹ 20,000  │
  │  ...                                   │
  ├────────────────────────────────────────┤
  │  [+ Add Custom Expense]                │
  └────────────────────────────────────────┘
  ```

- **Features:**
  - Group expenses by category (transport, stay, activity, other)
  - Show payment status indicators
  - Editable – tap any item to edit expense
  - Support for **custom/miscellaneous expenses** not tied to items
  - Optional currency conversion display (future enhancement)

**Schema Impact:**
- New table: `trip_expenses` for custom expenses

---

#### 2.3.3 Trip Budget View (REQ #6)

**Problem:** Users cannot set a budget and compare against actual spending.

**Solution:**

- Add **"Budget"** button/tab to Trip Overview (alongside Expenses):

  ```
  ┌────────────────────────────────────────┐
  │  ←  Trip Budget                   ✏️   │
  ├────────────────────────────────────────┤
  │  Total Budget          ₹ 1,50,000      │
  │  Total Spent           ₹ 1,25,000      │
  │  Remaining             ₹ 25,000  ✓     │
  ├────────────────────────────────────────┤
  │                                        │
  │  Category Budgets                      │
  │                                        │
  │  🛫 Transport                          │
  │  ▓▓▓▓▓▓▓▓░░  ₹45K / ₹50K (90%)        │
  │                                        │
  │  🏨 Stays                              │
  │  ▓▓▓▓▓▓▓▓▓▓▓ ₹55K / ₹50K (110%) ⚠️    │
  │                                        │
  │  🎟 Activities                         │
  │  ▓▓▓▓▓░░░░░  ₹15K / ₹30K (50%)        │
  │                                        │
  │  🍔 Food                               │
  │  ▓▓░░░░░░░░  ₹5K / ₹15K (33%)         │
  │                                        │
  │  📦 Other                              │
  │  ▓▓▓▓░░░░░░  ₹5K / ₹5K (100%)         │
  │                                        │
  └────────────────────────────────────────┘
  ```

- **Budget Categories:**
  - Transport
  - Stays (Accommodation)
  - Activities
  - Food & Dining
  - Other / Miscellaneous

- **Features:**
  - Set budget per category
  - Visual progress bars (green < 80%, yellow 80-100%, red > 100%)
  - Total budget rollup
  - Over-budget warnings
  - Edit budget amounts

**Schema Impact:**
- New table: `trip_budgets` with category-wise budget amounts

---

### 2.4 Documents (Global & Trip)

> **Related Requirements:** #10, #11

#### 2.4.1 Fix Document Upload in Trip (REQ #10)

**Problem:** Clicking "Upload document" in Trip Documents section, then selecting a category, does nothing.

**Solution:**

- Debug and fix the document upload flow:
  1. User taps "Upload Document"
  2. Category selection sheet appears (Ticket, Voucher, Visa, Other)
  3. After category selection, file picker should open
  4. After file selection, upload should proceed with progress indicator
  5. On success, document should appear in grid with refresh

- **Likely Issue:** Missing navigation or async await after category selection

---

#### 2.4.2 Global Documents (REQ #11)

**Problem:** Users need to store documents like passport, visa, insurance globally and reference them across trips.

**Solution:**

- **New Settings Section: "My Documents"**
  
  ```
  ┌────────────────────────────────────────┐
  │  ←  My Documents               [+ Add] │
  ├────────────────────────────────────────┤
  │  ─── Travel Documents ───              │
  │                                        │
  │  ┌──────────┐  ┌──────────┐            │
  │  │ 🛂       │  │ 🎫       │            │
  │  │ Passport │  │ Visa USA │            │
  │  │ PDF      │  │ PDF      │            │
  │  │Exp: 2030 │  │Exp: 2026 │            │
  │  └──────────┘  └──────────┘            │
  │                                        │
  │  ┌──────────┐  ┌──────────┐            │
  │  │ 🏥       │  │ [+ Add]  │            │
  │  │Insurance │  │          │            │
  │  │ PDF      │  │          │            │
  │  │Exp: 2025 │  │          │            │
  │  └──────────┘  └──────────┘            │
  └────────────────────────────────────────┘
  ```

- **Document Types for Global:**
  - `passport`
  - `visa` (with country)
  - `travel_insurance`
  - `health_card`
  - `id_card`
  - `vaccination_certificate`
  - `other`

- **Fields:**
  | Field | Type | Description |
  |-------|------|-------------|
  | `doc_type` | enum | Type of document |
  | `country_code` | char(2) | For visa – which country |
  | `expiry_date` | date | Optional expiry |
  | `file_name`, `storage_path` | text | File reference |

- **In Trip Overview – Reference Section:**
  
  ```
  ─── My Travel Documents ───
  
  📎 Passport (exp: Mar 2030)          [View]
  📎 Visa - Thailand (exp: Dec 2025)   [View]
  📎 Travel Insurance                  [View]
  
  These are your global documents. Manage them in Settings.
  ```

  - Read-only display in trip context
  - Links to document viewer
  - Shows only documents relevant to trip countries (optional enhancement)

**Schema Impact:**
- Extend `documents` table with `is_global` flag and additional type values
- Or create new table `global_documents`

---

### 2.5 Checklists (Global & Trip)

> **Related Requirements:** #21, #22

#### 2.5.1 Improved Trip Checklist UI (REQ #21)

**Problem:** Current checklist UI is basic and not user-friendly.

**Solution:**

- **Enhanced Checklist Design:**
  
  ```
  ┌────────────────────────────────────────┐
  │  ←  Trip Checklist                 ✏️  │
  ├────────────────────────────────────────┤
  │  Progress: 8/15 items  ▓▓▓▓▓░░░ 53%   │
  ├────────────────────────────────────────┤
  │  ─── Before Trip ───                   │
  │                                        │
  │  [✓] Book flights                      │
  │  [✓] Book hotels                       │
  │  [✓] Get travel insurance              │
  │  [ ] Check visa requirements           │
  │  [ ] Exchange currency                 │
  ├────────────────────────────────────────┤
  │  ─── Packing ───                       │
  │                                        │
  │  [✓] Passport                          │
  │  [✓] Phone charger                     │
  │  [✓] Medications                       │
  │  [ ] Camera                            │
  │  [ ] Sunscreen                         │
  ├────────────────────────────────────────┤
  │  ─── At Destination ───                │
  │                                        │
  │  [ ] Buy local SIM                     │
  │  [ ] Get metro card                    │
  │  [ ] Register with embassy             │
  ├────────────────────────────────────────┤
  │  [+ Add Item]   [Import from Template] │
  └────────────────────────────────────────┘
  ```

- **Features:**
  - **Grouping:** Items can be grouped (Before Trip, Packing, At Destination, Custom)
  - **Progress indicator:** Visual progress bar
  - **Quick toggle:** Tap anywhere on row to toggle
  - **Swipe actions:** Swipe to delete
  - **Reordering:** Drag to reorder within group
  - **Editing:** Inline edit or tap to edit details

**Schema Impact:**
- Add `group_name` and `sort_order` to `checklist_items`

---

#### 2.5.2 Global Checklist Template (REQ #22)

**Problem:** Users want to create reusable checklist templates.

**Solution:**

- **New Settings Section: "My Checklist Templates"**
  
  ```
  ┌────────────────────────────────────────┐
  │  ←  Checklist Templates       [+ New]  │
  ├────────────────────────────────────────┤
  │                                        │
  │  ┌──────────────────────────────────┐  │
  │  │ 📋 Standard Packing List         │  │
  │  │    12 items • 3 groups           │  │
  │  │                            ✏️ 🗑 │  │
  │  └──────────────────────────────────┘  │
  │                                        │
  │  ┌──────────────────────────────────┐  │
  │  │ 📋 Beach Vacation Extras         │  │
  │  │    8 items • 2 groups            │  │
  │  │                            ✏️ 🗑 │  │
  │  └──────────────────────────────────┘  │
  │                                        │
  │  ┌──────────────────────────────────┐  │
  │  │ 📋 Business Trip                 │  │
  │  │    6 items • 1 group             │  │
  │  │                            ✏️ 🗑 │  │
  │  └──────────────────────────────────┘  │
  │                                        │
  └────────────────────────────────────────┘
  ```

- **Template Editor:**
  - Same UI as trip checklist but for templates
  - Items are not "checked" – just a list

- **Import to Trip:**
  - From Trip Checklist, tap "Import from Template"
  - Select template(s)
  - Items are copied (duplicated) into the trip's checklist
  - Existing items are preserved

  ```
  ┌────────────────────────────────────────┐
  │  Import Checklist Template             │
  ├────────────────────────────────────────┤
  │                                        │
  │  [✓] 📋 Standard Packing List          │
  │  [ ] 📋 Beach Vacation Extras          │
  │  [ ] 📋 Business Trip                  │
  │                                        │
  │  ⚠️ Items will be added to your        │
  │     existing checklist.                │
  │                                        │
  │  [Cancel]              [Import Selected]│
  └────────────────────────────────────────┘
  ```

**Schema Impact:**
- New table: `checklist_templates` (user-level templates)
- New table: `checklist_template_items` (items in templates)

---

### 2.6 Locations & Google API Enhancements

> **Related Requirements:** #13, #14, #16, #17, #19

#### 2.6.1 Auto-populate Airport Code (REQ #13)

**Problem:** When selecting an airport from autocomplete, the airport code isn't auto-filled.

**Solution:**

- When user selects an airport from Google Places autocomplete:
  1. Parse the airport name to extract IATA code if present (e.g., "Chhatrapati Shivaji International Airport (BOM)")
  2. Or use the airport database to look up the code
  3. Auto-fill the airport code field

- **Implementation:**
  - Enhance `AirportAutocomplete` widget to return code with selection
  - Map Google Place ID or name to IATA code from `airports_database.dart`

---

#### 2.6.2 Google Places for Address Fields (REQ #14)

**Problem:** Transport location/address fields don't use autocomplete for cities, addresses, and places.

**Solution:**

- Enable Google Places autocomplete for these fields:
  | Form | Field | Place Types |
  |------|-------|-------------|
  | Transport | Origin/Destination Address | `cities`, `geocode` |
  | Transport (non-flight) | Pickup/Dropoff Location | `address`, `establishment` |
  | Stay | Hotel Name | `lodging`, `establishment` |
  | Stay | Address | `address` |
  | Activity | Venue/Location | `establishment`, `point_of_interest` |

- After selection, auto-fill:
  - City
  - Country
  - Address (if applicable)
  - Lat/Lng (if we want map integration later)

---

#### 2.6.3 Bike Drop-off Same as Pickup (REQ #16)

**Problem:** Cars have "Drop-off same as pickup" toggle, but Bikes don't.

**Solution:**

- Add the same toggle to Bike mode:
  ```
  ─────────── Destination ───────────
  
  [✓] Drop-off same as pickup
  
  (When checked, destination fields are hidden and 
   automatically set to match origin)
  ```

- Copy existing Car mode implementation to Bike mode

---

#### 2.6.4 Cities Display – Avoid Duplicates (REQ #17)

**Problem:** When an airport is selected, the city chips in Trip Overview show duplicates or full airport names.

**Solution:**

- In the Cities Summary section (Trip Overview header):
  - Extract city name only from airport selections
  - Deduplicate city names
  - Show as compact chips: "Pune", "Mumbai", "Bangkok", "Da Nang"
  - Do NOT show: "Chhatrapati Shivaji International Airport (BOM)"

- **Implementation:**
  - Parse `origin_city` and `destination_city` fields
  - Normalize and dedupe before display
  - If a city name contains "Airport" or matches known airport patterns, extract just the city portion

---

#### 2.6.5 Auto-populate City from Hotel (REQ #19)

**Problem:** When selecting a hotel, the City field doesn't auto-populate.

**Solution:**

- When user selects a hotel from Google Places:
  1. Extract city from the place's address components
  2. Auto-fill the City field
  3. Auto-fill the Country field

- **Implementation:**
  - Use `address_components` from Google Places API response
  - Find component with `locality` or `administrative_area_level_1` type
  - Auto-fill city and country_code

---

### 2.7 Notifications & Sharing

> **Related Requirements:** #7, #12

#### 2.7.1 Fix Notification Test Button (REQ #7)

**Problem:** "Test notification" button in settings does nothing visible.

**Solution:**

- Ensure the test notification button:
  1. Requests notification permissions if not granted
  2. Shows a local notification immediately (within 2 seconds)
  3. Displays feedback: "Test notification sent!" toast
  4. If permissions denied, show: "Please enable notifications in device settings"

- **Test Notification Content:**
  ```
  Title: "Waydeck Test"
  Body: "🎉 Notifications are working! You'll receive reminders 30 minutes before your travel events."
  ```

- **Implementation:**
  - Debug `flutter_local_notifications` initialization
  - Ensure iOS permission flow is complete
  - Add try-catch with error feedback

---

#### 2.7.2 Improve Trip Sharing (REQ #12)

**Problem:**
- WhatsApp sharing is very slow
- "Copy link" doesn't work or show feedback

**Solution:**

**a) WhatsApp Sharing:**
- Generate share content synchronously (don't fetch from network)
- Format as plain text summary:
  ```
  🧳 Vietnam & Thailand 2025
  📍 Pune, India → Bangkok, Da Nang, Hanoi
  📅 1 Dec – 15 Dec 2025
  
  ✈ 5 flights | 🏨 4 stays | 🎟 6 activities
  
  Shared from Waydeck
  ```
- Use `share_plus` with pre-built content (no network calls)
- Add loading indicator during share sheet preparation

**b) Copy Link:**
- Generate a shareable deep link: `waydeck://trip/{trip_id}`
- Copy to clipboard immediately
- Show confirmation toast: "✓ Link copied to clipboard"
- Optional: If web sharing is implemented, use HTTPS URL

**c) Share Options Sheet:**
  ```
  ┌────────────────────────────────────────┐
  │  Share Trip                            │
  ├────────────────────────────────────────┤
  │                                        │
  │  [📤 Share via Apps...]                │
  │      Opens system share sheet          │
  │                                        │
  │  [📋 Copy Link]                        │
  │      Copy trip link to clipboard       │
  │                                        │
  │  [📱 WhatsApp]                         │
  │      Quick share to WhatsApp           │
  │                                        │
  │  [Cancel]                              │
  └────────────────────────────────────────┘
  ```

---

### 2.8 Landing & Auth UX

> **Related Requirements:** #23

#### 2.8.1 Pre-Auth Landing Page

**Problem:** Users who aren't logged in go directly to a Sign In screen without context about the app.

**Solution:**

- Create a **Landing Page** shown before auth:
  
  ```
  ┌────────────────────────────────────────┐
  │                                        │
  │           [Waydeck Logo]               │
  │                                        │
  │     Your Complete Travel Companion     │
  │                                        │
  │  ─────────────────────────────────     │
  │                                        │
  │  ┌──────────────────────────────────┐  │
  │  │   📱  [App Screenshot/Carousel]  │  │
  │  │                                  │  │
  │  │   Timeline view, item cards,     │  │
  │  │   document management            │  │
  │  └──────────────────────────────────┘  │
  │                                        │
  │  ─────────────────────────────────     │
  │                                        │
  │  ✈️ Plan complete itineraries         │
  │  📎 Store all your tickets & docs     │
  │  🏨 Track hotels & activities         │
  │  💰 Manage trip budgets               │
  │                                        │
  │  ─────────────────────────────────     │
  │                                        │
  │  [─────── Sign In ───────] (primary)  │
  │                                        │
  │  [─────── Create Account ───────]     │
  │                                        │
  │  ─────────────────────────────────     │
  │                                        │
  │  About • How it Works • Contact       │
  │                                        │
  └────────────────────────────────────────┘
  ```

- **Sections:**
  1. **Hero:** Logo + tagline
  2. **Visual:** Screenshot carousel or illustration
  3. **Features:** Key value propositions with icons
  4. **CTAs:** Sign In (primary), Create Account (secondary)
  5. **Footer:** About, How it Works, Contact links

- **About Page (`/about`):**
  - Brief description of Waydeck
  - Key features list
  - Link back to landing

- **How it Works Page (`/how-it-works`):**
  - Step-by-step flow with illustrations:
    1. Create a trip
    2. Add flights, hotels, activities
    3. Attach tickets and documents
    4. View your complete itinerary
  - CTAs to sign up

- **Contact Page (`/contact`):**
  - Email: support@waydeck.app
  - Feedback form (optional)
  - Social links (if any)

- **Navigation Flow:**
  ```
  App Launch → Splash
                ↓
            Has Session?
           /           \
         Yes            No
          ↓              ↓
     Trip List      Landing Page
                         ↓
              [Sign In] [Create Account]
                    ↓         ↓
               Sign In    Sign Up
                    \       /
                     Trip List
  ```

---

### 2.9 UI/UX Polish & Fixes

> **Related Requirements:** #8, #9, #15, #20

#### 2.9.1 Improved Empty State for Trips (REQ #8)

**Problem:** Current "No trips" empty state has two buttons that don't make sense.

**Solution:**

- Redesign empty state:
  
  ```
  ┌────────────────────────────────────────┐
  │                                        │
  │           🧳                           │
  │     (Illustration: suitcase + map)     │
  │                                        │
  │     No trips yet!                      │
  │                                        │
  │     Start planning your first          │
  │     adventure today.                   │
  │                                        │
  │     [+ Create Your First Trip]         │
  │         (primary button)               │
  │                                        │
  └────────────────────────────────────────┘
  ```

- **Single primary CTA:** One clear action
- **Friendly illustration:** Travel-themed
- **Encouraging copy:** Positive, action-oriented

---

#### 2.9.2 Modern Icon Set (REQ #9)

**Problem:** Some icons in the app look outdated compared to the modern edit/delete/close icons.

**Solution:**

- **Audit all icons** and standardize to a consistent set
- **Recommended:** Use Material Symbols (outlined, 400 weight) or Phosphor Icons
- **Icon Updates:**

  | Location | Current | Updated |
  |----------|---------|---------|
  | Transport modes | Mixed emoji/icons | Consistent outlined icons |
  | Action buttons | Varied styles | Unified icon family |
  | Navigation | Mixed | Consistent back arrows, close X |
  | Badges/chips | Emoji-heavy | Icon + text |

- **Transport Mode Icons:**
  - ✈ Flight → `flight_takeoff` (outlined)
  - 🚂 Train → `train` (outlined)
  - 🚌 Bus → `directions_bus` (outlined)
  - 🚗 Car → `directions_car` (outlined)
  - 🚲 Bike → `pedal_bike` (outlined)
  - 🚢 Cruise → `sailing` (outlined)
  - 🚇 Metro → `subway` (outlined)
  - ⛴ Ferry → `directions_boat` (outlined)

---

#### 2.9.3 Date Validation (REQ #15)

**Problem:** No validation prevents trip/item end dates from being before start dates.

**Solution:**

- **Trip Level:**
  - End date picker should disable dates before start date
  - If start date is changed to after end date, show warning and either:
    - Option A: Auto-clear end date
    - Option B: Show validation error "End date cannot be before start date"

- **Item Level (Transport, Stay, Activity):**
  - Arrival/check-out/end time cannot be before departure/check-in/start time
  - Same validation logic as trip

- **UI Behavior:**
  ```
  Start Date: [5 Dec 2025]
  End Date:   [3 Dec 2025]  ⚠️
  
  "End date cannot be before start date"
  [Save] (disabled until fixed)
  ```

- **Validation Logic:**
  - Validate on field change (not just save)
  - Disable Save button if invalid
  - Show inline error message
  - Highlight field with error border

---

#### 2.9.4 Trip Notes Section Review (REQ #20)

**Problem:** Notes section at trip level may be redundant with Checklists.

**Proposed Change:**

After analysis, **Notes** and **Checklists** serve different purposes:
- **Notes:** Free-form text for general trip information
- **Checklist:** Actionable items to track completion

**Recommendation:**
- **Keep Notes** but reposition:
  - Move from Trip Overview header to a collapsible section
  - Or make it accessible via trip edit/details
- **Rename to "Trip Notes" or "Details"**
- **Make it collapsible** by default if empty

**Alternative:**
- If user testing shows it's truly redundant, remove entirely
- Ensure Notes per trip item remain (for per-item comments)

---

## 3. Data Schema Changes

### 3.1 Modified Tables

#### `profiles` (Extended)

```sql
ALTER TABLE public.profiles
ADD COLUMN phone text,
ADD COLUMN date_of_birth date,
ADD COLUMN nationality char(2),
ADD COLUMN passport_number text,
ADD COLUMN passport_expiry date,
ADD COLUMN theme_preference text DEFAULT 'auto'; -- 'auto', 'light', 'dark'
```

#### `transport_items`, `stay_items`, `activity_items` (Expense Fields)

```sql
-- Add to each item table
ALTER TABLE public.transport_items
ADD COLUMN expense_amount numeric(12,2),
ADD COLUMN expense_currency char(3),
ADD COLUMN payment_status payment_status_enum DEFAULT 'not_paid',
ADD COLUMN payment_method text,
ADD COLUMN expense_notes text;

-- Similar for stay_items and activity_items
```

#### `checklist_items` (Grouping)

```sql
ALTER TABLE public.checklist_items
ADD COLUMN group_name text DEFAULT 'General',
ADD COLUMN sort_order int DEFAULT 0;
```

### 3.2 New Tables

#### `payment_status` Enum

```sql
CREATE TYPE payment_status AS ENUM ('not_paid', 'paid', 'partial');
```

#### `trip_expenses` (Custom Expenses)

```sql
CREATE TABLE public.trip_expenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id uuid NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  category text NOT NULL, -- 'transport', 'stay', 'activity', 'food', 'other'
  description text NOT NULL,
  amount numeric(12,2) NOT NULL,
  currency char(3) NOT NULL,
  payment_status payment_status DEFAULT 'paid',
  expense_date date,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.trip_expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage expenses of own trips"
  ON public.trip_expenses
  FOR ALL
  USING (trip_id IN (SELECT id FROM public.trips WHERE owner_id = auth.uid()))
  WITH CHECK (trip_id IN (SELECT id FROM public.trips WHERE owner_id = auth.uid()));
```

#### `trip_budgets` (Budget per Trip)

```sql
CREATE TABLE public.trip_budgets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id uuid NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  category text NOT NULL, -- 'transport', 'stay', 'activity', 'food', 'other'
  budget_amount numeric(12,2) NOT NULL,
  currency char(3) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(trip_id, category)
);

ALTER TABLE public.trip_budgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage budgets of own trips"
  ON public.trip_budgets
  FOR ALL
  USING (trip_id IN (SELECT id FROM public.trips WHERE owner_id = auth.uid()))
  WITH CHECK (trip_id IN (SELECT id FROM public.trips WHERE owner_id = auth.uid()));
```

#### `global_documents` (Global Travel Documents)

```sql
CREATE TYPE global_doc_type AS ENUM (
  'passport', 'visa', 'travel_insurance', 'health_card',
  'id_card', 'vaccination_certificate', 'other'
);

CREATE TABLE public.global_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  doc_type global_doc_type NOT NULL,
  country_code char(2), -- For visa: which country
  file_name text NOT NULL,
  mime_type text,
  storage_path text NOT NULL,
  size_bytes bigint,
  expiry_date date,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.global_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own global documents"
  ON public.global_documents
  FOR ALL
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());
```

#### `checklist_templates` (User Templates)

```sql
CREATE TABLE public.checklist_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.checklist_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own templates"
  ON public.checklist_templates
  FOR ALL
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());
```

#### `checklist_template_items` (Items in Templates)

```sql
CREATE TABLE public.checklist_template_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id uuid NOT NULL REFERENCES public.checklist_templates(id) ON DELETE CASCADE,
  title text NOT NULL,
  group_name text DEFAULT 'General',
  sort_order int DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.checklist_template_items ENABLE ROW LEVEL SECURITY;

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
```

---

## 4. Implementation Priority

### Phase 1: Bug Fixes & Quick Wins (1-2 weeks)

| Priority | Feature | REQ # |
|----------|---------|-------|
| P0 | Fix document upload | #10 |
| P0 | Fix notifications test button | #7 |
| P0 | Fix "Add new traveller" from picker | #18 |
| P0 | Fix copy link for sharing | #12 |
| P1 | Date validation | #15 |
| P1 | Bike drop-off same as pickup | #16 |
| P1 | Auto-populate airport code | #13 |
| P1 | Auto-populate city from hotel | #19 |
| P1 | Cities display deduplication | #17 |

### Phase 2: Profile & Theming (1 week)

| Priority | Feature | REQ # |
|----------|---------|-------|
| P1 | Profile as traveller (extended fields) | #1 |
| P1 | Add self as passenger | #2 |
| P1 | Theme support (dark mode) | #3 |

### Phase 3: Expenses & Budget (2 weeks)

| Priority | Feature | REQ # |
|----------|---------|-------|
| P1 | Expense fields on items | #4 |
| P1 | Trip expense summary view | #5 |
| P2 | Trip budget view | #6 |

### Phase 4: Documents & Checklists (2 weeks)

| Priority | Feature | REQ # |
|----------|---------|-------|
| P1 | Global documents | #11 |
| P2 | Improved checklist UI | #21 |
| P2 | Global checklist templates | #22 |

### Phase 5: UX Polish (1 week)

| Priority | Feature | REQ # |
|----------|---------|-------|
| P1 | Improved empty state | #8 |
| P2 | Modern icon set | #9 |
| P2 | WhatsApp sharing performance | #12 |
| P2 | Trip notes repositioning | #20 |

### Phase 6: Landing Page (1 week)

| Priority | Feature | REQ # |
|----------|---------|-------|
| P2 | Pre-auth landing page | #23 |

---

## 5. Traceability Matrix

| REQ # | Requirement | Section | Schema Impact | Priority |
|-------|-------------|---------|---------------|----------|
| 1 | Profile with traveller details | 2.1.1 | `profiles` extension | P1 |
| 2 | Add self as passenger | 2.1.2 | None | P1 |
| 3 | Theme support / dark mode | 2.2.1 | `profiles.theme_preference` | P1 |
| 4 | Expense section on items | 2.3.1 | Expense cols on items | P1 |
| 5 | Trip expense summary | 2.3.2 | `trip_expenses` table | P1 |
| 6 | Trip budget view | 2.3.3 | `trip_budgets` table | P2 |
| 7 | Fix notification test button | 2.7.1 | None | P0 |
| 8 | Improved empty state | 2.9.1 | None | P1 |
| 9 | Modern icon set | 2.9.2 | None | P2 |
| 10 | Fix document upload | 2.4.1 | None | P0 |
| 11 | Global documents | 2.4.2 | `global_documents` table | P1 |
| 12 | Improve sharing | 2.7.2 | None | P0/P2 |
| 13 | Auto-populate airport code | 2.6.1 | None | P1 |
| 14 | Google Places for addresses | 2.6.2 | None | P1 |
| 15 | Date validation | 2.9.3 | None | P1 |
| 16 | Bike drop-off toggle | 2.6.3 | None | P1 |
| 17 | Cities display deduplication | 2.6.4 | None | P1 |
| 18 | Fix add traveller from picker | 2.1.3 | None | P0 |
| 19 | Auto-populate city from hotel | 2.6.5 | None | P1 |
| 20 | Trip notes repositioning | 2.9.4 | None | P2 |
| 21 | Improved checklist UI | 2.5.1 | `checklist_items` cols | P2 |
| 22 | Global checklist templates | 2.5.2 | Template tables | P2 |
| 23 | Pre-auth landing page | 2.8.1 | None | P2 |

---

## Summary of New Data Concepts

For the **Backend Agent**, the following **new tables/concepts** are introduced:

1. **`trip_expenses`** – Custom/miscellaneous expenses per trip
2. **`trip_budgets`** – Category-wise budget amounts per trip
3. **`global_documents`** – User-level travel documents (passport, visa, etc.)
4. **`checklist_templates`** – User-defined checklist templates
5. **`checklist_template_items`** – Items within templates
6. **`payment_status` enum** – For tracking expense payment state
7. **`global_doc_type` enum** – Types of global documents

**Extended tables:**
- `profiles` – Added travel document fields (passport, nationality, etc.) + theme preference
- `transport_items`, `stay_items`, `activity_items` – Added expense fields
- `checklist_items` – Added grouping and sorting fields

---

*End of Waydeck v1.1 Spec Addendum*
