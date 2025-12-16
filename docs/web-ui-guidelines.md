# Waydeck Web UI & Design System Guidelines

> **Version:** 1.0  
> **Created:** 2025-12-15  
> **Target Stack:** shadcn/ui + Tailwind CSS + lucide-react  
> **Reference:** waydeck-web-ux-spec.md

---

## 1. Design Tokens

### 1.1 Colors

#### Light Mode

| Token | Tailwind Class | Hex Value | Usage |
|-------|----------------|-----------|-------|
| **Primary** | `bg-primary` | `#0D9488` (teal-600) | Main actions, active states |
| **Primary Foreground** | `text-primary-foreground` | `#FFFFFF` | Text on primary |
| **Secondary** | `bg-secondary` | `#F1F5F9` (slate-100) | Secondary buttons, muted areas |
| **Secondary Foreground** | `text-secondary-foreground` | `#1E293B` (slate-800) | Text on secondary |
| **Accent** | `bg-accent` | `#F59E0B` (amber-500) | Highlights, badges |
| **Background** | `bg-background` | `#FAFAFA` | Page background |
| **Card** | `bg-card` | `#FFFFFF` | Card surfaces |
| **Muted** | `bg-muted` | `#F1F5F9` (slate-100) | Disabled, secondary text |
| **Muted Foreground** | `text-muted-foreground` | `#64748B` (slate-500) | Secondary text |
| **Border** | `border-border` | `#E2E8F0` (slate-200) | Borders, dividers |
| **Destructive** | `bg-destructive` | `#EF4444` (red-500) | Delete, errors |

#### Dark Mode

| Token | Tailwind Class | Hex Value | Usage |
|-------|----------------|-----------|-------|
| **Background** | `dark:bg-background` | `#0F172A` (slate-900) | Page background |
| **Card** | `dark:bg-card` | `#1E293B` (slate-800) | Card surfaces |
| **Muted** | `dark:bg-muted` | `#334155` (slate-700) | Muted areas |
| **Border** | `dark:border-border` | `#334155` (slate-700) | Borders |
| **Foreground** | `dark:text-foreground` | `#F8FAFC` (slate-50) | Primary text |
| **Muted Foreground** | `dark:text-muted-foreground` | `#94A3B8` (slate-400) | Secondary text |

#### Semantic Colors

| Purpose | Light | Dark | Usage |
|---------|-------|------|-------|
| **Success** | `#22C55E` (green-500) | `#4ADE80` (green-400) | Completed, paid |
| **Warning** | `#F59E0B` (amber-500) | `#FBBF24` (amber-400) | Partial, expiring soon |
| **Error** | `#EF4444` (red-500) | `#F87171` (red-400) | Failed, overdue |
| **Info** | `#3B82F6` (blue-500) | `#60A5FA` (blue-400) | Information |

### 1.2 Typography

**Font Family:**
```css
--font-sans: 'Inter', system-ui, -apple-system, sans-serif;
```

**Type Scale:**

| Level | Class | Size | Weight | Usage |
|-------|-------|------|--------|-------|
| **Display** | `text-3xl` | 30px | 700 | Landing hero |
| **H1** | `text-2xl` | 24px | 600 | Page titles |
| **H2** | `text-xl` | 20px | 600 | Section headers |
| **H3** | `text-lg` | 18px | 600 | Card titles |
| **Body** | `text-base` | 16px | 400 | Default text |
| **Small** | `text-sm` | 14px | 400 | Secondary text, labels |
| **XSmall** | `text-xs` | 12px | 400 | Badges, metadata |

**Line Heights:**
- Headings: `leading-tight` (1.25)
- Body: `leading-relaxed` (1.625)

### 1.3 Spacing Scale

Use Tailwind's default spacing scale:

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 4px | Tight gaps |
| `space-2` | 8px | Inline spacing |
| `space-3` | 12px | Element gaps |
| `space-4` | 16px | Standard gap |
| `space-6` | 24px | Section padding |
| `space-8` | 32px | Large gaps |
| `space-12` | 48px | Section margins |

### 1.4 Border Radius

