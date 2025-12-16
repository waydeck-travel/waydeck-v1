# Waydeck v1.1 – QA & Regression + Production-Readiness Plan

> **Version:** 1.0  
> **Target Release:** Waydeck v1.1  
> **Based on:** `waydeck-spec.md` (v1) and `waydeck-v1.1-spec-addendum.md`

---

## 1. Waydeck v1.1 – Test Strategy

### 1.1 Scope

The QA scope for the v1.1 release encompasses the validation of the core foundation (Regression) and the verification of all new enhancements (New Features).

*   **Core v1 Flows (Regression Focus):**
    *   **Authentication:** Sign up, Sign in, Sign out, Session persistence.
    *   **Trip Management:** CRUD operations for trips.
    *   **Trip Items:** Transport, Stay, Activity, Note CRUD; formatting and timeline logic.
    *   **Documents:** Basic upload and attachment to trips/items.
    *   **Checklists:** Basic per-trip checklist functionality.

*   **v1.1 Additions (New Feature Validation):**
    *   **Travel Identity:** Profile updates, "Me" passenger, Traveller management.
    *   **Financials:** Expenses tracking (paid/partial/unpaid), Budget setting vs. Actuals.
    *   **Global Assets:** Global Documents (Passport/Visa), Global Checklist Templates.
    *   **UX/UI Overhaul:** Theming (Dark Mode), Google Places Integration (Airports/Cities), Icon refresh, Landing Page.
    *   **Integration:** Notifications, Sharing (WhatsApp/Link).

### 1.2 Test Levels

1.  **Unit Tests:**
    *   Focus on business logic isolated from UI and Backend.
    *   *Examples:* Date validation logic, expense totals calculation, layover computation, budget progress percentage.
2.  **Widget/Component Tests:**
    *   Focus on individual reusable UI components and screen interactions.
    *   *Examples:* Passenger picker behavior, checklist item toggling, theme switching rendering, empty state displays.
3.  **Integration Tests:**
    *   Focus on the interaction between Repositories and `supabase_flutter` (mocked or real dev instance).
    *   *Examples:* Fetching trips returns correct object structure, data persistence respects RLS.
4.  **End-to-End (E2E) / Manual Tests:**
    *   Full user flows on real devices/simulators.
    *   *Examples:* "Create a trip from scratch, add a flight with expense, upload a ticket, and share it."

### 1.3 Supported Platforms

*   **iOS:** Minimum iOS 14.0 (Recommended for Flutter).
*   **Android:** Minimum Android 8.0 (Oreo, API 26).

### 1.4 Environments

*   **Dev/Staging:** Using the development Supabase project (for all destructive testing and new feature verification).
*   **Production:** Using the production Supabase project (Smoke tests only post-release).

---

## 2. Waydeck v1.1 – Test Plan

### 2.1 Core Flows (Regression)

These tests ensure previously working features remain stable.

| ID | Flow | Objective | Test Steps | Expected Result | Priority |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **R01** | **Auth - Sign In** | Verify user can log in and session persists. | 1. Launch app.<br>2. Enter valid email/password.<br>3. Tap Sign In.<br>4. Restart app. | User lands on Trip List. After restart, user remains logged in (no login screen). | **P0** |
| **R02** | **Trip - CRUD** | Verify trip lifecycle. | 1. Create Trip "Test Trip" with dates.<br>2. Edit Trip name to "Renamed Trip".<br>3. Delete/Archive Trip. | Trip appears in list. Renaming reflects immediately. Deleted trip is removed from list. | **P0** |
| **R03** | **Timeline - Add Transport** | Verify transport item creation and display. | 1. Add Flight: BOM->BKK.<br>2. Set times ensuring BKK arrival is after BOM dep.<br>3. Save. | Flight appears on timeline in correct date group. Computed layover shows if applicable. | **P0** |
| **R04** | **Timeline - stay/Activity** | Verify non-transport items. | 1. Add Hotel (Stay) and Tour (Activity).<br>2. Verify sorting on timeline. | Items sort by time within the correct day. City chips update in header. | **P1** |
| **R05** | **Trip - Empty State** | Verify UX when no data exists. | 1. Create new account (no trips). | **[v1.1 Updated]** User sees new illustration + "Create Your First Trip" button. | **P1** |
| **R06** | **Checklist - Basic** | Verify item state. | 1. Create checklist item.<br>2. Toggle done.<br>3. Leave screen and return. | Item remains checked. Progress bar updates. | **P1** |
| **R07** | **Documents - Upload** | Verify file attachment. | 1. Open Trip Item.<br>2. Attach image/PDF.<br>3. Tap to view. | File uploads successfully. Tapping opens viewer. | **P0** |

