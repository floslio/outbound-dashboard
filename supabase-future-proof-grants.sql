-- ============================================================
-- Future-proof migration: explicit GRANTs for all Lio tables
-- ============================================================
-- Why: Supabase is removing the implicit public-schema GRANTs
-- on Oct 30, 2026. Without explicit privileges, PostgREST will
-- return 401/403 for anon-key requests even when RLS policies
-- allow access.
--
-- This migration is idempotent — safe to re-run. Run it once
-- now to lock in privileges before the deadline.
-- Supabase Dashboard → SQL Editor → paste → Run.
-- ============================================================

-- 1. quotes — main quote history
grant select, insert, update, delete on public.quotes to anon, authenticated;
-- if the table has a serial PK, also grant the sequence:
do $$ begin
  if exists (select 1 from pg_class where relname = 'quotes_id_seq') then
    execute 'grant usage, select on sequence public.quotes_id_seq to anon, authenticated';
  end if;
end $$;

-- 2. roi_calculations — ROI calculator
grant select, insert, update, delete on public.roi_calculations to anon, authenticated;
grant usage, select on sequence public.roi_calculations_id_seq to anon, authenticated;

-- 3. custom_modules — team-shared module library
grant select, insert, update, delete on public.custom_modules to anon, authenticated;
do $$ begin
  if exists (select 1 from pg_class where relname = 'custom_modules_id_seq') then
    execute 'grant usage, select on sequence public.custom_modules_id_seq to anon, authenticated';
  end if;
end $$;

-- 4. segment_factors — per-segment pricing multipliers
grant select, insert, update, delete on public.segment_factors to anon, authenticated;

-- 5. segment_module_prices — per-(segment, module) custom tier prices
grant select, insert, update, delete on public.segment_module_prices to anon, authenticated;

-- 6. manual_activities — outbound dashboard activities
do $$ begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='manual_activities') then
    execute 'grant select, insert, update, delete on public.manual_activities to anon, authenticated';
    if exists (select 1 from pg_class where relname = 'manual_activities_id_seq') then
      execute 'grant usage, select on sequence public.manual_activities_id_seq to anon, authenticated';
    end if;
  end if;
end $$;

-- Verify
select
  table_name,
  string_agg(privilege_type, ', ' order by privilege_type) as privileges
from information_schema.role_table_grants
where grantee = 'anon'
  and table_schema = 'public'
  and table_name in (
    'quotes', 'roi_calculations', 'custom_modules',
    'segment_factors', 'segment_module_prices', 'manual_activities'
  )
group by table_name
order by table_name;