| Token | Class | Value | Usage |
|-------|-------|-------|-------|
| **Small** | `rounded-md` | 6px | Inputs, small buttons |
| **Medium** | `rounded-lg` | 8px | Buttons, badges |
| **Large** | `rounded-xl` | 12px | Cards |
| **Full** | `rounded-full` | 9999px | Avatars, pills |

### 1.5 Shadows

| Level | Class | Usage |
|-------|-------|-------|
| **None** | `shadow-none` | Flat elements |
| **Small** | `shadow-sm` | Subtle elevation |
| **Medium** | `shadow-md` | Cards, dropdowns |
| **Large** | `shadow-lg` | Modals, popovers |

---

## 2. Layout & Breakpoints

### 2.1 Breakpoints

| Name | Width | Target |
|------|-------|--------|
| `sm` | ≥640px | Large phones, small tablets |
| `md` | ≥768px | Tablets |
| `lg` | ≥1024px | Small laptops, desktop |
| `xl` | ≥1280px | Large desktop |
| `2xl` | ≥1536px | Wide screens |

### 2.2 Layout Patterns

#### App Shell (Authenticated)

```tsx
// Desktop (lg+)
<div className="flex h-screen">
  <aside className="hidden lg:flex w-64 flex-col border-r">
    <Sidebar />
  </aside>
  <main className="flex-1 overflow-auto">
    <div className="container py-6">
      {children}
    </div>
  </main>
</div>

// Mobile/Tablet (<lg)
<div className="flex h-screen flex-col">
  <header className="sticky top-0 z-50 border-b bg-background">
    <TopBar />
  </header>
  <main className="flex-1 overflow-auto">
    <div className="container py-4">
      {children}
    </div>
  </main>
</div>
```

#### Container Widths

```tsx
// Standard content container
<div className="container max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
  {/* Max 1024px, centered, responsive padding */}
</div>

// Wide container (trip list, landing)
<div className="container max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  {/* Max 1280px */}
</div>

// Narrow container (auth forms)
<div className="container max-w-md mx-auto px-4">
  {/* Max 448px */}
</div>
```

### 2.3 Sidebar Layout

```tsx
// Sidebar component
<aside className="flex h-full w-64 flex-col bg-background">
  {/* Logo */}
  <div className="flex h-16 items-center px-4 border-b">
    <Logo />
  </div>
  
  {/* Navigation */}
  <nav className="flex-1 space-y-1 p-4">
    <NavItem icon={Plane} label="Trips" href="/app/trips" />
    <NavItem icon={Calendar} label="Today" href="/app/today" />
    <NavItem icon={FileText} label="Documents" href="/app/documents" />
    <NavItem icon={CheckSquare} label="Checklists" href="/app/checklists" />
  </nav>
  
  {/* Footer */}
  <div className="border-t p-4">
    <NavItem icon={User} label="Profile" href="/app/profile" />
  </div>
</aside>
```

### 2.4 Grid Patterns

**Trip Cards Grid:**
```tsx
<div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
  {trips.map(trip => <TripCard key={trip.id} trip={trip} />)}
</div>
```

**Document Cards Grid:**
```tsx
<div className="grid gap-4 grid-cols-2 sm:grid-cols-3 lg:grid-cols-4">
  {documents.map(doc => <DocumentCard key={doc.id} doc={doc} />)}
</div>
```

---

## 3. Component Guidelines (shadcn/ui)

### 3.1 Navigation Components

#### Sidebar (Desktop)

Use custom layout with shadcn/ui `Button` for nav items:

```tsx
<Button 
  variant={isActive ? "secondary" : "ghost"} 
  className="w-full justify-start gap-3"
  asChild
>
  <Link href={href}>
    <Icon className="h-4 w-4" />
    {label}
  </Link>
</Button>
```

#### Mobile Menu

Use `Sheet` component for slide-out navigation:

```tsx
<Sheet>
  <SheetTrigger asChild>
    <Button variant="ghost" size="icon">
      <Menu className="h-5 w-5" />
    </Button>
  </SheetTrigger>
  <SheetContent side="left" className="w-64">
    <MobileNav />
  </SheetContent>
</Sheet>
```

