-- ============================================================
-- Lio Pricing · Segment Factors table
-- Run this once in the Supabase SQL editor to enable
-- team-shared segment pricing multipliers with persistence.
-- ============================================================

create table if not exists public.segment_factors (
  segment_key text primary key,       -- 'fortune500', 'dax40', 'midmarket', 'mittelstand', 'custom'
  factor      numeric   not null default 1.0,
  label       text,
  currency    text,                    -- 'usd', 'eur', 'gbp', 'chf', or null
  updated_at  timestamptz not null default now()
);

-- Enable Row Level Security (anon key can read + write — same pattern as quotes table)
alter table public.segment_factors enable row level security;

-- Explicit table privileges — REQUIRED for new Supabase projects after
-- May 30, 2026 and enforced on existing projects after Oct 30, 2026.
-- Without these, PostgREST returns 401/403 even when RLS policies allow access.
grant select, insert, update, delete on public.segment_factors to anon, authenticated;

create policy "anon_select" on public.segment_factors for select using (true);
create policy "anon_insert" on public.segment_factors for insert with check (true);
create policy "anon_update" on public.segment_factors for update using (true);
create policy "anon_upsert" on public.segment_factors for insert with check (true);

-- Seed with defaults (safe to re-run: on conflict does nothing)
insert into public.segment_factors (segment_key, factor, label, currency)
values
  ('fortune500',  1.50, 'Fortune 500',           'usd'),
  ('dax40',       1.25, 'DAX 40',                'eur'),
  ('midmarket',   0.85, 'Mid Market (US)',        'usd'),
  ('mittelstand', 0.70, 'German Mittelstand',     'eur'),
  ('custom',      1.00, 'Custom',                 null)
on conflict (segment_key) do nothing;
