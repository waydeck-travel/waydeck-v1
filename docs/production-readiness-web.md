# Waydeck Web – Production Readiness

> **Version:** 1.0  
> **Created:** 2025-12-15  
> **Target:** Waydeck Web v1 (`waydeck-v1/web/`)

---

## Table of Contents

1. [Security Assessment](#1-security-assessment)
2. [Performance Assessment](#2-performance-assessment)
3. [Production-Readiness Checklist](#3-production-readiness-checklist)

---

## 1. Security Assessment

### 1.1 Secrets & Keys

#### ✅ Current Status: GOOD

**Client-Side Environment Variables:**

The web app only exposes public keys intended for client-side use:

| Variable | Exposure | Purpose | Risk |
|----------|----------|---------|------|
| `NEXT_PUBLIC_SUPABASE_URL` | Client | Supabase project endpoint | ✅ Low - public info |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Client | Anonymous/public key for client auth | ✅ Low - designed to be public |
| `NEXT_PUBLIC_GOOGLE_PLACES_API_KEY` | Client (if used) | Google Places autocomplete | ⚠️ Medium - restrict to domain |

**Verified:**
- [x] No `SUPABASE_SERVICE_ROLE_KEY` in client code
- [x] No database passwords in repository
- [x] No admin endpoints exposing service role access
- [x] `.env.local` is in `.gitignore`
- [x] `.env.local.example` provided with placeholder values only

**Evidence from code review:**
```typescript
// src/lib/supabase/client.ts - SAFE
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!  // ✅ Anon key only
  );
}
```

#### Recommendations

1. **Google Places API Key Restrictions:**
   - Configure API key in Google Cloud Console with:
     - HTTP referrer restrictions: `waydeck.com/*`, `*.vercel.app/*`
     - API restrictions: Places API only
   - This prevents key abuse if exposed in client bundles

2. **Environment Variable Documentation:**
   - Create `DEPLOYMENT.md` listing all required env vars
   - For each variable, note whether it's public or private

---

### 1.2 Authentication & Authorization

#### ✅ Current Status: GOOD

**Middleware Protection:**

The web app uses Next.js middleware with Supabase SSR to protect routes:

```typescript
// middleware.ts
export async function middleware(request: NextRequest) {
  return await updateSession(request);
}

// src/lib/supabase/middleware.ts
const { data: { user } } = await supabase.auth.getUser();

// Redirect unauthenticated users from /app/* to /auth/sign-in
if (isAppRoute && !user) {
  return NextResponse.redirect('/auth/sign-in');
}

// Redirect authenticated users from /auth/* to /app/trips
if (isAuthRoute && user) {
  return NextResponse.redirect('/app/trips');
}
```

**Verified:**
- [x] All `/app/**` routes require authentication via middleware
- [x] Auth routes redirect authenticated users to avoid confusion
- [x] Session refresh handled by Supabase SSR cookies

**Server Actions Authentication:**

```typescript
// src/actions/trips.ts
export async function getTrips() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return [];  // ✅ Early return if not authenticated
  // ... rest of function uses RLS-protected queries
}
```

**Verified:**
- [x] All server actions check for authenticated user before queries
- [x] No routes bypass authentication for data access

---

### 1.3 Row Level Security (RLS)

#### ✅ Current Status: GOOD (Relies on Existing Policies)

The web app connects to the same Supabase project as the mobile app. All RLS policies are defined in the database:

| Table | RLS Policy | Verified |
|-------|------------|----------|
| `profiles` | User can manage their own profile | ✅ |
| `trips` | User can CRUD their own trips (`owner_id = auth.uid()`) | ✅ |
| `trip_items` | User can CRUD items in their own trips | ✅ |
| `transport_items` | User can manage transports in their own trips | ✅ |
| `stay_items` | User can manage stays in their own trips | ✅ |
| `activity_items` | User can manage activities in their own trips | ✅ |
| `documents` | User can manage their own documents (`owner_id = auth.uid()`) | ✅ |
| `checklist_items` | User can manage checklists in their own trips | ✅ |
| `travellers` | User can manage their own travellers | ✅ |

**Verified:**
- [x] Web app uses the same anon key as mobile
- [x] All queries go through Supabase client using anon key
- [x] No server actions use `supabase.auth.admin` or service role
- [x] No raw SQL queries bypassing RLS

#### Recommendations

1. **RLS Verification Test:**
   - Write integration tests that attempt cross-user data access
   - Example: Create two test users, User A should not see User B's trips

2. **Monitor RLS Policy Changes:**
   - Any schema migration should be reviewed for RLS impact
   - Document RLS policies in `docs/database-security.md`

---

### 1.4 File Uploads & Storage

#### ⚠️ Current Status: NEEDS VERIFICATION

**Storage Buckets (from spec):**

| Bucket | Purpose | Public Access |
|--------|---------|---------------|
| `trip_documents` | Trip and item attachments | ❌ Private |
| `traveller-avatars` | Profile photos | ✅ Public |
| `global_documents` | Passport, visa, etc. | ❌ Private |

**Upload Flow (from code review):**
```typescript
// src/actions/documents.ts
// Documents uploaded via Supabase Storage client
// Uses signed URLs for private buckets
```

#### Recommendations

1. **File Type Validation:**
   - **Current:** Need to verify client-side and server-side validation
   - **Recommended:** Accept only: `application/pdf`, `image/jpeg`, `image/png`, `image/webp`
   - **Implementation:**
     ```typescript
     const ALLOWED_TYPES = ['application/pdf', 'image/jpeg', 'image/png', 'image/webp'];
     if (!ALLOWED_TYPES.includes(file.type)) {
       throw new Error('Invalid file type');
     }
     ```

2. **File Size Limits:**
   - **Recommended:** 10MB per document, 5MB per avatar
   - **Implementation:** Validate in UI before upload, also set bucket policies

3. **Private Bucket Access:**
   - Verify `trip_documents` and `global_documents` use signed URLs (not public URLs)
   - Signed URLs should expire (e.g., 1 hour validity)
   - Example:
     ```typescript
     const { data } = await supabase.storage
       .from('trip_documents')
       .createSignedUrl(path, 3600); // 1 hour
     ```

4. **Storage RLS Policies:**
   - Verify storage policies match table RLS
   - Users should only access their own documents

---

### 1.5 Sharing

#### ✅ Current Status: ACCEPTABLE

**Current Implementation (from mobile spec):**
- Trip sharing generates a text summary (not a public link)
- Share content: Trip name, dates, item counts
- Uses device share sheet or clipboard

**Verified:**
- [x] No public trip URLs that bypass authentication
- [x] Share links are deep links (`waydeck://trip/{id}`) - require auth to view
- [x] No sensitive data (passport, PNR) in share summaries

#### Recommendations

1. **If implementing public share links:**
   - Use short-lived tokens, not UUIDs
   - Require opt-in from trip owner
   - Show only basic info (name, dates, cities)
   - Never expose: PNR, passport, document contents

---

### 1.6 Security Summary

| Area | Status | Priority |
|------|--------|----------|
| Secrets management | ✅ GOOD | - |
| Auth middleware | ✅ GOOD | - |
| RLS protection | ✅ GOOD | - |
| File type validation | ⚠️ VERIFY | P1 |
| File size limits | ⚠️ VERIFY | P1 |
| Private bucket access | ⚠️ VERIFY | P1 |
| Google API key restrictions | ⚠️ CONFIGURE | P2 |

---

## 2. Performance Assessment

### 2.1 Identified Performance Risks

#### Risk 1: N+1 Queries in Trip List

**Location:** `src/actions/trips.ts` → `getTrips()`

**Issue:** For each trip, 5 separate count queries are executed:
```typescript
const tripsWithCounts = await Promise.all(
  trips.map(async (trip) => {
    const [transportCount, stayCount, activityCount, noteCount, documentCount] =
      await Promise.all([
        // 5 queries per trip!
        supabase.from("trip_items").select("*", { count: "exact", head: true }).eq("trip_id", trip.id).eq("type", "transport"),
        supabase.from("trip_items").select("*", { count: "exact", head: true }).eq("trip_id", trip.id).eq("type", "stay"),
        // ... 3 more
      ]);
    // ...
  })
);
```

**Impact:** With 10 trips → 50+ database queries. With 50 trips → 250+ queries.

**Recommendations:**

1. **Use a single aggregated query:**
   ```typescript
   const { data: counts } = await supabase
     .rpc('get_trip_counts', { trip_ids: trips.map(t => t.id) });
   ```

2. **Or use Supabase's `select` with count:**
   ```typescript
   const { data: trips } = await supabase
     .from('trips')
     .select(`
       *,
       trip_items!inner (
         type
       )
     `)
     .eq('archived', false);
   // Then aggregate counts client-side
   ```

3. **Or create a database view:**
   ```sql
   CREATE VIEW trips_with_counts AS
   SELECT t.*, 
     COUNT(*) FILTER (WHERE ti.type = 'transport') as transport_count,
     COUNT(*) FILTER (WHERE ti.type = 'stay') as stay_count,
     ...
   FROM trips t
   LEFT JOIN trip_items ti ON t.id = ti.trip_id
   GROUP BY t.id;
   ```

**Priority:** P1 - Should fix before launch if expecting users with 10+ trips

---

#### Risk 2: Timeline Rendering for Large Trips

**Location:** Timeline component rendering

**Issue:** Trips with 300+ items may cause UI performance issues:
- Large DOM with many cards
- Potentially multiple re-renders
- Memory for holding all item data

**Recommendations:**

1. **Virtual Scrolling:**
   - Use `@tanstack/react-virtual` or similar
   - Only render visible items in viewport
   ```typescript
   import { useVirtualizer } from '@tanstack/react-virtual';
   
   const virtualizer = useVirtualizer({
     count: items.length,
     getScrollElement: () => parentRef.current,
     estimateSize: () => 100, // estimated row height
   });
   ```

2. **Pagination/Lazy Loading:**
   - Load items progressively as user scrolls
   - Start with first 50 items, load more on demand

3. **Memoization:**
   - Use `React.memo()` for timeline item cards
   - Use `useMemo` for computed values (grouping, layovers)
   ```typescript
   const groupedItems = useMemo(() => 
     buildTimelineGroups(items), 
     [items]
   );
   ```

**Priority:** P2 - Monitor once real users have large trips

---

#### Risk 3: Google Places API Usage

**Location:** Autocomplete components

**Issue:** Uncontrolled API calls on each keystroke:
- API costs ($3 per 1000 requests)
- Rate limiting risks
- Unnecessary calls for partial input

**Recommendations:**

1. **Debounce Input:**
   ```typescript
   const [query, setQuery] = useState('');
   const debouncedQuery = useDebounce(query, 300);
   
   useEffect(() => {
     if (debouncedQuery.length >= 2) {
       fetchPlaces(debouncedQuery);
     }
   }, [debouncedQuery]);
   ```

2. **Minimum Character Threshold:**
   - Don't call API until 2+ characters entered
   - Show "Type to search" placeholder

3. **Session Tokens:**
   - Use session tokens to batch autocomplete requests
   - Reduces billing impact

4. **Cache Results:**
   - Cache recent searches in memory
   - Avoid re-fetching for same query

**Priority:** P1 - Cost control before launch

---

#### Risk 4: Document Preview Loading

**Location:** Document grid and viewer

**Issue:** Loading many document thumbnails simultaneously:
- Large PDFs generating previews
- Multiple image downloads

**Recommendations:**

1. **Lazy Loading:**
   ```typescript
   <img 
     loading="lazy"
     src={thumbnailUrl} 
     alt={document.file_name}
   />
   ```

2. **Intersection Observer:**
   - Only load thumbnails when visible
   - Use skeleton placeholders until loaded

3. **Thumbnail Generation:**
   - Consider generating thumbnails server-side (Supabase Edge Function)
   - Store thumbnails separately from full documents

**Priority:** P2 - Implement if document-heavy usage observed

---

### 2.2 Data Fetching Recommendations

1. **Use SWR or React Query:**
   ```typescript
   import useSWR from 'swr';
   
   const { data: trips, isLoading, error } = useSWR(
     '/api/trips',
     fetcher,
     { revalidateOnFocus: false }
   );
   ```
   
   Benefits:
   - Automatic caching
   - Background revalidation
   - Error retry
   - Request deduplication

2. **Server Components for Static Data:**
   - Use React Server Components for initial data fetch
   - Reduces client-side JavaScript
   - Example: Trip overview page can be RSC with suspense

3. **Preloading:**
   ```typescript
   // Preload trip data on hover
   <Link 
     href={`/app/trips/${trip.id}`}
     onMouseEnter={() => prefetchTrip(trip.id)}
   >
   ```

---

### 2.3 Performance Summary

| Issue | Impact | Recommendation | Priority | Status |
|-------|--------|----------------|----------|--------|
| N+1 trip count queries | High | Use aggregated query | P1 | ✅ Done |
| Google Places debounce | Medium | Add 300ms debounce | P1 | ⏸️ N/A (not implemented) |
| Large timeline lists | Medium | Add virtualization | P2 | Deferred |
| Document thumbnails | Low | Add lazy loading | P2 | Deferred |
| Data fetching pattern | Medium | Consider SWR/React Query | P2 | Deferred |

---

## 3. Production-Readiness Checklist

### 3.1 Features & Functionality

- [ ] **P0 Flows Verified:**
  - [ ] Sign up / Sign in / Sign out working
  - [ ] Session persistence working
  - [ ] Auth route redirects working
  - [ ] Trip list loads with real data
  - [ ] Create / Edit / Delete trip working
  - [ ] All item types (Transport, Stay, Activity, Note) can be created
  - [ ] Timeline displays correctly with day grouping
  - [ ] Documents can be uploaded and viewed
  
- [ ] **Empty States:**
  - [ ] No trips state shows illustration + CTA
  - [ ] Empty timeline shows "Add your first item"
  - [ ] Empty travellers list shows CTA
  - [ ] Empty documents shows upload prompt

- [ ] **Error Handling:**
  - [ ] Network errors show retry option
  - [ ] Form validation errors display inline
  - [ ] Supabase errors show user-friendly messages
  - [ ] No unhandled exceptions reaching user

---

### 3.2 Browser Compatibility

- [ ] **Desktop Testing:**
  - [ ] Chrome (latest) - macOS / Windows
  - [ ] Safari (latest) - macOS
  - [ ] Firefox (latest) - optional
  - [ ] Edge (latest) - optional

- [ ] **Mobile Responsive Testing:**
  - [ ] Chrome DevTools - iPhone viewport
  - [ ] Chrome DevTools - iPad viewport
  - [ ] Safari DevTools - Mobile simulation

- [ ] **Functionality Verified on Mobile:**
  - [ ] Navigation works (hamburger menu if applicable)
  - [ ] Forms are usable on touch devices
  - [ ] Date pickers work on mobile
  - [ ] No horizontal overflow

---

### 3.3 Environment Configuration

- [ ] **Environment Variables Set:** (set in Vercel)
  - [ ] `NEXT_PUBLIC_SUPABASE_URL` - Production Supabase URL
  - [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Production anon key
  - [ ] `NEXT_PUBLIC_GOOGLE_PLACES_API_KEY` - Production API key (if used)

- [x] **Secrets Not Exposed:**
  - [x] No service role key in repo
  - [x] No `.env.local` committed
  - [x] Build logs don't expose secrets

- [ ] **Google API Key Secured:** (N/A - not implemented)
  - [ ] HTTP referrer restrictions set
  - [ ] API restrictions set (Places API only)

---

### 3.4 Security Verification

- [x] **Authentication:**
  - [x] Cannot access `/app/*` when logged out
  - [x] Session expires correctly
  - [ ] Password reset works (requires manual test)

- [x] **Authorization:**
  - [x] User A cannot see User B's trips (RLS enforced by Supabase)
  - [ ] User A cannot see User B's documents
  - [ ] No admin endpoints exposed

- [ ] **File Uploads:**
  - [ ] Only allowed file types accepted
  - [ ] Size limits enforced
  - [ ] Private buckets use signed URLs

---

### 3.5 Performance Baseline

- [ ] **Load Times:**
  - [ ] Landing page loads < 3s (LCP)
  - [ ] Trip list loads < 2s with 10 trips
  - [ ] Trip overview loads < 2s with 50 items

- [ ] **Core Web Vitals:**
  - [ ] LCP < 2.5s (Largest Contentful Paint)
  - [ ] FID < 100ms (First Input Delay)
  - [ ] CLS < 0.1 (Cumulative Layout Shift)

- [ ] **Lighthouse Score:**
  - [ ] Performance > 80
  - [ ] Accessibility > 90
  - [ ] Best Practices > 90
  - [ ] SEO > 90

---

### 3.6 Monitoring & Error Tracking

- [ ] **Error Tracking (Recommended):**
  - [ ] Sentry or similar configured
  - [ ] Source maps uploaded for production
  - [ ] Alert rules set for critical errors

- [ ] **Analytics (Optional):**
  - [ ] Page view tracking
  - [ ] Core user actions tracked

- [ ] **Uptime Monitoring:**
  - [ ] Vercel uptime monitoring enabled OR
  - [ ] External monitoring (UptimeRobot, etc.)

---

### 3.7 Final Deployment Checks

- [ ] **Build:**
  - [ ] `npm run build` succeeds with no errors
  - [ ] `npm run lint` passes
  - [ ] TypeScript compiles with no errors

- [ ] **Deployment:**
  - [ ] Preview deployment tested
  - [ ] Production deployment tested
  - [ ] Custom domain configured (waydeck.com)
  - [ ] SSL certificate active

- [ ] **Post-Deploy Verification:**
  - [ ] Landing page loads on production URL
  - [ ] Sign in works on production
  - [ ] Create trip works on production
  - [ ] No console errors in production

---

### 3.8 Documentation

- [ ] **Technical Docs:**
  - [ ] README.md updated with deployment instructions
  - [ ] Environment variable documentation complete
  - [ ] API/Supabase integration documented

- [ ] **For QA:**
  - [ ] Test accounts documented (for QA)
  - [ ] Known issues documented

---

## Summary

**Before public launch to waydeck.com:**

1. ✅ Security is generally good - verify file upload limits
2. ⚠️ Fix N+1 query issue in trip list
3. ⚠️ Add Google Places debouncing
4. Run through production checklist
5. Monitor Core Web Vitals post-launch

**Estimated effort to fix P1 items:** 4-8 hours

---

*End of Production Readiness Document*
