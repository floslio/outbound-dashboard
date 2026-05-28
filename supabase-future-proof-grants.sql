-- ============================================================
-- Future-proof migration: explicit GRANTs for all Lio tables
-- ============================================================
-- Why: Supabase is removing the implicit public-schema GRANTs
-- on Oct 30, 2026. Without explicit privileges, PostgREST will
-- return 401/403 for anon-key requests even when RLS policies
-- allow access.
--
-- This migration is idempotent + DEFENSIVE — every table grant
-- is wrapped in an existence check so missing tables don't
-- abort the whole transaction. Safe to re-run any time.
-- Supabase Dashboard → SQL Editor → paste → Run.
-- ============================================================

-- Helper: grant CRUD on a table only if it exists (and its
-- *_id_seq sequence too when one is present).
do $$
declare
  t text;
  tables text[] := array[
    'quotes',
    'roi_calculations',
    'custom_modules',
    'segment_factors',
    'segment_module_prices',
    'manual_activities'
  ];
begin
  foreach t in array tables loop
    if exists (
      select 1 from information_schema.tables
      where table_schema = 'public' and table_name = t
    ) then
      execute format(
        'grant select, insert, update, delete on public.%I to anon, authenticated',
        t
      );
      -- Also grant the matching sequence if the table uses a SERIAL/IDENTITY PK.
      if exists (select 1 from pg_class where relname = t || '_id_seq') then
        execute format(
          'grant usage, select on sequence public.%I to anon, authenticated',
          t || '_id_seq'
        );
      end if;
      raise notice 'Granted: public.%', t;
    else
      raise notice 'Skipped (does not exist): public.%', t;
    end if;
  end loop;
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
