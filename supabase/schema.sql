-- ============================================================
-- Smart Planner & Trip Assistant — Supabase DDL
-- ============================================================
-- Run this in the Supabase SQL Editor (or via supabase db push)
-- after enabling pgcrypto.

create extension if not exists "pgcrypto";

-- ── 1. Profiles ──────────────────────────────────────────────
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  full_name  text,
  avatar_url text,
  timezone   text not null default 'Asia/Jakarta',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ── 2. User Preferences ──────────────────────────────────────
create table if not exists public.preferences (
  user_id           uuid primary key references public.profiles(id) on delete cascade,
  travel_style      text,
  interests         text[]  not null default '{}',
  pace              text,
  budget_daily_limit integer,
  avoid             text[]  not null default '{}',
  updated_at        timestamptz not null default now()
);

-- ── 3. Recurring schedule rules ───────────────────────────────
create table if not exists public.schedule_rules (
  id                    uuid primary key default gen_random_uuid(),
  user_id               uuid not null references public.profiles(id) on delete cascade,
  title                 text not null,
  description           text,
  kind                  text not null check (kind in ('task','event')),
  is_all_day            boolean not null default false,
  default_start_time    time,
  default_end_time      time,
  recurrence_type       text not null check (recurrence_type in ('none','daily','weekly','monthly','custom')),
  interval              integer not null default 1,
  days_of_week          smallint[] not null default '{}',
  start_date            date not null,
  end_date              date,
  notify_before_minutes integer not null default 15,
  is_enabled            boolean not null default true,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

-- ── 4. Schedule instances ─────────────────────────────────────
create table if not exists public.schedule_items (
  id                    uuid primary key default gen_random_uuid(),
  user_id               uuid not null references public.profiles(id) on delete cascade,
  rule_id               uuid references public.schedule_rules(id) on delete set null,
  title                 text not null,
  description           text,
  kind                  text not null check (kind in ('task','event')),
  status                text not null default 'pending' check (status in ('pending','done','cancelled')),
  start_at              timestamptz,
  end_at                timestamptz,
  due_at                timestamptz,
  is_all_day            boolean not null default false,
  source                text not null default 'manual' check (source in ('manual','ai','google_import')),
  external_provider     text,
  external_id           text,
  external_calendar_id  text,
  notify_before_minutes integer,
  notify_enabled        boolean not null default true,
  metadata              jsonb not null default '{}'::jsonb,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create index if not exists idx_schedule_items_user_start
  on public.schedule_items(user_id, start_at);

create index if not exists idx_schedule_items_user_due
  on public.schedule_items(user_id, due_at);

create unique index if not exists uq_google_import
  on public.schedule_items(user_id, external_provider, external_id)
  where external_provider is not null and external_id is not null;

-- ── 5. AI trip plans ─────────────────────────────────────────
create table if not exists public.trip_plans (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles(id) on delete cascade,
  destination text not null,
  start_date  date,
  days        integer not null default 1 check (days between 1 and 7),
  prompt      jsonb not null default '{}'::jsonb,
  response    jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default now()
);

-- ── Row-Level Security ────────────────────────────────────────
alter table public.profiles      enable row level security;
alter table public.preferences   enable row level security;
alter table public.schedule_rules enable row level security;
alter table public.schedule_items enable row level security;
alter table public.trip_plans    enable row level security;

-- Profiles
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

-- Preferences
create policy "preferences_crud_own" on public.preferences
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Rules
create policy "rules_crud_own" on public.schedule_rules
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Items
create policy "items_crud_own" on public.schedule_items
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Trip plans
create policy "trip_plans_crud_own" on public.trip_plans
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
