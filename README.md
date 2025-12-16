# Waydeck

**Waydeck** is a travel management app that helps you organize trips, track itineraries, manage documents, and more.

## Repository Structure

```
waydeck-v1/
├── mobile/     # Flutter mobile app (iOS & Android)
├── web/        # Next.js web app (coming soon)
├── docs/       # Shared documentation & specs
└── .github/    # CI/CD workflows
```

## Mobile App

The mobile app is built with **Flutter** and uses **Supabase** as the backend.

### Prerequisites
- Flutter SDK 3.24.0+
- Dart SDK 3.10.1+
- Xcode (for iOS)
- Android Studio (for Android)

### Getting Started

```bash
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Create a `.env` file in `mobile/`:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Run the App

```bash
cd mobile
flutter run
```

For web preview:
```bash
flutter run -d chrome
```

### Run Tests

```bash
cd mobile
flutter test
```

## Web App

> **Coming Soon** - The web app will be built with Next.js + Supabase + Vercel.

See [web/README.md](./web/README.md) for details.

## Documentation

Project specs and documentation are in the `docs/` folder:
- [Product Spec](./docs/waydeck-spec.md)
- [Completed Features](./docs/waydeck-completed-features.md)
- [QA Test Plan](./docs/qa-test-plan.md)
- [v1.1 Addendum](./docs/waydeck-v1.1-spec-addendum.md)

## CI/CD

GitHub Actions workflows are configured in `.github/workflows/`:
- **flutter-ci.yml** - Runs analyze, tests, and builds on push/PR to main/develop
