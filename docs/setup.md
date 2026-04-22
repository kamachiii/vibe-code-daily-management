# Smart Planner & Trip Assistant — Setup Guide

## 1. Supabase Setup

### 1.1 Create a project
1. Go to [supabase.com](https://supabase.com) and create a free project.
2. Note your **Project URL** and **anon (public) key** from *Settings → API*.

### 1.2 Apply the database schema
Run the SQL in `supabase/schema.sql` in the Supabase **SQL Editor**.

### 1.3 Deploy the Edge Function
```bash
# Install Supabase CLI: https://supabase.com/docs/guides/cli
supabase login
supabase link --project-ref <your-project-ref>

# Set your Gemini API key as a secret (never commit it)
supabase secrets set GEMINI_API_KEY=your_gemini_api_key_here

# Deploy
supabase functions deploy trip-plan
```

> **Note:** The Flutter app never calls Gemini directly.  
> All AI calls are routed through the `trip-plan` Edge Function, keeping
> your `GEMINI_API_KEY` safe on the server.

---

## 2. Flutter App Configuration

### 2.1 Passing Supabase credentials

Do **not** hard-code secrets in source. Use `--dart-define` at build/run time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

For CI/CD, set these as environment secrets and pass them via your pipeline.

### 2.2 VS Code launch configuration (optional helper)

Create `.vscode/launch.json` (already in `.gitignore`):

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug (local)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://xxxx.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=eyJ..."
      ]
    }
  ]
}
```

---

## 3. Firebase (FCM) — Placeholder

Firebase Cloud Messaging is scaffolded but **not activated** in this MVP.

To enable it later:
1. Create a Firebase project and add Android/iOS apps.
2. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   and place them in the expected locations.
3. Uncomment the `await Firebase.initializeApp(...)` call in `main.dart`.
4. Implement `FirebaseMessaging.onMessage` listener in
   `lib/features/notifications/data/`.

---

## 4. Architecture

```
lib/
  main.dart             — Supabase init, ProviderScope, runApp
  app/
    app.dart            — MaterialApp.router + theme
    router.dart         — go_router routes (login, home, trip-ai)
    di.dart             — global Riverpod providers
  core/
    config/env.dart     — dart-define constants (no secrets)
    error/              — AppException hierarchy
    network/            — AppHttpClient wrapper
    utils/              — JSON helpers, DateTime helpers
  features/
    auth/               — Supabase Auth scaffold
    preferences/        — User preferences model + CRUD
    schedules/          — ScheduleRule + ScheduleItem models,
                          RecurrenceService stub, SchedulesRepository
    notifications/      — LocalNotificationsService + NotificationScheduler
    trip_ai/            — TripPlan model, TripAiRepository (Edge Fn),
                          TripAiController (Riverpod), TripAiPage UI

supabase/
  schema.sql            — PostgreSQL DDL + RLS policies
  functions/trip-plan/  — Deno Edge Function (calls Gemini)
```

---

## 5. Key decisions

| Concern | Choice |
|---------|--------|
| State management | Riverpod (`flutter_riverpod ^2.5`) |
| Routing | go_router (`^14`) |
| Backend | Supabase (Auth, DB, Edge Functions) |
| AI calls | Server-side only via `trip-plan` Edge Function → Gemini |
| Notifications | `flutter_local_notifications` (local); FCM stub ready |
| Calendar sync | 1-way import (Google → Supabase) — TODO Phase 2 |
| Recurring rules | Store rule + generate 30-day instances — TODO implement `RecurrenceService` |
