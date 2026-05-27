-- ============================================
-- Lio Outbound Dashboard — Supabase Setup
-- Run this in: Supabase Dashboard > SQL Editor
-- ============================================

-- 1. Manual Activities Table
CREATE TABLE IF NOT EXISTS manual_activities (
  id BIGSERIAL PRIMARY KEY,
  person TEXT NOT NULL,
  activity_type TEXT NOT NULL CHECK (activity_type IN ('linkedin', 'linkedin_demo', 'outreach_email', 'followup_email', 'cold_call', 'followup_call', 'demo', 'cold_call_demo')),
  count INTEGER NOT NULL DEFAULT 1 CHECK (count > 0),
  activity_date DATE NOT NULL,
  note TEXT DEFAULT '',
  created_by TEXT DEFAULT 'dashboard',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_manual_date ON manual_activities(activity_date);
CREATE INDEX IF NOT EXISTS idx_manual_person ON manual_activities(person);
CREATE INDEX IF NOT EXISTS idx_manual_type ON manual_activities(activity_type);

-- 3. Enable Row Level Security
ALTER TABLE manual_activities ENABLE ROW LEVEL SECURITY;

-- 4. Explicit table privileges — REQUIRED for new Supabase projects after
-- May 30, 2026 and enforced on existing projects after Oct 30, 2026.
-- Without these, PostgREST returns 401/403 even when RLS policies allow access.
GRANT SELECT, INSERT, UPDATE, DELETE ON manual_activities TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE manual_activities_id_seq TO anon, authenticated;

-- 5. RLS Policies — allow all operations with anon key (team-internal tool)
CREATE POLICY "allow_read" ON manual_activities FOR SELECT USING (true);
CREATE POLICY "allow_insert" ON manual_activities FOR INSERT WITH CHECK (true);
CREATE POLICY "allow_delete" ON manual_activities FOR DELETE USING (true);
CREATE POLICY "allow_update" ON manual_activities FOR UPDATE USING (true);

-- 6. Fix CHECK constraint (run this if table already exists)
-- ALTER TABLE manual_activities DROP CONSTRAINT IF EXISTS manual_activities_activity_type_check;
-- ALTER TABLE manual_activities ADD CONSTRAINT manual_activities_activity_type_check
--   CHECK (activity_type IN ('linkedin','linkedin_demo','outreach_email','followup_email','cold_call','followup_call','demo','cold_call_demo'));

-- 7. Verify setup
SELECT 'Setup complete! Table manual_activities created.' AS status;
