# Waydeck - Completed Features Documentation

> **Version:** 1.0 + V2 + V3 Enhancements  
> **Last Updated:** December 8, 2024  
> **Status:** All MVP + V2 + V3 Features Complete

---

## 📋 Feature Comparison Matrix

### Original Spec (waydeck-spec.md) vs Implementation

| Spec Requirement | Status | Notes |
|-----------------|--------|-------|
| **Auth: Email Sign Up/In** | ✅ | Supabase Auth |
| **Auth: Password Reset** | ✅ | Forgot Password flow |
| **Trip: Create/Edit/Delete** | ✅ | Full CRUD |
| **Trip: Archive** | ✅ | Soft delete |
| **Timeline View** | ✅ | Grouped by day with layovers |
| **Transport Items** | ✅ | All 9 modes + new features |
| **Stay Items** | ✅ | Hotels with breakfast flag |
| **Activity Items** | ✅ | With categories |
| **Note Items** | ✅ | Free-form notes |
| **Documents** | ✅ | PDF/Image upload, Supabase Storage |
| **Comments** | ✅ | On all trip items |
| **RLS Security** | ✅ | All tables secured |

### V2 Enhancements (Not in Original Spec)

| Feature | Status | Description |
|---------|--------|-------------|
| **Trip Checklists** | ✅ | Pre-trip task lists |
| **Travellers Management** | ✅ | Passport details, expiry alerts |
| **Trip Status** | ✅ | Planned → Active → Completed |
| **Google Places** | ✅ | City/venue autocomplete |
| **Passenger Selection** | ✅ | Assign travellers to transports |
| **Get Directions** | ✅ | Google Maps integration |
| **Trip Sharing** | ✅ | Share via WhatsApp/Email |
| **Airline Database** | ✅ | 100+ airlines with codes |
| **Traveller Photos** | ✅ | Avatar upload |
| **Today View** | ✅ | Smart daily itinerary |

### V3 Enhancements (Dec 2024)

| Feature | Status | Description |
|---------|--------|-------------|
| **Event Notifications** | ✅ | 30-min reminders before flights/activities |
| **Activity Completion** | ✅ | Auto 'Done' badge for past activities |
| **Trip Item Counts** | ✅ | Accurate transport/stay/activity/doc counts |
| **Documents Section** | ✅ | Trip documents shown in overview |
| **Cities Summary** | ✅ | City chips from trip items |
| **Airline Autocomplete** | ✅ | Search by name, auto-fills IATA code |
| **Airport Autocomplete** | ✅ | Airport search for flight mode |
| **15+ Bug Fixes** | ✅ | P0-P2 issues resolved |

---

## 🗂️ App Structure

```
lib/
├── app/              # App config, router, theme
├── core/             # Environment, utilities
├── features/
│   ├── auth/         # Sign in, Sign up, Password reset
│   ├── checklists/   # Trip checklists (V2)
│   ├── documents/    # File attachments
│   ├── profile/      # User profile + Notification settings (V3)
│   ├── travellers/   # Traveller management (V2)
│   ├── trip_items/   # Transport, Stay, Activity, Note
│   └── trips/        # Trip list, overview, today view
└── shared/
    ├── data/         # Airlines database, countries
    ├── models/       # All data models
    ├── services/     # Places, Share, Avatar, Notifications (V3)
    └── ui/           # Reusable widgets
```

---

## 🧭 Navigation Guide

### Authentication Flow

| Screen | Route | How to Navigate |
|--------|-------|-----------------|
| Splash | `/` | App launch |
| Sign In | `/auth/signin` | Default if not logged in |
| Sign Up | `/auth/signup` | "Create account" link |
| Forgot Password | `/auth/forgot` | "Forgot password?" link |

---

### Main App Screens

| Screen | Route | How to Navigate |
|--------|-------|-----------------|
| **Trip List** | `/trips` | Home screen (after login) |
| **Today View** | `/today` | Today icon in app bar (when active trip exists) |
| **Profile** | `/profile` | Person icon in app bar |
| **New Trip** | `/trips/new` | Floating "+" button |

