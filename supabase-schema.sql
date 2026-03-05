-- Run this in Supabase SQL Editor if visit_entries doesn't exist or has wrong schema
-- Matches the app's expected columns: id, company_name, contact_person, latitude, longitude, notes, visit_date, device_id

CREATE TABLE IF NOT EXISTS visit_entries (
  id UUID PRIMARY KEY,
  company_name TEXT NOT NULL,
  contact_person TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  notes TEXT DEFAULT '',
  visit_date TIMESTAMPTZ NOT NULL,
  device_id TEXT
);

-- RLS: service_role key (used by iOS app) bypasses RLS. For anon (dashboard), allow read.
ALTER TABLE visit_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anon select" ON visit_entries FOR SELECT USING (true);
CREATE POLICY "Allow anon insert" ON visit_entries FOR INSERT WITH CHECK (true);
