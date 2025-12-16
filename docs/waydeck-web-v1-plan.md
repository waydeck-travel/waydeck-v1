# Waydeck Web v1 – Implementation Plan

> **Version:** 1.0  
> **Created:** 2025-12-15  
> **Status:** Ready for Review  
> **Base Docs:** waydeck-spec.md, waydeck-completed-features.md, waydeck-v1.1-spec-addendum.md

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Scope Definition](#2-scope-definition)
3. [Route Map](#3-route-map)
4. [Page-to-Feature Mapping](#4-page-to-feature-mapping)
5. [Tech Stack & Architecture](#5-tech-stack--architecture)
6. [Project Structure](#6-project-structure)
7. [Phased Implementation Plan](#7-phased-implementation-plan)
8. [Supabase Integration Details](#8-supabase-integration-details)
9. [Risks & Considerations](#9-risks--considerations)
10. [Left for Later](#10-left-for-later)

---

## 1. Executive Summary

Waydeck Web v1 will provide a full-featured web companion to the existing Flutter mobile app. The web app will achieve **feature parity** with mobile (v1 + V2 + V3) while adding **web-specific enhancements** that take advantage of larger screens and desktop interaction patterns.

### Goals

- **Parity MVP**: All features from `waydeck-completed-features.md` that work on web
- **Web Enhancements**: Drag-and-drop timeline, richer expense views, PDF export, better Today overview
- **Marketing Presence**: Public landing page, about, how-it-works pages
- **Same Backend**: Shared Supabase for seamless cross-platform data

### Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | **Next.js 14+ (App Router)** |
| Language | **TypeScript** |
| Styling | **Tailwind CSS** |
| Components | **shadcn/ui** + **lucide-react** icons |
| Backend | **Supabase** (existing project) |
| Auth | **@supabase/ssr** for server-side auth |

---

## 2. Scope Definition

### 2.1 Web Parity MVP (Must Have)

All features currently shipped on mobile, adapted for web:

#### Authentication
| Feature | Mobile Status | Web Scope |
|---------|---------------|-----------|
| Email Sign Up/Sign In | ✅ Done | Full parity |
| Password Reset | ✅ Done | Full parity |
| Session Persistence | ✅ Done | Using cookies via @supabase/ssr |
| Sign Out | ✅ Done | Full parity |

#### Trip Management
| Feature | Mobile Status | Web Scope |
|---------|---------------|-----------|
| Trip List | ✅ Done | Full parity with grid/list toggle |
| Create/Edit Trip | ✅ Done | Full parity |
| Archive/Delete Trip | ✅ Done | Full parity |
| Trip Status (Planned → Active → Completed) | ✅ Done | Full parity |
| Trip Sharing | ✅ Done | Full parity + improved web share |

#### Timeline & Trip Items
| Feature | Mobile Status | Web Scope |
|---------|---------------|-----------|
| Timeline View (grouped by day) | ✅ Done | Full parity with wider layout |
| Transport Items (9 modes) | ✅ Done | Full parity |
| Stay Items | ✅ Done | Full parity |
| Activity Items | ✅ Done | Full parity |
| Note Items | ✅ Done | Full parity |
| Layover Calculation | ✅ Done | Full parity |
| Item Counts | ✅ Done | Full parity |
| Cities Summary Chips | ✅ Done | Full parity |

#### Documents
| Feature | Mobile Status | Web Scope |
|---------|---------------|-----------|
| Upload PDF/Image to Trip/Item | ✅ Done | Full parity + drag-drop upload |
| View Documents | ✅ Done | In-browser PDF viewer |
| Document Grid in Overview | ✅ Done | Full parity |

#### Travellers (V2)
| Feature | Mobile Status | Web Scope |
|---------|---------------|-----------|
| Traveller Management | ✅ Done | Full parity |
| Passport Details & Expiry Alerts | ✅ Done | Full parity |
| Avatar Upload | ✅ Done | Full parity |
| Passenger Selection for Transport | ✅ Done | Full parity |

#### Checklists (V2)
| Feature | Mobile Status | Web Scope |
|---------|---------------|-----------|
| Trip Checklists | ✅ Done | Full parity |
| Add/Complete Items | ✅ Done | Full parity |

#### Today View (V2)
| Feature | Mobile Status | Web Scope |
|---------|---------------|-----------|
| Today Banner | ✅ Done | Full parity |
| Today Itinerary | ✅ Done | Enhanced with larger layout |

#### Autocomplete & Location (V2)
| Feature | Mobile Status | Web Scope |
|---------|---------------|-----------|
| Google Places Autocomplete | ✅ Done | Full parity (Places API) |
| Airline Autocomplete | ✅ Done | Client-side with airline DB |
| Airport Autocomplete | ✅ Done | Client-side with airport DB |

#### Profile
| Feature | Mobile Status | Web Scope |
|---------|---------------|-----------|
| View/Edit Profile | ✅ Done | Full parity |
| Notification Settings | ✅ Done | Display only (no mobile notifications) |

---

### 2.2 Web Enhancements (Nice to Have)

Features that work better on web or leverage larger screens:

| Feature | Description | Priority |
|---------|-------------|----------|
| **Drag-and-Drop Timeline** | Reorder items by dragging within/between days | P2 |
| **Card Grid vs List Toggle** | Switch between card grid and compact list view | P1 |
| **Richer Expense Dashboard** | Charts, category breakdown, budget vs actual | P2 |
| **PDF Itinerary Export** | Generate printable itinerary PDF | P2 |
| **Keyboard Shortcuts** | Quick navigation, create actions | P3 |
| **Bulk Timeline Actions** | Select multiple items to delete/move | P3 |
| **Split-Pane Layout** | Trip list + overview side-by-side on wide screens | P2 |
| **Inline Item Editing** | Click to edit items without full modal | P3 |
| **Calendar View** | Month-view alternative to timeline | P3 |
| **Dark Mode Toggle** | Based on `theme_preference` from v1.1 | P1 |

---

### 2.3 v1.1 Features (Partial Support)

Features from `waydeck-v1.1-spec-addendum.md` to include on web:

| Feature | Schema Ready | Web Support |
|---------|--------------|-------------|
| Profile as Traveller (extended fields) | ✅ | Full parity |
| Theme Support (Dark Mode) | ✅ | Full parity |
| Expense Fields on Items | ✅ | Full parity |
| Trip Expense Summary | ✅ | Full parity with charts |
| Trip Budget View | ✅ | Full parity with progress bars |
| Global Documents | ✅ | Full parity |
| Improved Checklist UI | ✅ | Full parity |
| Global Checklist Templates | ✅ | Full parity |

---

## 3. Route Map

### 3.1 Public Routes (No Auth Required)

| Route | Purpose | Content |
|-------|---------|---------|
| `/` | Landing Page | Hero, features, screenshots, CTAs |
| `/about` | About Waydeck | App description, key features |
| `/how-it-works` | How it Works | Step-by-step flow with illustrations |
| `/contact` | Contact | Email, feedback form (optional) |

### 3.2 Auth Routes

| Route | Purpose | Redirect If |
|-------|---------|-------------|
| `/auth/sign-in` | Sign In | → `/app/trips` if logged in |
| `/auth/sign-up` | Create Account | → `/app/trips` if logged in |
| `/auth/forgot-password` | Password Reset | → `/auth/sign-in` after success |
| `/auth/callback` | OAuth/Magic Link Callback | → `/app/trips` |

### 3.3 App Routes (Auth Required)

| Route | Purpose | Key Features |
|-------|---------|--------------|
| `/app/trips` | Trip List | All trips, create new, grid/list toggle |
| `/app/trips/new` | Create Trip | Trip form |
| `/app/trips/[tripId]` | Trip Overview | Summary card, timeline, documents |
| `/app/trips/[tripId]/edit` | Edit Trip | Trip form (edit mode) |
| `/app/trips/[tripId]/checklist` | Trip Checklist | Checklist items with groups |
| `/app/trips/[tripId]/expenses` | Trip Expenses | Expense summary, breakdown, add custom |
| `/app/trips/[tripId]/budget` | Trip Budget | Category budgets with progress |
| `/app/trips/[tripId]/items/[itemId]` | Item Detail | Transport/Stay/Activity/Note details |
| `/app/trips/[tripId]/items/new` | Add Item | Item type selection + form |
| `/app/today` | Today View | Today's itinerary across all trips |
| `/app/profile` | Profile | User details, settings, sign out |
| `/app/profile/edit` | Edit Profile | Extended traveller-like fields |
| `/app/travellers` | Travellers List | All travellers |
| `/app/travellers/new` | Add Traveller | Traveller form |
| `/app/travellers/[travellerId]` | View/Edit Traveller | Traveller form (edit mode) |
| `/app/documents` | Global Documents | Passport, visa, insurance, etc. |
| `/app/checklists` | Checklist Templates | Global reusable templates |
| `/app/checklists/[templateId]` | Edit Template | Template items |

### 3.4 Auth-Gating Strategy

```typescript
// middleware.ts
export async function middleware(request: NextRequest) {
  const supabase = createServerClient(...)
  const { data: { session } } = await supabase.auth.getSession()
  
  const isAppRoute = request.nextUrl.pathname.startsWith('/app')
  const isAuthRoute = request.nextUrl.pathname.startsWith('/auth')
  
  // Redirect unauthenticated users from /app/* to /auth/sign-in
  if (isAppRoute && !session) {
    return NextResponse.redirect(new URL('/auth/sign-in', request.url))
  }
  
  // Redirect authenticated users from /auth/* to /app/trips
  if (isAuthRoute && session) {
    return NextResponse.redirect(new URL('/app/trips', request.url))
  }
  
  return NextResponse.next()
}
```

---

## 4. Page-to-Feature Mapping

| Page | Features | Supabase Tables | Source Docs |
|------|----------|-----------------|-------------|
| **Landing** `/` | Hero, Features, CTA | None | v1.1-spec-addendum §2.8 |
| **Sign In** `/auth/sign-in` | Email/password auth | `auth.users` | waydeck-spec §2.1, §6.1 |
| **Sign Up** `/auth/sign-up` | Registration, confirm email | `auth.users`, `profiles` | waydeck-spec §2.1 |
| **Forgot Password** `/auth/forgot-password` | Password reset email | `auth.users` | waydeck-spec §2.1 |
| **Trip List** `/app/trips` | List trips, create, archive | `trips` | waydeck-spec §2.2, §6.2 |
| **Trip Overview** `/app/trips/[tripId]` | Summary, timeline, docs | `trips`, `trip_items`, `transport_items`, `stay_items`, `activity_items`, `documents` | waydeck-spec §6.3, completed-features |
| **Trip Checklist** `/app/trips/[tripId]/checklist` | Checklist items | `checklist_items` | completed-features §7 |
| **Trip Expenses** `/app/trips/[tripId]/expenses` | Expense summary | `trip_expenses`, item expense fields | v1.1-spec-addendum §2.3.2 |
| **Trip Budget** `/app/trips/[tripId]/budget` | Category budgets | `trip_budgets` | v1.1-spec-addendum §2.3.3 |
| **Item Detail** `/app/trips/[tripId]/items/[itemId]` | View/edit item details | `trip_items` + type table | waydeck-spec §6.4 |
| **Today View** `/app/today` | Today's itinerary | `trips`, `trip_items` (filtered by date) | completed-features §9 |
| **Profile** `/app/profile` | User profile, settings | `profiles` | waydeck-ux-blueprint §3.18 |
| **Travellers** `/app/travellers` | Traveller list, CRUD | `travellers`, `trip_travellers` | completed-features §6 |
| **Global Documents** `/app/documents` | User travel docs | `global_documents` | v1.1-spec-addendum §2.4.2 |
| **Checklist Templates** `/app/checklists` | Reusable templates | `checklist_templates`, `checklist_template_items` | v1.1-spec-addendum §2.5.2 |

---

## 5. Tech Stack & Architecture

### 5.1 Core Stack

| Technology | Purpose | Notes |
|------------|---------|-------|
| **Next.js 14+** | React framework | App Router, Server Components |
| **TypeScript** | Type safety | Strict mode, shared types with Supabase |
| **Tailwind CSS** | Styling | Utility-first, custom design tokens |
| **shadcn/ui** | Component library | Accessible, customizable |
| **lucide-react** | Icons | Consistent icon set |
| **@supabase/supabase-js** | Supabase client | Browser client |
| **@supabase/ssr** | SSR auth | Server-side auth with cookies |

### 5.2 Additional Dependencies

| Package | Purpose |
|---------|---------|
| `date-fns` | Date formatting and parsing |
| `react-hook-form` | Form handling |
| `zod` | Schema validation |
| `@tanstack/react-query` | Server state management (optional) |
| `react-dropzone` | Drag-drop file upload |
| `@react-pdf/renderer` or `jspdf` | PDF export |
| `@hello-pangea/dnd` | Drag-and-drop (for timeline) |
| `recharts` | Charts for expense dashboard |

### 5.3 Architecture Decisions

1. **Server Components Default**: Use RSC for data fetching where possible
2. **Supabase SSR**: Auth via middleware and server actions
3. **Client State**: React state + URL params, minimal global state
4. **Route Handlers**: For server-side mutations when needed
5. **Optimistic Updates**: For better UX on mutations

---

## 6. Project Structure

```
waydeck-v1/web/
├── app/                          # Next.js App Router
│   ├── (marketing)/              # Public pages (landing, about)
│   │   ├── page.tsx              # Landing page
│   │   ├── about/page.tsx
│   │   ├── how-it-works/page.tsx
│   │   └── contact/page.tsx
│   ├── auth/                     # Auth pages
│   │   ├── sign-in/page.tsx
│   │   ├── sign-up/page.tsx
│   │   ├── forgot-password/page.tsx
│   │   └── callback/route.ts     # OAuth callback
│   ├── app/                      # Authenticated app
│   │   ├── layout.tsx            # App shell with nav
│   │   ├── trips/
│   │   │   ├── page.tsx          # Trip list
│   │   │   ├── new/page.tsx      # Create trip
│   │   │   └── [tripId]/
│   │   │       ├── page.tsx      # Trip overview
│   │   │       ├── edit/page.tsx
│   │   │       ├── checklist/page.tsx
│   │   │       ├── expenses/page.tsx
│   │   │       ├── budget/page.tsx
│   │   │       └── items/
│   │   │           ├── new/page.tsx
│   │   │           └── [itemId]/page.tsx
│   │   ├── today/page.tsx
│   │   ├── profile/
│   │   │   ├── page.tsx
│   │   │   └── edit/page.tsx
│   │   ├── travellers/
│   │   │   ├── page.tsx
│   │   │   ├── new/page.tsx
│   │   │   └── [travellerId]/page.tsx
│   │   ├── documents/page.tsx
│   │   └── checklists/
│   │       ├── page.tsx
│   │       └── [templateId]/page.tsx
│   ├── layout.tsx                # Root layout
│   └── globals.css
├── components/
│   ├── ui/                       # shadcn/ui components
│   ├── forms/                    # Form components
│   │   ├── trip-form.tsx
│   │   ├── transport-form.tsx
│   │   ├── stay-form.tsx
│   │   ├── activity-form.tsx
│   │   └── note-form.tsx
│   ├── trips/                    # Trip-specific components
│   │   ├── trip-card.tsx
│   │   ├── trip-summary.tsx
│   │   └── trip-actions.tsx
│   ├── timeline/                 # Timeline components
│   │   ├── timeline.tsx
│   │   ├── timeline-day-group.tsx
│   │   ├── timeline-item-card.tsx
│   │   └── layover-chip.tsx
│   ├── documents/                # Document components
│   │   ├── document-grid.tsx
│   │   ├── document-uploader.tsx
│   │   └── document-viewer.tsx
│   ├── travellers/               # Traveller components
│   │   ├── traveller-card.tsx
│   │   └── passenger-picker.tsx
│   └── shared/                   # Shared components
│       ├── date-picker.tsx
│       ├── country-picker.tsx
│       ├── places-autocomplete.tsx
│       ├── airline-autocomplete.tsx
│       └── empty-state.tsx
├── lib/
│   ├── supabase/
│   │   ├── client.ts             # Browser client
│   │   ├── server.ts             # Server client
│   │   └── middleware.ts         # Auth middleware helper
│   ├── utils.ts                  # General utilities
│   ├── dates.ts                  # Date formatting
│   └── constants.ts              # App constants
├── types/
│   ├── database.ts               # Supabase generated types
│   ├── trip.ts
│   ├── trip-item.ts
│   ├── traveller.ts
│   └── enums.ts
├── data/
│   ├── airlines.ts               # Airline database
│   ├── airports.ts               # Airport database
│   └── countries.ts              # Country list
├── hooks/
│   ├── use-trip.ts
│   ├── use-trip-items.ts
│   └── use-travellers.ts
├── actions/                      # Server actions
│   ├── trips.ts
│   ├── trip-items.ts
│   └── auth.ts
├── middleware.ts                 # Auth middleware
├── tailwind.config.ts
├── next.config.js
├── package.json
└── tsconfig.json
```

---

## 7. Phased Implementation Plan

### Phase 1: Foundation (Week 1-2)

**Goal**: Scaffold project, auth, and basic trip list

#### Routes to Build
- Landing page `/`
- Auth pages `/auth/*`
- Trip list `/app/trips`
- Create trip `/app/trips/new`

#### Components
- Layout components (header, sidebar, footer)
- Auth forms (sign-in, sign-up, forgot-password)
- Trip card
- Empty state

#### Supabase Integration
- Client setup (browser + server)
- Auth middleware
- `profiles` table query/insert
- `trips` table CRUD

#### Deliverables
- [ ] Next.js project initialized with App Router
- [ ] Tailwind + shadcn/ui configured
- [ ] Supabase client setup with SSR auth
- [ ] Auth middleware protecting `/app/*`
- [ ] Sign in / Sign up / Forgot password working
- [ ] Profile auto-creation on sign up
- [ ] Trip list with real data
- [ ] Create trip form
- [ ] Basic landing page

#### Risks
- Supabase SSR setup can be tricky with cookies
- RLS policies already exist, just need to use them correctly

---

### Phase 2: Trip Overview & Timeline (Week 3-4)

**Goal**: Full trip overview with timeline and all item types

#### Routes to Build
- Trip overview `/app/trips/[tripId]`
- Edit trip `/app/trips/[tripId]/edit`
- Item detail `/app/trips/[tripId]/items/[itemId]`
- Add item `/app/trips/[tripId]/items/new`

#### Components
- Trip summary card (counts, cities, dates)
- Timeline widget with day groups
- Transport/Stay/Activity/Note cards
- Layover chip
- Item forms (transport, stay, activity, note)
- Mode selector (flight, train, bus, etc.)

#### Supabase Integration
- `trip_items` + type tables queries
- Timeline query with joins
- CRUD for all item types
- Item counts aggregation

#### Deliverables
- [ ] Trip overview with summary card
- [ ] Timeline view grouped by day
- [ ] All 4 item type cards rendering correctly
- [ ] Layover calculation between transports
- [ ] Cities summary chips
- [ ] Add/edit forms for all 4 item types
- [ ] Mode-specific fields for transport
- [ ] Item deletion

#### Risks
- Timeline grouping logic needs careful date handling
- Large trips (300+ items) need pagination or virtualization
- Timezone handling (store UTC, display local)

---

### Phase 3: Documents & Travellers (Week 5-6)

**Goal**: File attachments and traveller management

#### Routes to Build
- Travellers list `/app/travellers`
- Add/edit traveller `/app/travellers/new`, `/app/travellers/[id]`
- Profile page `/app/profile`
- Profile edit `/app/profile/edit`

#### Components
- Document grid in item detail
- Document uploader (drag-drop)
- Document viewer (in-browser PDF/image)
- Traveller card
- Traveller form
- Passenger picker (for transport)
- Avatar upload

#### Supabase Integration
- `documents` table CRUD
- Supabase Storage upload/download
- `travellers` table CRUD
- `trip_travellers` junction
- `transport_passengers` junction

#### Deliverables
- [ ] Upload documents to trips/items
- [ ] View documents in browser
- [ ] Delete documents
- [ ] Traveller list and CRUD
- [ ] Passport expiry warnings
- [ ] Avatar upload to Supabase Storage
- [ ] Passenger selection in transport form
- [ ] Profile view with traveller-like fields
- [ ] Profile edit form

#### Risks
- Large file uploads need progress indicators
- Storage bucket permissions (RLS on storage exists)

---

### Phase 4: Checklists, Expenses & Budgets (Week 7-8)

**Goal**: Trip checklists, expense tracking, and budgets

#### Routes to Build
- Trip checklist `/app/trips/[tripId]/checklist`
- Trip expenses `/app/trips/[tripId]/expenses`
- Trip budget `/app/trips/[tripId]/budget`
- Global documents `/app/documents`
- Checklist templates `/app/checklists`

#### Components
- Checklist with groups and progress
- Checklist item row (toggle, delete)
- Expense summary card
- Expense breakdown list
- Custom expense form
- Budget category with progress bar
- Budget edit form
- Template list
- Template editor

#### Supabase Integration
- `checklist_items` CRUD
- `trip_expenses` CRUD
- `trip_budgets` CRUD
- `global_documents` CRUD
- `checklist_templates` + `checklist_template_items` CRUD
- Aggregate expense totals

#### Deliverables
- [ ] Trip checklist with groups
- [ ] Add/complete/delete checklist items
- [ ] Import from template
- [ ] Expense summary with category totals
- [ ] Add custom expenses
- [ ] Budget view with visual progress
- [ ] Set/edit budget per category
- [ ] Global documents page
- [ ] Checklist templates management

#### Risks
- Currency handling (might need conversion later)
- Expense aggregation performance

---

### Phase 5: Today View & Polish (Week 9-10)

**Goal**: Today view, sharing, and UI polish

#### Routes to Build
- Today view `/app/today`

#### Components
- Today itinerary (larger layout)
- Today banner on trip list
- Share modal/dropdown
- Improved empty states
- Dark mode toggle

#### Features
- Trip sharing (copy link, native share)
- Today view with active trip detection
- Dark mode based on `theme_preference`
- Get directions links (Google Maps)

#### Deliverables
- [ ] Today view with current city, activities, hotel
- [ ] Today banner on trip list when applicable
- [ ] Share trip via native share or copy link
- [ ] Dark mode support
- [ ] Empty states for all list views
- [ ] General UI polish

---

### Phase 6: Marketing Pages & Launch (Week 11-12)

**Goal**: Public pages and production readiness

#### Routes to Build
- About `/about`
- How it Works `/how-it-works`
- Contact `/contact`

#### Features
- Landing page with screenshots/animations
- SEO meta tags
- Mobile-responsive marketing pages
- Error boundaries
- Loading states

#### Deliverables
- [ ] Landing page with hero, features, CTAs
- [ ] About page
- [ ] How It Works page
- [ ] Contact page
- [ ] SEO optimization
- [ ] Responsive design verified
- [ ] Production build + deploy to Vercel

---

## 8. Supabase Integration Details

### 8.1 Tables Used

| Table | Operations | RLS Scope |
|-------|------------|-----------|
| `profiles` | SELECT, UPDATE | Own profile |
| `trips` | SELECT, INSERT, UPDATE, DELETE | Own trips |
| `trip_items` | SELECT, INSERT, UPDATE, DELETE | Items in own trips |
| `transport_items` | SELECT, INSERT, UPDATE, DELETE | Items in own trips |
| `stay_items` | SELECT, INSERT, UPDATE, DELETE | Items in own trips |
| `activity_items` | SELECT, INSERT, UPDATE, DELETE | Items in own trips |
| `documents` | SELECT, INSERT, DELETE | Own documents |
| `checklist_items` | SELECT, INSERT, UPDATE, DELETE | Items in own trips |
| `travellers` | SELECT, INSERT, UPDATE, DELETE | Own travellers |
| `trip_travellers` | SELECT, INSERT, DELETE | Own trip links |
| `transport_passengers` | SELECT, INSERT, DELETE | Own transport links |
| `trip_expenses` | SELECT, INSERT, UPDATE, DELETE | Expenses in own trips |
| `trip_budgets` | SELECT, INSERT, UPDATE, DELETE | Budgets in own trips |
| `global_documents` | SELECT, INSERT, DELETE | Own global docs |
| `checklist_templates` | SELECT, INSERT, UPDATE, DELETE | Own templates |
| `checklist_template_items` | SELECT, INSERT, UPDATE, DELETE | Items in own templates |

### 8.2 Storage Buckets

| Bucket | Purpose | Public |
|--------|---------|--------|
| `trip_documents` | Trip and item attachments | No |
| `traveller-avatars` | Traveller photos | Yes |
| `global_documents` | Global travel documents | No |

### 8.3 Key Queries

```typescript
// Trip list with counts
const { data: trips } = await supabase
  .from('trips')
  .select(`
    *,
    transport_count:trip_items(count).filter(type.eq.transport),
    stay_count:trip_items(count).filter(type.eq.stay),
    activity_count:trip_items(count).filter(type.eq.activity)
  `)
  .eq('archived', false)
  .order('created_at', { ascending: false })

// Timeline items with details
const { data: items } = await supabase
  .from('trip_items')
  .select(`
    *,
    transport_items(*),
    stay_items(*),
    activity_items(*),
    documents(count)
  `)
  .eq('trip_id', tripId)
  .order('day_index')
  .order('sort_index')
```

### 8.4 Generated Types

Generate TypeScript types from Supabase schema:

```bash
npx supabase gen types typescript --project-id <project-id> > types/database.ts
```

---

## 9. Risks & Considerations

### 9.1 Technical Risks

| Risk | Mitigation |
|------|------------|
| **Timezone complexity** | Use date-fns-tz, store UTC, display with localTz |
| **Large timeline performance** | Consider virtualization for 300+ items |
| **File upload failures** | Chunked uploads, retry logic, progress feedback |
| **RLS policy mismatches** | Test all queries against existing policies |
| **Google Places API costs** | Debounce autocomplete, cache responses |

### 9.2 UX Considerations

| Consideration | Approach |
|---------------|----------|
| **Mobile web experience** | Responsive design, but optimize for desktop |
| **Form complexity** | Progressive disclosure, smart defaults |
| **Data entry efficiency** | Autocomplete, paste support, keyboard nav |
| **Offline support** | Out of scope for v1, note for future |

### 9.3 Data Considerations

| Consideration | Approach |
|---------------|----------|
| **Existing mobile data** | Read-only compatibility, same schema |
| **Currency handling** | Store as-is, display conversion later |
| **Date parsing** | Robust parsing for various input formats |

---

## 10. Left for Later

Features explicitly deferred from Web v1:

| Feature | Reason |
|---------|--------|
| **Push Notifications** | Browser notifications less useful than mobile |
| **Offline Mode** | Adds significant complexity |
| **Email Itinerary Parsing** | Requires ML/API integration |
| **Collaborative Trips** | Schema supports it but UX not designed |
| **Calendar Sync (Google/Apple)** | OAuth complexity |
| **Mobile Web PWA** | Focus on desktop experience first |
| **Advanced Expense Charts** | Phase 2 enhancement |
| **Drag-drop Timeline Reorder** | Phase 2 enhancement |
| **PDF Export** | Phase 2 enhancement |
| **Keyboard Shortcuts** | Phase 2 enhancement |
| **Real-time Collaboration** | Requires Supabase Realtime setup |

---

## Summary

This plan provides a comprehensive roadmap for building Waydeck Web v1:

- **6 phases** over approximately 12 weeks
- **Full parity** with mobile (v1 + V2 + V3)
- **20+ routes** covering all features
- **Shared Supabase backend** with existing RLS policies
- **Modern stack**: Next.js 14, TypeScript, Tailwind, shadcn/ui

The web app will complement the mobile experience while leveraging web-specific advantages like larger screens, keyboard interaction, and easier content management.

---

*End of Waydeck Web v1 Implementation Plan*