---

### Trip Screens

| Screen | Route | How to Navigate |
|--------|-------|-----------------|
| Trip Overview | `/trips/:id` | Tap any trip card |
| Edit Trip | `/trips/:id/edit` | Edit icon in trip overview |
| Checklist | `/trips/:id/checklist` | "Checklist" button in trip overview |

---

### Trip Item Screens

| Item Type | View Route | Form Route | Navigation |
|-----------|------------|------------|------------|
| Transport | `/trips/:tripId/items/:itemId/transport` | `/trips/:tripId/items/transport/new` | + button → Transport |
| Stay | `/trips/:tripId/items/:itemId/stay` | `/trips/:tripId/items/stay/new` | + button → Stay |
| Activity | `/trips/:tripId/items/:itemId/activity` | `/trips/:tripId/items/activity/new` | + button → Activity |
| Note | `/trips/:tripId/items/:itemId/note` | `/trips/:tripId/items/note/new` | + button → Note |

---

### Travellers & Documents

| Screen | Route | How to Navigate |
|--------|-------|-----------------|
| Travellers List | `/travellers` | Profile → My Travellers |
| Add Traveller | `/travellers/new` | "+" button in travellers |
| Edit Traveller | `/travellers/:id/edit` | Tap traveller card |
| Document Viewer | `/documents/:id` | Tap any document thumbnail |

---

## ⚙️ Feature Details

### 1. Trip Management

**Create Trip:**
1. Tap **"+ New Trip"** button
2. Enter name, origin city (autocomplete), dates
3. Tap **Save**

**View Trip:**
- Shows: Summary card, timeline, items list
- Actions: Edit, Archive, Delete, Share, Checklist

**Trip Status:**
- Tap **"Start Trip"** to mark as Active
- Tap **"Complete Trip"** when finished
- Status badge shows in overview

---

### 2. Transport Items

**Add Transport:**
1. Trip Overview → **"+"** button → **Transport**
2. Select mode (Flight, Train, Bus, Car, etc.)
3. Enter details:
   - Carrier code with airline autocomplete (flights)
   - Origin/Destination with city autocomplete
   - Times, booking reference
   - Select passengers from travellers

**Special Features:**
- **Airline Autocomplete:** Type "6E" or "IndiGo" for suggestions
- **Passenger Picker:** Assign travellers to this transport
- **Get Directions:** Button on detail screen → Google Maps
- **Vehicle Number:** For Car/Bike/Bus modes

**Mode-Specific Fields:**

| Mode | Carrier Label | Location Label | Terminal Label |
|------|---------------|----------------|----------------|
| ✈️ Flight | Airline | Airport Code | Terminal |
| 🚂 Train | Railway | Station | Platform |
| 🚌 Bus | Operator | Bus Stop | Bay |
| 🚗 Car | Rental Co | Pickup/Dropoff | - |
| 🚲 Bike | Rental Co | Pickup/Dropoff | - |
| 🚢 Cruise | Cruise Line | Port | Pier |
| 🚇 Metro | Line | Station | - |
| ⛴️ Ferry | Operator | Port | Pier |

---

### 3. Stay Items (Hotels)

**Add Stay:**
1. **"+"** → **Stay**
2. Hotel name with establishment autocomplete
3. Address, city (autocomplete), country
4. Check-in/out dates and times
5. Breakfast included toggle

**View Stay:**
- Shows hotel card with dates
- **Get Directions** button for Google Maps

---

### 4. Activity Items

**Add Activity:**
1. **"+"** → **Activity**
2. Activity name (autocomplete if venue)
3. Location, city, start/end times
4. Category (tour, museum, food, etc.)

**View Activity:**
- Shows activity card with timing
- **Get Directions** button for location

---

### 5. Documents

**Attach Document:**
1. Any item detail screen → **"Attach"** / **Documents** section
2. Pick PDF or image from device
3. Select document type (Ticket, Voucher, Visa, etc.)