### 3.2 Button Variants

| Variant | Usage | Example |
|---------|-------|---------|
| `default` | Primary actions | "Save", "Create Trip" |
| `secondary` | Secondary actions | "Cancel", "Back" |
| `outline` | Tertiary actions | "Edit", "View All" |
| `ghost` | Subtle actions | Nav items, icon buttons |
| `destructive` | Delete/destructive | "Delete", "Sign Out" |
| `link` | Text links | "Forgot password?" |

**Button Sizes:**

| Size | Usage |
|------|-------|
| `sm` | Inline actions, badges |
| `default` | Standard buttons |
| `lg` | Hero CTAs, full-width forms |
| `icon` | Icon-only buttons (32px × 32px) |

### 3.3 Form Components

#### Input Fields

```tsx
<div className="space-y-2">
  <Label htmlFor="email">Email</Label>
  <Input 
    id="email" 
    type="email" 
    placeholder="john@example.com"
    className="w-full"
  />
  {error && (
    <p className="text-sm text-destructive">{error}</p>
  )}
</div>
```

#### Form Layout

```tsx
<form className="space-y-6">
  {/* Section with header */}
  <div className="space-y-4">
    <h3 className="text-lg font-semibold">Origin Details</h3>
    <div className="grid gap-4 sm:grid-cols-2">
      <FormField label="City" />
      <FormField label="Country" />
    </div>
  </div>
  
  <Separator />
  
  <div className="space-y-4">
    <h3 className="text-lg font-semibold">Destination</h3>
    {/* ... */}
  </div>
</form>
```

#### Select/Combobox

Use `Select` for simple dropdowns, `Combobox` for searchable:

```tsx
// Simple dropdown
<Select>
  <SelectTrigger>
    <SelectValue placeholder="Select country" />
  </SelectTrigger>
  <SelectContent>
    <SelectItem value="IN">🇮🇳 India</SelectItem>
    <SelectItem value="TH">🇹🇭 Thailand</SelectItem>
  </SelectContent>
</Select>

// Searchable (cities, airlines)
<Popover>
  <PopoverTrigger asChild>
    <Button variant="outline" className="w-full justify-between">
      {value || "Search city..."}
      <ChevronsUpDown className="ml-2 h-4 w-4" />
    </Button>
  </PopoverTrigger>
  <PopoverContent className="w-full p-0">
    <Command>
      <CommandInput placeholder="Search..." />
      <CommandList>
        {items.map(item => (
          <CommandItem key={item.value}>{item.label}</CommandItem>
        ))}
      </CommandList>
    </Command>
  </PopoverContent>
</Popover>
```

#### Date & Time Pickers

Use `Popover` with `Calendar` for date selection:

```tsx
<Popover>
  <PopoverTrigger asChild>
    <Button variant="outline" className="w-full justify-start">
      <CalendarIcon className="mr-2 h-4 w-4" />
      {date ? format(date, "PPP") : "Pick a date"}
    </Button>
  </PopoverTrigger>
  <PopoverContent className="w-auto p-0">
    <Calendar
      mode="single"
      selected={date}
      onSelect={setDate}
    />
  </PopoverContent>
</Popover>
```

### 3.4 Cards

#### Trip Card

```tsx
<Card className="overflow-hidden hover:shadow-md transition-shadow">
  <CardHeader className="pb-2">
    <div className="flex items-start justify-between">
      <CardTitle className="text-lg">{trip.name}</CardTitle>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="icon">
            <MoreVertical className="h-4 w-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem>Edit</DropdownMenuItem>
          <DropdownMenuItem>Share</DropdownMenuItem>
          <Separator />
          <DropdownMenuItem className="text-destructive">
            Delete
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
    <CardDescription>
      📍 {trip.origin_city}, {trip.origin_country}
    </CardDescription>
  </CardHeader>
  <CardContent className="pt-2">
    <p className="text-sm text-muted-foreground">
      📅 {formatDateRange(trip.start_date, trip.end_date)}
    </p>
    <div className="mt-3 flex gap-3">
      <Badge variant="secondary">✈ {counts.transport}</Badge>
      <Badge variant="secondary">🏨 {counts.stays}</Badge>
      <Badge variant="secondary">🎟 {counts.activities}</Badge>
    </div>
  </CardContent>
</Card>
```

