# Waydeck Web

The web application for Waydeck, built with **Next.js 14**, **TypeScript**, **Tailwind CSS**, and **shadcn/ui**.

## Tech Stack

- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS + shadcn/ui
- **Icons**: lucide-react
- **Auth**: Supabase (shared with mobile app)
- **Deployment**: Vercel

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm (or pnpm/yarn)
- Supabase project credentials

### Installation

```bash
cd waydeck-v1/web
npm install
```

### Environment Variables

Create a `.env.local` file in the `web/` directory:

```bash
cp .env.local.example .env.local
```

Then fill in your Supabase credentials:

```
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
```

> ⚠️ **Never commit `.env.local` to version control!**

### Development

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the app.

### Build

```bash
npm run build
```

### Lint

```bash
npm run lint
```

### Type Check

```bash
npx tsc --noEmit
```

## Project Structure

```
web/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── (marketing)/        # Public pages (landing)
│   │   ├── auth/               # Auth pages (sign-in, sign-up)
│   │   └── app/                # Authenticated app pages
│   ├── components/
│   │   ├── ui/                 # shadcn/ui components
│   │   ├── layout/             # Layout components (sidebar, topbar)
│   │   └── ...                 # Feature components
│   ├── lib/
│   │   ├── supabase/           # Supabase clients
│   │   └── utils.ts            # Utility functions
│   └── types/                  # TypeScript types
├── middleware.ts               # Auth middleware
├── tailwind.config.ts
└── package.json
```

## Vercel Deployment

When deploying to Vercel:

| Setting | Value |
|---------|-------|
| **Root Directory** | `web` |
| **Framework Preset** | Next.js |
| **Build Command** | `npm run build` |
| **Output Directory** | `.next` |

### Required Environment Variables (Vercel)

- `NEXT_PUBLIC_SUPABASE_URL` - Your Supabase project URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Your Supabase anon key

## CI/CD

A GitHub Actions workflow (`.github/workflows/web-ci.yml`) runs on pushes and PRs to `main`:

1. Install dependencies
2. Run ESLint
3. Run TypeScript type check
4. Build the app

## Related Documentation

- [Web UX Spec](../docs/waydeck-web-ux-spec.md)
- [Web UI Guidelines](../docs/web-ui-guidelines.md)
- [Web Implementation Plan](../docs/waydeck-web-v1-plan.md)