**View Document:**
- Tap document thumbnail → Full screen viewer
- Supports PDF and images

---

### 6. Travellers (V2)

**Add Traveller:**
1. Profile → **My Travellers** → **"+"**
2. Enter name, email, phone
3. Passport number and expiry date
4. Nationality

**Features:**
- **Passport Expiry Alert:** Warning if < 6 months
- **Avatar Upload:** Tap circle to add photo
- **Passenger Selection:** Assign to transports

---

### 7. Trip Checklists (V2)

**Access Checklist:**
1. Trip Overview → **"Checklist"** button
2. Add custom items or use defaults
3. Check off as completed

**Default Items:**
- Passport, Visa, Travel Insurance
- Medications, Chargers, etc.

---

### 8. Trip Sharing (V2)

**Share a Trip:**
1. Trip Overview → **Share** icon (app bar)
2. Choose:
   - **Share Trip:** Opens device share sheet
   - **Copy Link:** Copies URL to clipboard

---

### 9. Today View (V2)

**Auto-Detection:**
- When today falls within a trip's start/end dates
- **Today banner** appears at top of Trip List
- **Today icon** appears in app bar

**View:**
- Current city (from stay)
- Today's activities sorted by time
- Current hotel information
- **Get Directions** for each item
- **"+"** FAB to add activities

---

### 10. Google Places Integration (V2)

**Where It Works:**
- Trip Form: Origin city
- Transport Form: Origin/Destination cities (airport search for flights)
- Stay Form: Hotel name, City
- Activity Form: Venue, City

**How to Use:**
- Start typing (min 2 chars)
- Dropdown appears with suggestions
- Select to auto-fill details (address, city, country)

---

### 11. Event Notifications (V3)

**Setup:**
1. Profile → **Notifications** section
2. Enable **Event Reminders** toggle
3. Grant permission when prompted

**Features:**
- Notifies **30 minutes before** flights, check-ins, activities
- Works on iOS and Android
- **Test Notification** button to verify setup

---

### 12. Activity Completion (V3)

**Auto-Detection:**
- When activity time passes, card shows:
  - Green **"Done"** badge with checkmark
  - Title with strikethrough
  - Reduced opacity (70%)

---

### 13. Trip Overview Enhancements (V3)

**New Elements:**
- **Cities Summary:** Chips showing all cities in trip
- **Documents Section:** Shows document count with link
- **Accurate Item Counts:** Transport, stays, activities, notes, documents

---

### 14. Bug Fixes (V3)

| Issue | Fix |
|-------|-----|
| Sign out button invisible | Fixed text color for outlined destructive buttons |
| Checklist save crash | Fixed disposed notifier by reading before dialog close |
| Avatar upload crash | Added error handling for missing storage bucket |
| Stay detail overflow | Wrapped text in Flexible widget |
| Edit forms blank | Added data loading in edit mode |
| Passenger checkbox state | Converted to StatefulWidget for local state |
| Country dropdown collapse | Moved to separate row |
| iOS share crash | Added sharePositionOrigin parameter |
| Complete button styling | Changed to ElevatedButton |
| Add traveller from picker | Added navigation with redirect |

---

## 🗄️ Database Schema

### SQL Migrations (sql/ folder)

| File | Description |
|------|-------------|
| `001_init_extensions.sql` | Enable pgcrypto extension |
| `010_enums.sql` | trip_item_type, transport_mode, document_type |
| `020_profiles.sql` | User profiles table |
| `030_trips.sql` | Trips table with RLS |
| `040_trip_items.sql` | Base trip items table |
| `050_transport_items.sql` | Transport details table |
| `060_stay_items.sql` | Stay/hotel details table |
| `070_activity_items.sql` | Activity details table |
| `080_documents.sql` | Document attachments table |
| `090_seed_example.sql` | Sample data for development |
| `091_vehicle_number.sql` | **V1+** Add vehicle_number column |
| `092_checklist_items.sql` | **V2** Checklist items table |
| `093_travellers.sql` | **V2** Travellers + trip_travellers tables |
| `094_trip_status.sql` | **V2** Trip status column |
| `095_transport_passengers.sql` | **V2** Transport-traveller junction |
| `096_trip_shares.sql` | **V2** Trip sharing with codes |
| `097_fix_trip_shares_recursion.sql` | **V2** Fix RLS recursion |
| `098_traveller_avatars.sql` | **V2** Avatar URL column |