#### Timeline Item Card

```tsx
<Card className="hover:bg-muted/50 transition-colors cursor-pointer">
  <CardContent className="flex items-start gap-4 p-4">
    {/* Icon */}
    <div className="rounded-lg bg-primary/10 p-2 text-primary">
      <Plane className="h-5 w-5" />
    </div>
    
    {/* Content */}
    <div className="flex-1 min-w-0">
      <h4 className="font-medium truncate">
        Flight 6E 5102
      </h4>
      <p className="text-sm text-muted-foreground">
        PNQ → BOM
      </p>
      <p className="text-sm text-muted-foreground">
        08:00 – 09:15 • 2 passengers
      </p>
      <div className="mt-2 flex flex-wrap gap-1">
        <Badge variant="outline" className="text-xs">Flight</Badge>
        <Badge variant="secondary" className="text-xs">🎫 Ticket</Badge>
      </div>
    </div>
    
    {/* Actions */}
    <Button variant="ghost" size="icon">
      <ChevronRight className="h-4 w-4" />
    </Button>
  </CardContent>
</Card>
```

### 3.5 Timeline Component

Custom timeline using flex layout:

```tsx
<div className="space-y-8">
  {/* Day Group */}
  <div>
    {/* Day Header */}
    <div className="sticky top-0 z-10 bg-background py-2">
      <div className="flex items-center gap-2">
        <div className="h-px flex-1 bg-border" />
        <span className="text-sm font-medium text-muted-foreground">
          Sun, 1 Dec 2025
        </span>
        <div className="h-px flex-1 bg-border" />
      </div>
    </div>
    
    {/* Timeline Items */}
    <div className="relative pl-6 space-y-4">
      {/* Vertical line */}
      <div className="absolute left-2 top-0 bottom-0 w-0.5 bg-border" />
      
      {/* Item with dot */}
      <div className="relative">
        {/* Dot */}
        <div className="absolute -left-4 mt-1.5 h-3 w-3 rounded-full bg-primary ring-4 ring-background" />
        
        {/* Card */}
        <TimelineItemCard item={item} />
      </div>
      
      {/* Layover indicator */}
      <div className="relative">
        <div className="absolute -left-4 mt-1.5 h-3 w-3 rounded-full bg-amber-500 ring-4 ring-background" />
        <div className="py-2 px-4 bg-amber-50 dark:bg-amber-950 rounded-lg text-sm">
          <Clock className="inline h-4 w-4 mr-1" />
          Layover: 4h 15m at BOM
        </div>
      </div>
    </div>
  </div>
</div>
```

### 3.6 Dialogs & Sheets

#### Modal Dialog (Confirmations)

```tsx
<AlertDialog>
  <AlertDialogTrigger asChild>
    <Button variant="destructive">Delete Trip</Button>
  </AlertDialogTrigger>
  <AlertDialogContent>
    <AlertDialogHeader>
      <AlertDialogTitle>Delete Trip?</AlertDialogTitle>
      <AlertDialogDescription>
        This will permanently delete "Vietnam & Thailand 2025" 
        and all associated items. This action cannot be undone.
      </AlertDialogDescription>
    </AlertDialogHeader>
    <AlertDialogFooter>
      <AlertDialogCancel>Cancel</AlertDialogCancel>
      <AlertDialogAction className="bg-destructive">
        Delete
      </AlertDialogAction>
    </AlertDialogFooter>
  </AlertDialogContent>
</AlertDialog>
```

#### Side Sheet (Forms on Desktop)

```tsx
<Sheet>
  <SheetTrigger asChild>
    <Button>+ Add Transport</Button>
  </SheetTrigger>
  <SheetContent className="w-full sm:max-w-lg overflow-y-auto">
    <SheetHeader>
      <SheetTitle>Add Transport</SheetTitle>
      <SheetDescription>
        Add a flight, train, bus, or other transport.
      </SheetDescription>
    </SheetHeader>
    <div className="py-6">
      <TransportForm />
    </div>
    <SheetFooter>
      <SheetClose asChild>
        <Button variant="outline">Cancel</Button>
      </SheetClose>
      <Button>Save</Button>
    </SheetFooter>
  </SheetContent>
</Sheet>
```

