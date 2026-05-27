-- ============================================
-- Lio Pricing Platform — ROI Calculations Table
-- Run this in: Supabase Dashboard > SQL Editor
-- ============================================

-- 1. ROI Calculations Table
CREATE TABLE IF NOT EXISTS roi_calculations (
  id BIGSERIAL PRIMARY KEY,
  roi_ref TEXT NOT NULL UNIQUE,
  company TEXT,
  contact_name TEXT,
  lio_contact TEXT DEFAULT 'florian',
  currency TEXT DEFAULT 'usd',
  inputs JSONB NOT NULL DEFAULT '{}'::jsonb,
  lio_investment NUMERIC DEFAULT 0,
  annual_savings NUMERIC DEFAULT 0,
  roi_x NUMERIC DEFAULT 0,
  payback_months NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_edited_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Indexes
CREATE INDEX IF NOT EXISTS idx_roi_ref ON roi_calculations(roi_ref);
CREATE INDEX IF NOT EXISTS idx_roi_company ON roi_calculations(company);
CREATE INDEX IF NOT EXISTS idx_roi_last_edited ON roi_calculations(last_edited_at DESC);

-- 3. Row Level Security
ALTER TABLE roi_calculations ENABLE ROW LEVEL SECURITY;

-- 4. Explicit table privileges — REQUIRED for new Supabase projects after
-- May 30, 2026 and enforced on existing projects after Oct 30, 2026.
-- Without these, PostgREST returns 401/403 even when RLS policies allow access.
GRANT SELECT, INSERT, UPDATE, DELETE ON roi_calculations TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE roi_calculations_id_seq TO anon, authenticated;

-- 5. Policies (anon key access — internal tool)
CREATE POLICY "roi_allow_read"   ON roi_calculations FOR SELECT USING (true);
CREATE POLICY "roi_allow_insert" ON roi_calculations FOR INSERT WITH CHECK (true);
CREATE POLICY "roi_allow_update" ON roi_calculations FOR UPDATE USING (true);
CREATE POLICY "roi_allow_delete" ON roi_calculations FOR DELETE USING (true);

-- 6. Verify
SELECT 'ROI setup complete! Table roi_calculations ready.' AS status;