### 2.2 New v1.1 Features

#### 1. Profile & Travellers

*   **TC_1.1.1 Edit My Profile**
    *   *Steps:* Go to Settings > Profile. Fill in Passport, Nationality, Phone. Save. Re-open.
    *   *Expected:* Data persists. Avatar is visible.
*   **TC_1.1.2 Add "Me" as Passenger**
    *   *Steps:* Create Flight. Tap "Select Passengers". Select pinned "Me" option. Save.
    *   *Expected:* Transport item shows "1 Passenger" (User's name).
*   **TC_1.1.3 Add New Traveller via Picker**
    *   *Steps:* In Passenger Picker, tap "+ Add New". Fill form "Jane Doe". Save.
    *   *Expected:* User returned to Picker. "Jane Doe" is auto-selected.

#### 2. Theming & Icons

*   **TC_1.2.1 Theme Switching**
    *   *Steps:* Go to Settings > Theme. Toggle between Light, Dark, and System.
    *   *Expected:* UI colors update instantly. "Dark" shows dark backgrounds (#121212). Preference persists after restart.
*   **TC_1.2.2 Icon Consistency**
    *   *Steps:* Browse Timeline items (Flight, Train, Hotel).
    *   *Expected:* All icons use the new outlined modern style (Material Symbols/Phosphor). No mixed emojis.

#### 3. Expenses & Budgets

*   **TC_1.3.1 Add Expense to Item**
    *   *Steps:* Edit a Flight. Scroll to Expense. Enter "15000 INR", "Paid", "Card". Save.
    *   *Expected:* Timeline card shows "💰 15000" badge.
*   **TC_1.3.2 Budget vs Actuals**
    *   *Steps:* Go to Trip > Budget. Set Transport Budget = 20000.
    *   *Expected:* Bar shows usage (15000/20000 = 75%). Green color.
*   **TC_1.3.3 Over-Budget Behavior**
    *   *Steps:* Add another transport expense of 10000 (Total 25000).
    *   *Expected:* Budget bar turns Red/Warning. Progress > 100%.

#### 4. Global Documents & Checklist

*   **TC_1.4.1 Global Document Management**
    *   *Steps:* Settings > My Documents. Upload Passport PDF. Go to a Trip > Documents.
    *   *Expected:* Passport appears under "Global Documents" section (Read-only view).
*   **TC_1.4.2 Import Checklist Template**
    *   *Steps:* Settings > Checklists > Create "Beach Pack" (3 items). Go to Trip > Checklist > Import. Select "Beach Pack".
    *   *Expected:* The 3 items are added to the trip checklist. Modifying them in Trip does *not* affect the Global Template.

#### 5. Locations & Google Places

*   **TC_1.5.1 Airport Autocomplete**
    *   *Steps:* Add Transport. Type "Heathrow". Select "London Heathrow Airport".
    *   *Expected:* Airport Code field auto-fills "LHR". City auto-fills "London".
*   **TC_1.5.2 City Display Deduplication**
    *   *Steps:* Trip has flight to "London Heathrow (LHR)" and "London Gatwick (LGW)". check Trip Overview header.
    *   *Expected:* Shows "London" only (no duplicates, no "(LHR)" in city chip).

#### 6. Notifications

*   **TC_1.6.1 Permission & Test**
    *   *Steps:* Install fresh. Go to Settings. Tap "Test Notification".
    *   *Expected:* System prompt for permission (Allow). Local notification appears immediately ("Waydeck Test").

#### 7. Sharing

*   **TC_1.7.1 WhatsApp Share**
    *   *Steps:* Trip Overview > Share > WhatsApp.
    *   *Expected:* WhatsApp opens with pre-filled text summary ("Trip: India... Date...").
*   **TC_1.7.2 Copy Link**
    *   *Steps:* Trip Overview > Share > Copy Link.
    *   *Expected:* Toast "Link copied". Clipboard contains `waydeck://trip/<uuid>`.

#### 8. Landing Page

*   **TC_1.8.1 Pre-Auth Experience**
    *   *Steps:* Log out. Relaunch app.
    *   *Expected:* See Landing Page (Hero, Features, "Sign In" button). NOT the empty trip list.
    *   *Steps:* Tap "Sign In". Login.
    *   *Expected:* Navigate to Trip List. Relaunching app skips Landing Page.

### 2.3 Non-Functional Testing

*   **NF_01 Performance:** Scroll a timeline with 300+ items (mock data). Ensure 60fps scrolling and no memory leaks (images disposing).
*   **NF_02 Offline Launch:** Enable Airplane Mode. Launch app. Ensure last viewed trip is visible (cached).
*   **NF_03 Network Error Handling:** Try adding an item with flaky internet. Verify App shows "Retry" snackbar or graceful error, does not crash.

---

## 3. Automated Tests – Recommendations

### Unit Tests
*   `test/core/date_utils_test.dart`:
    *   `validates_end_after_start`: Assert `validateDateRange(start, end)` returns false if `end < start`.
    *   `calculates_layover`: Assert `computeLayover(arrivalA, depB)` returns correct Duration.
*   `test/features/expenses/expense_logic_test.dart`:
    *   `aggregates_totals_by_category`: Assert passing a list of Items returns correct `Map<Category, double>` totals.
    *   `calculates_budget_overflow`: Assert `isOverBudget(spent: 110, budget: 100)` is true.
*   `test/shared/parsers_test.dart`:
    *   `extracts_city_from_google_place`: Assert parsing Google Place JSON returns correct City/Country strings.

### Widget Tests
*   `test/features/checklist/checklist_screen_test.dart`:
    *   `toggling_item_updates_progress`: Tap CheckboxFinder -> Assert ProgressIndicator value changes.
    *   `import_dialog_shows_templates`: Open Import Dialog -> Assert list of templates is rendered.
*   `test/features/expenses/trip_expenses_screen_test.dart`:
    *   `renders_category_cards`: Pump screen with mock provider data -> Assert "Transport", "Stays" cards exist with correct amounts.
*   `test/features/landing/landing_page_test.dart`:
    *   `navigates_to_signin`: Tap "Sign In" button -> Verify navigation to `/auth/signin`.

### Integration Tests (E2E)
*   **Flow:** `create_trip_and_verify_persistence_test.dart`
    *   **Description:** Use `integration_test` package.
    *   **Assertions:**
        1.  Login programmatically (using Supabase Auth API).
        2.  Tap "Create Trip". Enter "Auto Test Trip". Save.
        3.  Verify "Auto Test Trip" exists in List.
        4.  Tap Trip. Add Transport "Flight".
        5.  Verify Timeline contains Flight.

---

## 4. Production-Readiness – QA Checklist

### 4.1 Features & Logic
- [ ] **Implementation Complete:** All items in `waydeck-v1.1-spec-addendum` are implemented.
- [ ] **Critical Flows Pass:** P0 tests in Core & New Features (Section 2) pass manually.
- [ ] **Empty States:** "No Trips", "No Checklist", "No Documents" screens look polished (no raw text).

### 4.2 Stability & Performance
- [ ] **No Crashes:** App does not crash on: Permissions Denied (Notifications/Photos), Network Timeout, Invalid Date inputs.
- [ ] **Offline Mode:** App opens and shows cached data without internet.
- [ ] **Image Caching:** Images in Timeline/Documents load and cache correctly; no flickering.

### 4.3 Platform Compliance
- [ ] **iOS:** Verified on iPhone (FaceID, Notch/Dynamic Island layout safe areas).
- [ ] **Android:** Verified on Android (Back button navigation works naturally).
- [ ] **Permissions:** "When in Use" / "Notification" permission dialogs show correct usage strings in `Info.plist` / `AndroidManifest`.

### 4.4 App Store / Metadata
- [ ] **App Icon:** Correct assets for all resolutions (no default Flutter icon).
- [ ] **Display Name:** "Waydeck" (not "waydeck_v1").
- [ ] **Strings:** No debug strings ("TODO", "Lorem Ipsum") visible in UI.
- [ ] **Version Number:** Bumped to `1.1.0` in `pubspec.yaml`.

### 4.5 Security
- [ ] **RLS:** Verified that User A cannot see User B's trips via Supabase (if possible to test via distinct logins).
- [ ] **API Keys:** Anon key is used; Service Role key is NOT in the app bundle.

---

## 5. Summary & Top Priorities

To declare Waydeck v1.1 **"Production Ready"**, the team must prioritize resolving the following top 5 risks/tasks:

1.  **Date Validation:** Ensure it is impossible to create "negative duration" trips or items (End < Start), as this breaks the Timeline logic.
2.  **Notification Permissions:** Handle the "Permission Denied" state gracefully on iOS/Android so the app doesn't silent-fail or crash when testing notifications.
3.  **Google Places Integration:** Verify `API_KEY` restrictions and billing; ensure the expensive Autocomplete API is debounced correctly to avoid quota spikes.
4.  **Offline Grace:** Ensure the app doesn't show a generic "Exception" red screen when opened in a tunnel/airplane mode; it should show cached content or a "No Connection" empty state.
5.  **Data Migration:** Since the schema changed (new `expenses`, `profiles` columns), verify that existing v1.0 users (if any) don't crash upon first launch. (Run migrations safely).
