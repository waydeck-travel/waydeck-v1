# Waydeck Web – Vercel Deployment Guide

> **Version:** 1.0  
> **Created:** 2025-12-15  
> **Target:** Waydeck Web v1 (`waydeck-v1/web/`)

---

## Table of Contents

1. [Project Settings](#1-project-settings)
2. [Environment Variables](#2-environment-variables)
3. [Deployment Workflow](#3-deployment-workflow)
4. [Custom Domain Setup](#4-custom-domain-setup)
5. [Troubleshooting](#5-troubleshooting)

---

## 1. Project Settings

### 1.1 Vercel Project Configuration

When importing the project to Vercel, use these settings:

| Setting | Value |
|---------|-------|
| **Framework Preset** | Next.js |
| **Root Directory** | `web` |
| **Build Command** | `npm run build` (default) |
| **Output Directory** | `.next` (default) |
| **Install Command** | `npm install` (default) |
| **Node.js Version** | 20.x (recommended) |

### 1.2 Import Steps

1. Go to [vercel.com/new](https://vercel.com/new)
2. Select "Import Git Repository"
3. Select the `waydeck-v1` repository
4. Configure project:
   - **Project Name:** `waydeck-web` (or your preference)
   - **Framework Preset:** `Next.js` (auto-detected)
   - **Root Directory:** Click "Edit" → Set to `web`
5. Add environment variables (see Section 2)
6. Click "Deploy"

### 1.3 vercel.json (Optional)

If custom configuration is needed, create `waydeck-v1/web/vercel.json`:

```json
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "installCommand": "npm install",
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        }
      ]
    }
  ]
}
```

---

## 2. Environment Variables

### 2.1 Required Variables

Configure these in Vercel Dashboard → Project → Settings → Environment Variables:

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL | `https://xxxxx.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anonymous (public) key | `eyJhbGciOiJIUzI1NiIs...` |

### 2.2 Optional Variables

| Variable | Description | When Needed |
|----------|-------------|-------------|
| `NEXT_PUBLIC_GOOGLE_PLACES_API_KEY` | Google Places API key | If Places autocomplete is enabled |
| `NEXT_PUBLIC_APP_URL` | Production URL | For sharing links (e.g., `https://waydeck.com`) |

### 2.3 Environment Configuration Per Environment

| Environment | Usage | Variables To Set |
|-------------|-------|------------------|
| **Production** | `main` branch deploys | Production Supabase credentials |
| **Preview** | PR/branch deploys | Staging/dev Supabase credentials |
| **Development** | Local only | Use `.env.local` |

To configure environment-specific variables:

1. Go to Project Settings → Environment Variables
2. Add variable name and value
3. Select environments: ✅ Production, ✅ Preview, ✅ Development
4. For different values per environment, uncheck environments and add separately

### 2.4 Environment Variables Checklist

**Before Production Deploy:**

- [ ] `NEXT_PUBLIC_SUPABASE_URL` set for Production environment
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY` set for Production environment
- [ ] Using PRODUCTION Supabase project (not dev/staging)
- [ ] `NEXT_PUBLIC_GOOGLE_PLACES_API_KEY` set (if using Google Places)
- [ ] Google API key has HTTP referrer restrictions

> ⚠️ **Never add:** `SUPABASE_SERVICE_ROLE_KEY`, database passwords, or any private keys

---

## 3. Deployment Workflow

### 3.1 Automatic Deployments

Vercel automatically deploys:

| Trigger | Environment | URL |
|---------|-------------|-----|
| Push to `main` | Production | `waydeck.com` / `*.vercel.app` |
| Push to other branches | Preview | `[branch]-[hash].vercel.app` |
| Pull Request | Preview | `[pr-number]-[hash].vercel.app` |

### 3.2 Recommended Git Workflow

```
main ← production deploys
  ↑
develop ← staging/preview
  ↑
feature/* ← preview per PR
```

**Branch Protection Rules:**
- Require PR reviews before merging to `main`
- Require CI checks to pass (lint, type check, tests)

### 3.3 Preview Deployments

Every Pull Request gets a unique preview URL:

1. Open PR against `main` or `develop`
2. Vercel bot comments with preview URL
3. QA can test on preview before merge
4. Preview uses Preview environment variables

**Commenting previews:**
- Vercel automatically adds PR comments with preview links
- Configure in Project Settings → Git → comments

### 3.4 Production Deployment

Production deploys happen automatically when:
- Changes are pushed/merged to `main` branch

**Manual deployment:**
1. Go to Vercel Dashboard → Deployments
2. Click "Deploy from..." → select branch
3. Or use Vercel CLI: `vercel --prod`

### 3.5 Rollback Strategy

If a production deployment has issues:

**Option 1: Instant Rollback (Recommended)**
1. Go to Vercel Dashboard → Deployments
2. Find previous stable deployment
3. Click "..." → "Promote to Production"
4. New deployment is live instantly

**Option 2: Git Revert**
1. Revert the problematic commit in Git
2. Push to `main`
3. Vercel auto-deploys the revert

**Option 3: Redeploy Previous Commit**
1. Go to Deployments
2. Find previous deployment
3. Click "Redeploy"

---

## 4. Custom Domain Setup

### 4.1 Adding waydeck.com

1. Go to Project Settings → Domains
2. Enter `waydeck.com`
3. Follow DNS configuration instructions

### 4.2 DNS Configuration

**Option A: Vercel Nameservers (Recommended)**
- Point domain nameservers to Vercel
- Vercel handles all DNS

**Option B: Custom DNS**

Add these records at your DNS provider:

| Type | Name | Value |
|------|------|-------|
| A | @ | `76.76.21.21` |
| CNAME | www | `cname.vercel-dns.com` |

### 4.3 SSL Certificate

- Vercel automatically provisions SSL certificates
- Certificate auto-renews
- Both `waydeck.com` and `www.waydeck.com` are secured

### 4.4 Recommended Domain Setup

| Domain | Configuration |
|--------|---------------|
| `waydeck.com` | Primary production domain |
| `www.waydeck.com` | Redirect to `waydeck.com` |
| `app.waydeck.com` | Optional: alias for `/app/*` routes |
| `staging.waydeck.com` | Optional: staging environment |

---

## 5. Troubleshooting

### 5.1 Common Issues

#### Build Fails: "Cannot find module..."

**Cause:** Missing dependency or wrong root directory

**Fix:**
1. Verify Root Directory is set to `web`
2. Check `package.json` includes all dependencies
3. Clear cache and redeploy

#### Environment Variables Not Loading

**Cause:** Variables not prefixed with `NEXT_PUBLIC_`

**Fix:**
- Client-side variables MUST start with `NEXT_PUBLIC_`
- Server-side only variables don't need prefix

#### Auth Not Working

**Cause:** Supabase URL/key mismatch or cookie issues

**Fix:**
1. Verify Supabase credentials match the project
2. Check Supabase → Auth → URL Configuration
3. Add production URL to allowed redirect URLs in Supabase

#### Preview Deployments Using Wrong Database

**Cause:** Preview using production variables

**Fix:**
1. Create separate environment variables for Preview
2. Use staging/dev Supabase project for previews

### 5.2 Vercel CLI Commands

Install CLI:
```bash
npm i -g vercel
```

Useful commands:
```bash
# Login
vercel login

# Deploy preview
vercel

# Deploy production
vercel --prod

# List deployments
vercel ls

# View logs
vercel logs [deployment-url]

# Pull environment variables locally
vercel env pull
```

### 5.3 Build Logs

View detailed build logs:
1. Go to Vercel Dashboard → Deployments
2. Click on deployment
3. Click "Building" or "Logs" tab
4. Scroll through output for errors

### 5.4 Support Resources

- [Vercel Next.js Docs](https://vercel.com/docs/frameworks/nextjs)
- [Supabase + Vercel Guide](https://supabase.com/docs/guides/getting-started/quickstarts/nextjs)
- [Vercel Status](https://www.vercel-status.com/)

---

## Quick Reference

### First-Time Setup

```bash
# 1. Import to Vercel (web UI or CLI)
vercel link

# 2. Set environment variables in Vercel Dashboard
# NEXT_PUBLIC_SUPABASE_URL
# NEXT_PUBLIC_SUPABASE_ANON_KEY

# 3. Deploy
git push origin main  # auto-deploys

# 4. Configure custom domain in Vercel Dashboard
```

### Day-to-Day

```bash
# Feature development
git checkout -b feature/new-feature
git push origin feature/new-feature  # → Preview deploy

# Create PR → Preview URL in PR comments

# Merge to main → Production deploy

# Rollback if needed → Vercel Dashboard → Promote previous build
```

---

*End of Vercel Deployment Guide*
