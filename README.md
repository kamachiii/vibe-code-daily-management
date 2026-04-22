# Smart Planner & Trip Assistant

A Flutter app that combines a personal daily planner with an AI-powered trip recommendation engine.

## Quick start

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

## Documentation

See [`docs/setup.md`](docs/setup.md) for:
- Full Supabase project setup & DDL
- Edge Function deployment (`trip-plan` → Gemini)
- Passing credentials safely via `--dart-define`
- Firebase / FCM placeholder activation steps

## Stack

| Layer | Technology |
|-------|------------|
| UI | Flutter (Material 3) |
| State | Riverpod `^2.5` |
| Routing | go_router `^14` |
| Backend | Supabase (Auth, PostgreSQL, Edge Functions) |
| AI | Google Gemini via `trip-plan` Edge Function |
| Notifications | flutter_local_notifications + FCM stub |