### 3.7 Badges & Tags

| Variant | Usage | Example |
|---------|-------|---------|
| `default` | Primary category | "Flight", "Hotel" |
| `secondary` | Counts, metadata | "✈ 5", "🏨 3" |
| `outline` | Subtle tags | "Ticket", "Voucher" |
| `destructive` | Alerts | "Expired", "Over Budget" |

**Custom Status Badges:**

```tsx
const StatusBadge = ({ status }) => {
  const variants = {
    paid: "bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300",
    pending: "bg-amber-100 text-amber-700 dark:bg-amber-900 dark:text-amber-300",
    overdue: "bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-300",
  };
  
  return (
    <span className={cn(
      "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium",
      variants[status]
    )}>
      {status}
    </span>
  );
};
```

---

## 4. Icon Strategy (lucide-react)

### 4.1 Transport Mode Icons

| Mode | Icon | Import |
|------|------|--------|
| Flight | ✈ | `Plane` |
| Train | 🚂 | `Train` |
| Bus | 🚌 | `Bus` |
| Car | 🚗 | `Car` |
| Bike | 🚲 | `Bike` |
| Cruise | 🚢 | `Ship` |
| Metro | 🚇 | `TrainFront` |
| Ferry | ⛴ | `Sailboat` |
| Other | 🚙 | `CarTaxiFront` |

### 4.2 Action Icons

| Action | Icon | Context |
|--------|------|---------|
| Add | `Plus` | FABs, create buttons |
| Edit | `Pencil` | Edit actions |
| Delete | `Trash2` | Delete actions |
| Share | `Share2` | Share trip |
| Upload | `Upload` | Document upload |
| Download | `Download` | Document download |
| Archive | `Archive` | Archive trip |
| Search | `Search` | Search inputs |
| Filter | `Filter` | Filter controls |
| Settings | `Settings` | Settings links |
| Menu | `Menu` | Hamburger menu |
| Close | `X` | Close modals |
| Back | `ArrowLeft` | Navigation back |
| More | `MoreVertical` | Overflow menu |

### 4.3 Status Icons

| Status | Icon | Color |
|--------|------|-------|
| Completed | `CheckCircle2` | `text-green-500` |
| In Progress | `Clock` | `text-amber-500` |
| Upcoming | `Circle` | `text-muted-foreground` |
| Error | `AlertCircle` | `text-red-500` |
| Info | `Info` | `text-blue-500` |
| Warning | `AlertTriangle` | `text-amber-500` |

### 4.4 Category Icons

| Category | Icon |
|----------|------|
| Trips | `Plane` |
| Today | `Calendar` |
| Documents | `FileText` |
| Checklists | `CheckSquare` |
| Profile | `User` |
| Budget | `Wallet` |
| Expenses | `Receipt` |
| Travellers | `Users` |

### 4.5 Icon Sizing

| Context | Size | Class |
|---------|------|-------|
| Navigation | 20px | `h-5 w-5` |
| Inline | 16px | `h-4 w-4` |
| Card Icon | 20px | `h-5 w-5` |
| Large Icon | 24px | `h-6 w-6` |
| Hero Icon | 48px | `h-12 w-12` |

---

## 5. Feedback & States

### 5.1 Loading States

#### Skeleton

```tsx
// Card skeleton
<Card>
  <CardHeader>
    <Skeleton className="h-5 w-3/4" />
    <Skeleton className="h-4 w-1/2" />
  </CardHeader>
  <CardContent>
    <Skeleton className="h-4 w-full mb-2" />
    <Skeleton className="h-4 w-2/3" />
  </CardContent>
</Card>

// Table row skeleton
<div className="flex items-center space-x-4 p-4">
  <Skeleton className="h-10 w-10 rounded-full" />
  <div className="space-y-2">
    <Skeleton className="h-4 w-[200px]" />
    <Skeleton className="h-4 w-[150px]" />
  </div>
</div>
```

