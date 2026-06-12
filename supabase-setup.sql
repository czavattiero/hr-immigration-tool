-- ============================================================
-- Supabase setup script for HR Immigration Tool
-- Run this once in the Supabase SQL Editor:
--   https://supabase.com/dashboard → your project → SQL Editor
-- ============================================================

-- 1. Create the table (safe to run more than once)
CREATE TABLE IF NOT EXISTS hr_tool_data (
  id          BIGSERIAL PRIMARY KEY,
  title       TEXT NOT NULL UNIQUE,   -- UNIQUE required for upsert (on_conflict=title)
  content     TEXT,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Keep a current timestamp whenever a row is updated
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_hr_tool_data_updated_at ON hr_tool_data;
CREATE TRIGGER trg_hr_tool_data_updated_at
  BEFORE UPDATE ON hr_tool_data
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 3. Grant the anonymous role full access
--    The app uses the public anon key, so the anon role must be able to
--    read and write rows.  The simplest approach is to disable RLS:
ALTER TABLE hr_tool_data DISABLE ROW LEVEL SECURITY;

-- Alternative: keep RLS enabled and add explicit policies instead:
--   ALTER TABLE hr_tool_data ENABLE ROW LEVEL SECURITY;
--   CREATE POLICY "anon_select" ON hr_tool_data FOR SELECT TO anon USING (true);
--   CREATE POLICY "anon_insert" ON hr_tool_data FOR INSERT TO anon WITH CHECK (true);
--   CREATE POLICY "anon_update" ON hr_tool_data FOR UPDATE TO anon USING (true) WITH CHECK (true);
