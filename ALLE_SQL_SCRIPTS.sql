-- ========================================
-- FAMILIE-APP - ALLE SQL SCRIPTS
-- Kjør hele denne filen i Supabase SQL Editor
-- ========================================

-- ========================================
-- DEL 1: GRUNNLEGGENDE TABELLER
-- ========================================

-- Handleliste
CREATE TABLE IF NOT EXISTS shopping_items (
  id BIGSERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  quantity INTEGER DEFAULT 1,
  checked BOOLEAN DEFAULT false,
  added_by TEXT NOT NULL,
  added_by_color TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Kalender
CREATE TABLE IF NOT EXISTS calendar_events (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ,
  duration INTEGER DEFAULT 60,
  all_day BOOLEAN DEFAULT false,
  added_by TEXT NOT NULL,
  added_by_color TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Notater
CREATE TABLE IF NOT EXISTS notes (
  id BIGSERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  added_by TEXT NOT NULL,
  added_by_color TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Innstillinger
CREATE TABLE IF NOT EXISTS settings (
  id BIGSERIAL PRIMARY KEY,
  key TEXT UNIQUE NOT NULL,
  value TEXT NOT NULL
);

-- Vedlikehold
CREATE TABLE IF NOT EXISTS maintenance_tasks (
  id BIGSERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  completed BOOLEAN DEFAULT false,
  priority INTEGER NOT NULL,
  added_by TEXT NOT NULL,
  added_by_color TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- DEL 2: UKELØNN TABELLER
-- ========================================

-- Passord
CREATE TABLE IF NOT EXISTS user_passwords (
  user_name TEXT PRIMARY KEY,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Oppgaver
CREATE TABLE IF NOT EXISTS chore_tasks (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  amount INTEGER NOT NULL,
  task_type TEXT NOT NULL,
  category TEXT DEFAULT 'hjemme',
  status TEXT NOT NULL,
  created_by TEXT NOT NULL,
  created_by_color TEXT NOT NULL,
  proposed_by_child BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  approved_by TEXT,
  approved_at TIMESTAMPTZ,
  week_number INTEGER,
  year INTEGER,
  last_reset_week INTEGER,
  last_reset_year INTEGER,
  original_task_id BIGINT,
  deadline TIMESTAMPTZ,
  is_favorite BOOLEAN DEFAULT false
);

-- Oppgave-workers
CREATE TABLE IF NOT EXISTS chore_workers (
  id BIGSERIAL PRIMARY KEY,
  task_id BIGINT REFERENCES chore_tasks(id) ON DELETE CASCADE,
  worker_name TEXT NOT NULL,
  worker_color TEXT NOT NULL,
  percentage INTEGER NOT NULL,
  confirmed BOOLEAN DEFAULT false,
  earned_amount INTEGER,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  approved_at TIMESTAMPTZ,
  approved_by TEXT,
  rejected_at TIMESTAMPTZ,
  rejected_by TEXT
);

-- Deling-forespørsler
CREATE TABLE IF NOT EXISTS chore_split_requests (
  id BIGSERIAL PRIMARY KEY,
  task_id BIGINT REFERENCES chore_tasks(id) ON DELETE CASCADE,
  requester_name TEXT NOT NULL,
  requester_percentage INTEGER NOT NULL,
  partner_name TEXT NOT NULL,
  partner_percentage INTEGER NOT NULL,
  status TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  responded_at TIMESTAMPTZ
);

-- Sparemål
CREATE TABLE IF NOT EXISTS savings_goals (
  id BIGSERIAL PRIMARY KEY,
  child_name TEXT NOT NULL,
  goal_name TEXT NOT NULL,
  target_amount INTEGER NOT NULL,
  current_amount INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed BOOLEAN DEFAULT false
);

-- Utbetalinger
CREATE TABLE IF NOT EXISTS payouts (
  id BIGSERIAL PRIMARY KEY,
  child_name TEXT NOT NULL,
  amount INTEGER NOT NULL,
  paid_by TEXT NOT NULL,
  paid_at TIMESTAMPTZ DEFAULT NOW(),
  note TEXT
);

-- ========================================
-- DEL 3: NYE FUNKSJONER
-- ========================================

-- Profilbilder
CREATE TABLE IF NOT EXISTS user_profiles (
  user_name TEXT PRIMARY KEY,
  profile_image TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Achievements
CREATE TABLE IF NOT EXISTS user_achievements (
  id BIGSERIAL PRIMARY KEY,
  user_name TEXT NOT NULL,
  achievement_type TEXT NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_name, achievement_type)
);

-- Kommentarer
CREATE TABLE IF NOT EXISTS task_comments (
  id BIGSERIAL PRIMARY KEY,
  task_id BIGINT REFERENCES chore_tasks(id) ON DELETE CASCADE,
  worker_id BIGINT REFERENCES chore_workers(id) ON DELETE CASCADE,
  comment_by TEXT NOT NULL,
  comment_text TEXT NOT NULL,
  image_proof TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Streak tracking
CREATE TABLE IF NOT EXISTS user_streaks (
  user_name TEXT PRIMARY KEY,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_task_date DATE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Favoritt oppgaver
CREATE TABLE IF NOT EXISTS favorite_tasks (
  id BIGSERIAL PRIMARY KEY,
  user_name TEXT NOT NULL,
  task_title TEXT NOT NULL,
  task_amount INTEGER NOT NULL,
  task_category TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_name, task_title)
);

-- Oppgave-maler
CREATE TABLE IF NOT EXISTS task_templates (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  amount INTEGER NOT NULL,
  category TEXT NOT NULL,
  task_type TEXT NOT NULL,
  created_by TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- DEL 4: ROW LEVEL SECURITY
-- ========================================

ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_passwords ENABLE ROW LEVEL SECURITY;
ALTER TABLE chore_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE chore_workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE chore_split_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE savings_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorite_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_templates ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Allow all access to shopping_items" ON shopping_items;
DROP POLICY IF EXISTS "Allow all access to calendar_events" ON calendar_events;
DROP POLICY IF EXISTS "Allow all access to notes" ON notes;
DROP POLICY IF EXISTS "Allow all access to settings" ON settings;
DROP POLICY IF EXISTS "Allow all access to maintenance_tasks" ON maintenance_tasks;
DROP POLICY IF EXISTS "Allow all access to user_passwords" ON user_passwords;
DROP POLICY IF EXISTS "Allow all access to chore_tasks" ON chore_tasks;
DROP POLICY IF EXISTS "Allow all access to chore_workers" ON chore_workers;
DROP POLICY IF EXISTS "Allow all access to chore_split_requests" ON chore_split_requests;
DROP POLICY IF EXISTS "Allow all access to savings_goals" ON savings_goals;
DROP POLICY IF EXISTS "Allow all access to payouts" ON payouts;
DROP POLICY IF EXISTS "Allow all access to user_profiles" ON user_profiles;
DROP POLICY IF EXISTS "Allow all access to user_achievements" ON user_achievements;
DROP POLICY IF EXISTS "Allow all access to task_comments" ON task_comments;
DROP POLICY IF EXISTS "Allow all access to user_streaks" ON user_streaks;
DROP POLICY IF EXISTS "Allow all access to favorite_tasks" ON favorite_tasks;
DROP POLICY IF EXISTS "Allow all access to task_templates" ON task_templates;

-- Create new policies
CREATE POLICY "Allow all access to shopping_items" ON shopping_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to calendar_events" ON calendar_events FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to notes" ON notes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to settings" ON settings FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to maintenance_tasks" ON maintenance_tasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to user_passwords" ON user_passwords FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to chore_tasks" ON chore_tasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to chore_workers" ON chore_workers FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to chore_split_requests" ON chore_split_requests FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to savings_goals" ON savings_goals FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to payouts" ON payouts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to user_profiles" ON user_profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to user_achievements" ON user_achievements FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to task_comments" ON task_comments FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to user_streaks" ON user_streaks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to favorite_tasks" ON favorite_tasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access to task_templates" ON task_templates FOR ALL USING (true) WITH CHECK (true);

-- ========================================
-- FERDIG! Alle tabeller og policies opprettet
-- ========================================
