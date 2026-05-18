-- ============================================================
-- Lio Pricing · Per-Module Segment Prices table
-- Run once in the Supabase SQL editor.
-- Stores custom tier prices per (segment, module) pair.
-- When a row exists, it overrides the global segment factor
-- for that specific module only.
-- ============================================================

create table if not exists public.segment_module_prices (
  segment_key  text        not null,
  module_key   text        not null,
  tiers        jsonb       not null default '[]',
  updated_at   timestamptz not null default now(),
  primary key (segment_key, module_key)
);

alter table public.segment_module_prices enable row level security;

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
