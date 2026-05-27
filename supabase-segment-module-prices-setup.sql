-- ============================================================
-- Lio Pricing · Per-Module Segment Prices table
-- Run once in the Supabase SQL editor.
-- Stores custom tier prices per (segment, module) pair.
-- When a row exists, it overrides the global segment factor
-- for that specific module only.
-- ============================================================

create table if not exists public.segment_module_prices (
  segment_key  text        not null,       -- 'fortune500', 'dax40', 'midmarket', 'mittelstand', 'custom'
  module_key   text        not null,       -- e.g. 'pia', 'na', 'gb2po'
  tiers        jsonb       not null default '[]',  -- [{vol, price, eur?, gbp?, chf?}, ...]
  updated_at   timestamptz not null default now(),
  primary key (segment_key, module_key)
);

alter table public.segment_module_prices enable row level security;

-- Explicit table privileges — REQUIRED for new Supabase projects after
-- May 30, 2026 and enforced on existing projects after Oct 30, 2026.
-- Without these, PostgREST returns 401/403 even when RLS policies allow access.
grant select, insert, update, delete on public.segment_module_prices to anon, authenticated;

do $$ begin
  if not exists (select 1 from pg_policies where tablename='segment_module_prices' and policyname='smp_select') then
    create policy "smp_select" on public.segment_module_prices for select using (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='segment_module_prices' and policyname='smp_insert') then
    create policy "smp_insert" on public.segment_module_prices for insert with check (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='segment_module_prices' and policyname='smp_update') then
    create policy "smp_update" on public.segment_module_prices for update using (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='segment_module_prices' and policyname='smp_delete') then
    create policy "smp_delete" on public.segment_module_prices for delete using (true);
  end if;
end $$;