#### Button Loading

```tsx
<Button disabled>
  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
  Saving...
</Button>
```

#### Page Loading

```tsx
<div className="flex h-full items-center justify-center">
  <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
</div>
```

### 5.2 Empty States

```tsx
<div className="flex flex-col items-center justify-center py-12 text-center">
  <div className="rounded-full bg-muted p-4 mb-4">
    <Luggage className="h-8 w-8 text-muted-foreground" />
  </div>
  <h3 className="text-lg font-semibold mb-1">No trips yet</h3>
  <p className="text-sm text-muted-foreground mb-4 max-w-sm">
    Start planning your first adventure. Create a trip to organize 
    your flights, hotels, and activities.
  </p>
  <Button>
    <Plus className="mr-2 h-4 w-4" />
    Create Your First Trip
  </Button>
</div>
```

### 5.3 Toast Notifications

Use Sonner (shadcn/ui recommended) for toasts:

```tsx
import { toast } from "sonner"

// Success
toast.success("Trip created successfully")

// Error
toast.error("Failed to save changes", {
  description: "Please check your connection and try again."
})

// With action
toast("Trip archived", {
  action: {
    label: "Undo",
    onClick: () => handleUndo()
  }
})
```

### 5.4 Form Validation States

```tsx
// Error state
<div className="space-y-2">
  <Label htmlFor="email" className="text-destructive">
    Email
  </Label>
  <Input 
    id="email" 
    className="border-destructive focus-visible:ring-destructive"
  />
  <p className="text-sm text-destructive flex items-center gap-1">
    <AlertCircle className="h-3 w-3" />
    Please enter a valid email address
  </p>
</div>

// Success state
<div className="space-y-2">
  <Label htmlFor="email">Email</Label>
  <div className="relative">
    <Input id="email" className="pr-10" />
    <CheckCircle2 className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-green-500" />
  </div>
</div>
```

### 5.5 Progress Indicators

#### Linear Progress (Budget)

```tsx
<div className="space-y-1">
  <div className="flex justify-between text-sm">
    <span>Transport</span>
    <span>₹45K / ₹50K (90%)</span>
  </div>
  <Progress value={90} className="h-2" />
</div>
```

#### With Color Coding

```tsx
const getProgressColor = (percentage: number) => {
  if (percentage < 80) return "bg-green-500"
  if (percentage <= 100) return "bg-amber-500"
  return "bg-red-500"
}

<div className="h-2 w-full bg-muted rounded-full overflow-hidden">
  <div 
    className={cn("h-full transition-all", getProgressColor(percentage))}
    style={{ width: `${Math.min(percentage, 100)}%` }}
  />
</div>
```

---

## 6. Responsive Guidelines Summary

| Element | Mobile (<640px) | Tablet (640-1023px) | Desktop (≥1024px) |
|---------|-----------------|---------------------|-------------------|
| **Sidebar** | Hidden (Sheet) | Hidden (Sheet) | Visible (fixed) |
| **Trip cards** | 1 column | 2 columns | 3 columns |
| **Forms** | Full page | Full page/Sheet | Side Sheet |
| **Dialogs** | Full-width | Centered (max-w-md) | Centered (max-w-md) |
| **Timeline** | Single column | Single column | Single column |
| **Document grid** | 2 columns | 3 columns | 4 columns |
| **Container** | Full width (px-4) | Max 768px | Max 1024-1280px |

---

## 7. Accessibility Checklist

- [ ] All interactive elements have visible focus states
- [ ] Color contrast meets WCAG AA (4.5:1 for text, 3:1 for large text)
- [ ] Icons have `aria-label` or accompanying text
- [ ] Forms have associated labels
- [ ] Error states are announced to screen readers
- [ ] Modals trap focus and can be closed with Escape
- [ ] Loading states have appropriate `aria-busy` attributes
- [ ] Images have alt text
- [ ] Touch targets are minimum 44×44px on mobile

---

*End of Waydeck Web UI & Design System Guidelines*
