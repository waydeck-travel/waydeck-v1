# Waydeck Web – QA Test Plan

> **Version:** 1.0  
> **Created:** 2025-12-15  
> **Target:** Waydeck Web v1 (`waydeck-v1/web/`)  
> **Based on:** `qa-test-plan.md`, `waydeck-v1.1-qa-plan.md`, `waydeck-web-v1-plan.md`

---

## Table of Contents

1. [Overview](#1-overview)
2. [Manual Test Cases](#2-manual-test-cases)
3. [Automated Test Recommendations](#3-automated-test-recommendations)

---

## 1. Overview

### 1.1 Scope

This test plan covers manual and automated testing for the Waydeck Web application, ensuring feature parity with mobile and web-specific functionality.

| Priority | Area | Description |
|----------|------|-------------|
| **P0** | Authentication | Sign up, sign in, sign out, session persistence, redirects |
| **P0** | Trips | List, create, edit, archive, delete |
| **P0** | Trip Items | Transport, Stay, Activity, Note CRUD |
| **P0** | Documents | Upload, view, delete |
| **P1** | Timeline | Day grouping, layover calculation, icons/chips |
| **P1** | Travellers & Profile | Add/edit travellers, "Me" as passenger |
| **P1** | Checklists | Trip checklists, global templates |
| **P2** | Expenses & Budgets | Add expenses, budget views |
| **P2** | Landing & Marketing | Public pages, CTAs |

### 1.2 Supported Browsers

| Browser | Platform | Priority |
|---------|----------|----------|
| Chrome | Desktop (macOS, Windows) | P0 |
| Safari | Desktop (macOS) | P0 |
| Chrome | Mobile (Responsive/DevTools) | P1 |
| Safari | Mobile (Responsive/DevTools) | P1 |
| Firefox | Desktop | P2 |
| Edge | Desktop | P2 |

---

## 2. Manual Test Cases

### 2.1 Authentication

#### TC-WEB-AUTH-001: Sign Up (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/` (not logged in) | Landing page displays |
| 2 | Click "Get Started" or "Sign Up" | Navigate to `/auth/sign-up` |
| 3 | Enter valid email, password, confirm password | Fields accept input |
| 4 | Click "Create Account" | Loading state shows |
| 5 | After success | Redirect to `/app/trips` |

**Negative Cases:**
- Empty email → Validation error
- Invalid email format → Validation error
- Password < 6 characters → Validation error
- Mismatched passwords → Validation error
- Existing email → Error toast "User already exists"

---

#### TC-WEB-AUTH-002: Sign In (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/auth/sign-in` | Sign in form displays |
| 2 | Enter valid email and password | Fields accept input |
| 3 | Click "Sign In" | Loading state shows |
| 4 | After success | Redirect to `/app/trips` |

**Negative Cases:**
- Wrong password → Error toast "Invalid credentials"
- Non-existent email → Error toast

---

#### TC-WEB-AUTH-003: Session Persistence (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Sign in successfully | Redirect to `/app/trips` |
| 2 | Close browser tab | Tab closes |
| 3 | Open new tab, navigate to `/app/trips` | Directly loads trip list (no sign-in) |
| 4 | Clear cookies | Cookies cleared |
| 5 | Navigate to `/app/trips` | Redirect to `/auth/sign-in` |

---

#### TC-WEB-AUTH-004: Sign Out (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Click profile/settings | Profile page opens |
| 2 | Click "Sign Out" | Confirmation or immediate sign out |
| 3 | After sign out | Redirect to `/` or `/auth/sign-in` |
| 4 | Navigate to `/app/trips` | Redirect to `/auth/sign-in` |

---

#### TC-WEB-AUTH-005: Auth Route Redirects (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | While logged in, navigate to `/auth/sign-in` | Redirect to `/app/trips` |
| 2 | While logged in, navigate to `/auth/sign-up` | Redirect to `/app/trips` |
| 3 | While logged out, navigate to `/app/trips` | Redirect to `/auth/sign-in` |
| 4 | While logged out, navigate to `/app/profile` | Redirect to `/auth/sign-in` |

---

#### TC-WEB-AUTH-006: Password Reset (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/auth/sign-in` | Sign in page displays |
| 2 | Click "Forgot password?" | Navigate to `/auth/forgot-password` |
| 3 | Enter email, click submit | Success message shows |
| 4 | Check email for reset link | Email received (Supabase magic link) |

---

### 2.2 Trip Management

#### TC-WEB-TRIP-001: View Trip List (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Sign in and navigate to `/app/trips` | Trip list page loads |
| 2 | Observe trip cards | Each card shows: name, origin, dates, item counts |
| 3 | Verify sorting | Most recent trips at top |

**Empty State:**
- New user with no trips → Show "No trips yet" illustration + "Create Trip" button

---

#### TC-WEB-TRIP-002: Create Trip (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Click "New Trip" button | Create trip form opens |
| 2 | Enter name: "Vietnam 2025" | Field accepts input |
| 3 | Enter origin city: "Pune" | Field accepts input (Google Places autocomplete if enabled) |
| 4 | Select start date: 1 Dec 2025 | Date picker works |
| 5 | Select end date: 15 Dec 2025 | Date picker works |
| 6 | Click "Create" or "Save" | Redirect to trip overview or trip list |
| 7 | Verify trip appears in list | Trip card visible |

**Validation:**
- Empty name → Error "Trip name is required"
- End date before start date → Error "End date must be after start date"

---

#### TC-WEB-TRIP-003: Edit Trip (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to trip overview `/app/trips/[tripId]` | Overview loads |
| 2 | Click edit button | Edit form opens |
| 3 | Change name to "Southeast Asia 2025" | Field updates |
| 4 | Save changes | Redirect back, name updated |

---

#### TC-WEB-TRIP-004: Archive Trip (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | On trip card or overview, click overflow menu | Menu appears |
| 2 | Click "Archive" | Confirmation dialog |
| 3 | Confirm | Trip removed from active list |

---

#### TC-WEB-TRIP-005: Delete Trip (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | On trip overview, click overflow menu | Menu appears |
| 2 | Click "Delete" | Confirmation dialog with warning |
| 3 | Confirm | Redirect to trip list, trip removed |

---

### 2.3 Trip Overview & Timeline

#### TC-WEB-TL-001: View Trip Overview (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/app/trips/[tripId]` | Overview page loads |
| 2 | Observe summary card | Shows: name, origin, dates, item counts |
| 3 | Observe cities chips | Shows cities from trip items (deduplicated) |
| 4 | Observe timeline | Items grouped by day |

---

#### TC-WEB-TL-002: Timeline Day Grouping (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Add items across multiple days | Items created |
| 2 | View timeline | Day headers visible (e.g., "Sun, 1 Dec 2025") |
| 3 | Verify sorting within day | Items sorted by start time |

---

#### TC-WEB-TL-003: Layover Calculation (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Create Flight: PNQ → BOM, arrival 09:00 | Flight added |
| 2 | Create Flight: BOM → BKK, departure 13:30 | Flight added |
| 3 | View timeline | "Layover: 4h 30m at BOM" chip between flights |

**Edge Cases:**
- Flights to different cities → No layover shown
- Same city but > 24h gap → No layover (or labeled differently)

---

#### TC-WEB-TL-004: Timeline Item Icons & Chips (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Add various item types | Items created |
| 2 | View timeline | Transport shows mode icon (✈, 🚂, 🚌, etc.) |
| 3 | Stay with breakfast | Shows "Breakfast" badge |
| 4 | Item with document | Shows "Ticket" or "Document" badge |

---

### 2.4 Trip Items CRUD

#### TC-WEB-ITEM-001: Add Transport Item (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | On trip overview, click "Add Item" | Item type selector opens |
| 2 | Select "Transport" | Transport form opens |
| 3 | Select mode: Flight | Mode-specific fields appear |
| 4 | Enter: carrier "IndiGo", code "6E", number "5102" | Fields accept input |
| 5 | Enter origin: "Pune" (PNQ), destination: "Mumbai" (BOM) | Fields accept input |
| 6 | Set departure: 1 Dec 2025, 08:00 | Date/time picker works |
| 7 | Set arrival: 1 Dec 2025, 09:15 | Date/time picker works |
| 8 | Set passengers: 2 | Number field works |
| 9 | Click "Save" | Item appears in timeline |

---

#### TC-WEB-ITEM-002: Add Stay Item (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Add Item → Stay | Stay form opens |
| 2 | Enter name: "Grand Mercure Da Nang" | Field accepts input (autocomplete if enabled) |
| 3 | Enter address, city: "Da Nang", country | Fields accept input |
| 4 | Set check-in: 2 Dec 2025, 14:00 | Date/time picker works |
| 5 | Set check-out: 5 Dec 2025, 11:00 | Date/time picker works |
| 6 | Toggle "Breakfast included" ON | Checkbox works |
| 7 | Save | Item appears in timeline with breakfast badge |

---

#### TC-WEB-ITEM-003: Add Activity Item (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Add Item → Activity | Activity form opens |
| 2 | Enter name: "Ba Na Hills Day Tour" | Field accepts input |
| 3 | Enter category: "tour", city: "Da Nang" | Fields accept input |
| 4 | Set start/end times | Date/time picker works |
| 5 | Save | Item appears in timeline |

---

#### TC-WEB-ITEM-004: Add Note Item (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Add Item → Note | Note form opens |
| 2 | Enter title: "Buy SIM at BKK" | Field accepts input |
| 3 | Enter description | Multi-line text field works |
| 4 | Save | Item appears in timeline |

---

#### TC-WEB-ITEM-005: Edit Trip Item (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Click any item in timeline | Item detail page opens |
| 2 | Click "Edit" | Edit form opens with existing data |
| 3 | Make changes, save | Changes persisted |

---

#### TC-WEB-ITEM-006: Delete Trip Item (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | On item detail, click delete | Confirmation dialog |
| 2 | Confirm | Redirect to timeline, item removed |

---

#### TC-WEB-ITEM-007: Date/Time Validation (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Create transport with arrival before departure | Validation error |
| 2 | Create stay with checkout before checkin | Validation error |
| 3 | Create activity with end before start | Validation error |

---

### 2.5 Documents

#### TC-WEB-DOC-001: Upload Document to Trip (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to trip documents section | Documents grid visible |
| 2 | Click "Upload Document" | File picker opens |
| 3 | Select PDF file | Upload progress shows |
| 4 | After upload | Document thumbnail appears |

---

#### TC-WEB-DOC-002: Upload Document to Item (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open item detail (e.g., transport) | Detail page loads |
| 2 | Click "Add Document" or upload area | File picker opens |
| 3 | Select image file | Upload succeeds |
| 4 | Document appears in item | Document thumbnail shows |

---

#### TC-WEB-DOC-003: View Document (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Click document thumbnail | Document viewer opens |
| 2 | View PDF | In-browser PDF viewer shows content |
| 3 | View image | Image displays at full resolution |
| 4 | Close viewer | Return to previous page |

---

#### TC-WEB-DOC-004: Delete Document (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Click delete on document | Confirmation dialog |
| 2 | Confirm | Document removed from grid, storage cleaned |

---

### 2.6 Travellers & Profile

#### TC-WEB-TRAV-001: Add Traveller (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/app/travellers` | Traveller list shows |
| 2 | Click "Add Traveller" | Form opens |
| 3 | Enter name, passport number, expiry, nationality | Fields accept input |
| 4 | Save | Traveller appears in list |

---

#### TC-WEB-TRAV-002: "Me" as Traveller (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Edit profile at `/app/profile/edit` | Profile form opens |
| 2 | Fill passport, nationality, phone | Fields accept input |
| 3 | Save | Profile updated |
| 4 | Create transport, open passenger picker | "Me" appears at top |
| 5 | Select "Me" | Profile data associated |

---

#### TC-WEB-TRAV-003: Add Traveller from Picker (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | In transport form, open passenger picker | Picker opens |
| 2 | Click "+ Add New Traveller" | Navigate to traveller form |
| 3 | Fill form and save | Navigate back to picker, new traveller selected |

**Critical:** Must not hang on loader (bug fix from mobile v1.1)

---

### 2.7 Checklists

#### TC-WEB-CHECK-001: Trip Checklist (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/app/trips/[tripId]/checklist` | Checklist page loads |
| 2 | Add new item: "Pack sunscreen" | Item appears in list |
| 3 | Toggle item complete | Checkbox updates, progress bar changes |
| 4 | Leave and return | State persisted |

---

#### TC-WEB-CHECK-002: Global Checklist Templates (P2)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/app/checklists` | Templates list shows |
| 2 | Create new template: "Beach Pack" | Template created |
| 3 | Add items to template | Items saved |
| 4 | Go to trip checklist, click "Import" | Import dialog opens |
| 5 | Select template, import | Items copied to trip checklist |

---

### 2.8 Expenses & Budgets

#### TC-WEB-EXP-001: Add Expense to Item (P2)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Edit transport item | Form opens |
| 2 | Scroll to Expense section | Expense fields visible |
| 3 | Enter amount: 15000, currency: INR, status: Paid | Fields accept input |
| 4 | Save | Item shows expense badge in timeline |

---

#### TC-WEB-EXP-002: Trip Expense Summary (P2)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/app/trips/[tripId]/expenses` | Expense summary loads |
| 2 | View totals by category | Transport, Stays, Activities sections |
| 3 | View item breakdown | Individual expenses listed |

---

#### TC-WEB-EXP-003: Budget vs Actuals (P2)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/app/trips/[tripId]/budget` | Budget page loads |
| 2 | Set transport budget: 20000 | Budget saved |
| 3 | View bar | Shows usage (spent/budget percentage) |
| 4 | Exceed budget | Bar turns red/warning |

---

### 2.9 Landing & Marketing Pages

#### TC-WEB-LAND-001: Landing Page (P0)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/` (logged out) | Landing page displays |
| 2 | Verify content | Hero, features list, screenshots visible |
| 3 | Click "Sign In" | Navigate to `/auth/sign-in` |
| 4 | Click "Get Started" | Navigate to `/auth/sign-up` |

---

#### TC-WEB-LAND-002: Landing Redirect When Logged In (P1)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Sign in | On `/app/trips` |
| 2 | Navigate to `/` | Either shows landing or redirects to `/app/trips` |

---

#### TC-WEB-LAND-003: About & How It Works (P2)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/about` | About page displays |
| 2 | Navigate to `/how-it-works` | How It Works page displays |
| 3 | Verify content and links | Content renders, links work |

---

## 3. Automated Test Recommendations

### 3.1 Testing Framework Setup

**Recommended Stack:**

| Tool | Purpose |
|------|---------|
| **Vitest** | Unit and component tests (fast, ESM-native) |
| **React Testing Library** | Component testing |
| **Playwright** | E2E browser tests |
| **MSW (Mock Service Worker)** | API mocking for isolated tests |

**Installation:**

```bash
cd waydeck-v1/web
npm install -D vitest @testing-library/react @testing-library/jest-dom jsdom
npm install -D @playwright/test msw@latest
```

---

### 3.2 Unit Tests

#### Date Validation Logic

**File:** `__tests__/lib/dates.test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import { validateDateRange, formatDate, parseLocalDate } from '@/lib/dates';

describe('validateDateRange', () => {
  it('returns true when end date is after start date', () => {
    const start = new Date('2025-12-01');
    const end = new Date('2025-12-15');
    expect(validateDateRange(start, end)).toBe(true);
  });

  it('returns false when end date is before start date', () => {
    const start = new Date('2025-12-15');
    const end = new Date('2025-12-01');
    expect(validateDateRange(start, end)).toBe(false);
  });

  it('returns true when dates are the same', () => {
    const date = new Date('2025-12-01');
    expect(validateDateRange(date, date)).toBe(true);
  });
});

describe('formatDate', () => {
  it('formats date correctly', () => {
    const date = new Date('2025-12-01');
    expect(formatDate(date)).toMatch(/Dec 1, 2025|1 Dec 2025/);
  });
});
```

#### Layover Computation

**File:** `__tests__/lib/timeline.test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import { computeLayover, buildTimelineGroups } from '@/lib/timeline';

describe('computeLayover', () => {
  it('calculates layover duration correctly', () => {
    const arrival = new Date('2025-12-01T09:00:00Z');
    const departure = new Date('2025-12-01T13:30:00Z');
    const layover = computeLayover(arrival, departure);
    expect(layover.hours).toBe(4);
    expect(layover.minutes).toBe(30);
  });

  it('returns null for negative duration', () => {
    const arrival = new Date('2025-12-01T14:00:00Z');
    const departure = new Date('2025-12-01T13:00:00Z');
    expect(computeLayover(arrival, departure)).toBeNull();
  });

  it('returns null for durations > 24 hours', () => {
    const arrival = new Date('2025-12-01T09:00:00Z');
    const departure = new Date('2025-12-03T13:00:00Z');
    expect(computeLayover(arrival, departure)).toBeNull();
  });
});

describe('buildTimelineGroups', () => {
  it('groups items by day', () => {
    const items = [
      { id: '1', start_time_utc: '2025-12-01T08:00:00Z', type: 'transport' },
      { id: '2', start_time_utc: '2025-12-01T14:00:00Z', type: 'stay' },
      { id: '3', start_time_utc: '2025-12-02T09:00:00Z', type: 'activity' },
    ];
    const groups = buildTimelineGroups(items);
    expect(groups.length).toBe(2); // 2 days
    expect(groups[0].items.length).toBe(2); // 2 items on day 1
  });

  it('handles empty input', () => {
    expect(buildTimelineGroups([])).toEqual([]);
  });
});
```

#### Expense Aggregation

**File:** `__tests__/lib/expenses.test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import { aggregateExpenses, isOverBudget, calculateBudgetProgress } from '@/lib/expenses';

describe('aggregateExpenses', () => {
  it('aggregates expenses by category', () => {
    const items = [
      { type: 'transport', expense_amount: 15000 },
      { type: 'transport', expense_amount: 5000 },
      { type: 'stay', expense_amount: 25000 },
    ];
    const totals = aggregateExpenses(items);
    expect(totals.transport).toBe(20000);
    expect(totals.stay).toBe(25000);
  });
});

describe('isOverBudget', () => {
  it('returns true when spent exceeds budget', () => {
    expect(isOverBudget(110, 100)).toBe(true);
  });

  it('returns false when under budget', () => {
    expect(isOverBudget(80, 100)).toBe(false);
  });
});

describe('calculateBudgetProgress', () => {
  it('calculates percentage correctly', () => {
    expect(calculateBudgetProgress(75, 100)).toBe(75);
    expect(calculateBudgetProgress(120, 100)).toBe(120);
  });

  it('handles zero budget', () => {
    expect(calculateBudgetProgress(50, 0)).toBe(0);
  });
});
```

#### City/Airport Parsing Logic

**File:** `__tests__/lib/places.test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import { extractCityFromAirport, deduplicateCities } from '@/lib/places';

describe('extractCityFromAirport', () => {
  it('extracts city from airport name with code', () => {
    expect(extractCityFromAirport('London Heathrow Airport (LHR)')).toBe('London');
  });

  it('extracts city from simple airport name', () => {
    expect(extractCityFromAirport('Chhatrapati Shivaji International Airport')).toBe('Mumbai');
  });
});

describe('deduplicateCities', () => {
  it('removes duplicate city names', () => {
    const cities = ['London', 'Paris', 'London', 'Berlin', 'Paris'];
    expect(deduplicateCities(cities)).toEqual(['London', 'Paris', 'Berlin']);
  });
});
```

---

### 3.3 Component Tests

#### Trip List Component

**File:** `__tests__/components/trips/trip-list.test.tsx`

```typescript
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { TripList } from '@/components/trips/trip-list';

describe('TripList', () => {
  it('renders trip cards', () => {
    const trips = [
      { id: '1', name: 'Vietnam 2025', origin_city: 'Pune', transport_count: 3, stay_count: 2 },
      { id: '2', name: 'Weekend Trip', origin_city: 'Mumbai', transport_count: 1, stay_count: 1 },
    ];
    render(<TripList trips={trips} />);
    expect(screen.getByText('Vietnam 2025')).toBeInTheDocument();
    expect(screen.getByText('Weekend Trip')).toBeInTheDocument();
  });

  it('shows empty state when no trips', () => {
    render(<TripList trips={[]} />);
    expect(screen.getByText(/no trips/i)).toBeInTheDocument();
  });
});
```

#### Timeline Component

**File:** `__tests__/components/timeline/timeline.test.tsx`

```typescript
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Timeline } from '@/components/timeline/timeline';

describe('Timeline', () => {
  it('renders day headers', () => {
    const groups = [
      {
        date: '2025-12-01',
        dateLabel: 'Sun, 1 Dec 2025',
        items: [{ id: '1', title: 'Flight BOM → BKK', type: 'transport' }],
      },
    ];
    render(<Timeline groups={groups} />);
    expect(screen.getByText('Sun, 1 Dec 2025')).toBeInTheDocument();
  });

  it('renders layover chip between transports', () => {
    const groups = [
      {
        date: '2025-12-01',
        dateLabel: 'Sun, 1 Dec 2025',
        items: [
          { id: '1', title: 'Flight A', type: 'transport' },
          { id: 'layover-1', isLayover: true, duration: '4h 30m', location: 'BOM' },
          { id: '2', title: 'Flight B', type: 'transport' },
        ],
      },
    ];
    render(<Timeline groups={groups} />);
    expect(screen.getByText(/4h 30m/)).toBeInTheDocument();
  });
});
```

#### Trip Item Forms

**File:** `__tests__/components/forms/transport-form.test.tsx`

```typescript
import { describe, it, expect } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { TransportForm } from '@/components/forms/transport-form';

describe('TransportForm', () => {
  it('shows flight-specific fields when flight mode selected', () => {
    render(<TransportForm tripId="test" />);
    fireEvent.click(screen.getByText('Flight'));
    expect(screen.getByLabelText(/airline/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/flight number/i)).toBeInTheDocument();
  });

  it('validates required fields', async () => {
    render(<TransportForm tripId="test" />);
    fireEvent.click(screen.getByText('Save'));
    expect(await screen.findByText(/required/i)).toBeInTheDocument();
  });
});
```

#### Checklist Component

**File:** `__tests__/components/checklist/checklist.test.tsx`

```typescript
import { describe, it, expect } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { Checklist } from '@/components/checklist/checklist';

describe('Checklist', () => {
  it('renders items with checkboxes', () => {
    const items = [
      { id: '1', title: 'Pack passport', is_completed: false },
      { id: '2', title: 'Book hotel', is_completed: true },
    ];
    render(<Checklist items={items} onToggle={() => {}} />);
    expect(screen.getByText('Pack passport')).toBeInTheDocument();
    expect(screen.getByText('Book hotel')).toBeInTheDocument();
  });

  it('calls onToggle when checkbox clicked', () => {
    const onToggle = vi.fn();
    const items = [{ id: '1', title: 'Pack passport', is_completed: false }];
    render(<Checklist items={items} onToggle={onToggle} />);
    fireEvent.click(screen.getByRole('checkbox'));
    expect(onToggle).toHaveBeenCalledWith('1', true);
  });
});
```

---

### 3.4 E2E Tests (Playwright)

#### Setup

**File:** `playwright.config.ts`

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'safari', use: { ...devices['Desktop Safari'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

#### Auth E2E

**File:** `e2e/auth.spec.ts`

```typescript
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('sign in → see trips', async ({ page }) => {
    await page.goto('/auth/sign-in');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/app/trips');
    await expect(page.getByText('My Trips')).toBeVisible();
  });

  test('protected routes redirect to sign-in', async ({ page }) => {
    await page.goto('/app/trips');
    await expect(page).toHaveURL(/\/auth\/sign-in/);
  });
});
```

#### Core Journey E2E

**File:** `e2e/trip-journey.spec.ts`

```typescript
import { test, expect } from '@playwright/test';

test.describe('Core Trip Journey', () => {
  test.beforeEach(async ({ page }) => {
    // Sign in programmatically
    await page.goto('/auth/sign-in');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/app/trips');
  });

  test('create trip → add transport → add stay → view timeline', async ({ page }) => {
    // Create trip
    await page.click('text=New Trip');
    await page.fill('[name="name"]', 'E2E Test Trip');
    await page.fill('[name="origin_city"]', 'Pune');
    await page.click('button[type="submit"]');

    // Add transport
    await page.click('text=Add Item');
    await page.click('text=Transport');
    await page.click('text=Flight');
    await page.fill('[name="carrier_name"]', 'IndiGo');
    await page.fill('[name="origin_city"]', 'Mumbai');
    await page.fill('[name="destination_city"]', 'Bangkok');
    await page.click('button[type="submit"]');

    // Verify timeline
    await expect(page.getByText('IndiGo')).toBeVisible();
    await expect(page.getByText('BOM → BKK')).toBeVisible();
  });
});
```

#### Expense E2E

**File:** `e2e/expenses.spec.ts`

```typescript
import { test, expect } from '@playwright/test';

test.describe('Expenses', () => {
  test('add expense → verify totals', async ({ page }) => {
    // Navigate to existing trip
    await page.goto('/app/trips/test-trip-id');
    
    // Edit transport to add expense
    await page.click('text=Flight BOM → BKK');
    await page.click('text=Edit');
    await page.fill('[name="expense_amount"]', '15000');
    await page.selectOption('[name="expense_currency"]', 'INR');
    await page.click('button[type="submit"]');

    // Check expense summary
    await page.click('text=Expenses');
    await expect(page.getByText('₹15,000')).toBeVisible();
    await expect(page.getByText('Transport')).toBeVisible();
  });
});
```

---

### 3.5 CI Integration

**File:** `.github/workflows/web-ci.yml`

```yaml
name: Web CI

on:
  push:
    branches: [main, develop]
    paths:
      - 'web/**'
  pull_request:
    branches: [main, develop]
    paths:
      - 'web/**'

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: web

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: web/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Create .env.local
        run: |
          echo "NEXT_PUBLIC_SUPABASE_URL=${{ secrets.SUPABASE_URL }}" > .env.local
          echo "NEXT_PUBLIC_SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}" >> .env.local

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npx tsc --noEmit

      - name: Unit tests
        run: npm run test:unit

      - name: Build
        run: npm run build

  e2e:
    runs-on: ubuntu-latest
    needs: test
    defaults:
      run:
        working-directory: web

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run E2E tests
        run: npm run test:e2e
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: web/playwright-report/
```

---

### 3.6 Test File Naming Convention

| Type | Location | Naming |
|------|----------|--------|
| Unit tests | `__tests__/lib/` | `*.test.ts` |
| Component tests | `__tests__/components/` | `*.test.tsx` |
| E2E tests | `e2e/` | `*.spec.ts` |

**package.json scripts:**

```json
{
  "scripts": {
    "test": "vitest",
    "test:unit": "vitest run",
    "test:watch": "vitest watch",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```

---

## Summary

This QA plan covers:

- **45+ manual test cases** across all major areas
- **Unit tests** for date validation, layover computation, expense aggregation, city parsing
- **Component tests** for trip list, timeline, forms, checklists
- **E2E tests** for auth, core journey, and expenses
- **CI integration** with GitHub Actions

**Priority Focus:**
1. P0: Auth, Trips CRUD, Trip Items CRUD, Documents (blocking issues)
2. P1: Timeline, Travellers, Checklists (important UX)
3. P2: Expenses, Budgets, Marketing pages (nice-to-have)

---

*End of Web QA Test Plan*