### Core Tables (from spec)
- `profiles` - User profiles linked to auth.users
- `trips` - Trip data with origin, dates, notes
- `trip_items` - Base items with type enum
- `transport_items` - Transport mode, carrier, route, times
- `stay_items` - Hotel name, checkin/out, breakfast
- `activity_items` - Activity category, location, times
- `documents` - File attachments with storage path

### V2 Tables
- `checklist_items` - Pre-trip task checklist per trip
- `travellers` - Traveller profiles with passport info
- `trip_travellers` - Many-to-many trip-traveller link
- `transport_passengers` - Passenger assignment per transport
- `trip_shares` - Share codes for collaboration

---

## 🎨 V1 Features (Beyond MVP Spec)

These features were added during V1 development:

| Feature | Description | SQL/Files |
|---------|-------------|-----------|
| **Vehicle Number** | Registration plate for car/bus/bike | `091_vehicle_number.sql` |
| **Same Location Toggle** | Origin = Destination for round trips | Transport form UI |
| **Country Picker** | Searchable country dropdown | `country_picker.dart` |
| **Layover Calculation** | Auto-compute wait time between legs | Timeline widget |
| **Offline Cache** | Local storage of trip data | shared_preferences |

---

## 📱 UI Components

### Custom Widgets (lib/shared/ui/)

| Widget | Purpose |
|--------|---------|
| `WaydeckButton` | Primary/secondary buttons |
| `WaydeckInput` | Text input with label |
| `WaydeckCard` | Styled card container |
| `BadgeChip` | Mode/status badges |
| `CountryPicker` | Country selection dropdown |
| `PlacesAutocomplete` | Google Places search |
| `AirlineAutocomplete` | Airline code search |
| `PassengerPicker` | Traveller selection |
| `LoadingOverlay` | Loading indicators |

---

## ⚠️ Setup Requirements

### Environment Variables (.env)
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
GOOGLE_PLACES_API_KEY=your_places_key
```

### Supabase Storage Buckets
- `trip_documents` - Trip and item attachments
- `traveller-avatars` - User profile photos (public access)

> **Setup:** See `sql/100_storage_buckets.sql` for RLS policies

### Google Cloud APIs
- Places API (enabled, with billing)
- Maps JavaScript API (for directions links)

---

## 🧪 Testing Quick Reference

| Test | Steps |
|------|-------|
| Auth | Sign up → Sign out → Sign in → Reset password |
| Trip CRUD | Create → Edit → Archive → Delete |
| Transport | Add flight with passengers → View → Get Directions |
| Stay | Add hotel → View → Get Directions |
| Activity | Add activity → View → Get Directions |
| Documents | Attach PDF → View in viewer |
| Travellers | Add → Edit photo → Add to transport |
| Checklist | Open → Add items → Complete items |
| Sharing | Share trip → Copy link |
| Today View | Create trip for today → See banner |

---

## 📦 Dependencies

```yaml
# Core
supabase_flutter: ^2.8.1
flutter_riverpod: ^2.6.1
go_router: ^14.6.2

# Data
freezed: ^2.5.7
json_serializable: ^6.9.0

# UI
tdesign_flutter: ^0.1.8
cached_network_image: ^3.4.1

# Features (V2)
http: ^1.2.2
url_launcher: ^6.3.1
share_plus: ^10.1.4
image_picker: ^1.1.2

# Features (V3)
flutter_local_notifications: ^19.5.0
timezone: ^0.10.1
```

