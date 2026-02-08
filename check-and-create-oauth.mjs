import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://esyodlvfhztvowabjudx.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVzeW9kbHZmaHp0dm93YWJqdWR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5NTgxMDAsImV4cCI6MjA3NTUzNDEwMH0.HlptkCaFSe0_Ube4r4J42AL_yzF8kkiEaOOlXj5HISM';

const supabase = createClient(supabaseUrl, supabaseKey);

console.log('Checking for oauth_providers table...');

// Check if table exists
const { error: checkError } = await supabase
  .from('oauth_providers')
  .select('id')
  .limit(1);

if (checkError && checkError.code === '42P01') {
  console.log('Table does not exist. Creating it now...');
  console.log('');
  console.log('Please run this SQL in your Supabase SQL Editor:');
  console.log('-----------------------------------------------');
  console.log(`
CREATE TABLE IF NOT EXISTS oauth_providers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  provider text NOT NULL CHECK (provider IN ('google', 'facebook', 'github', 'apple')),
  provider_user_id text NOT NULL,
  email text,
  display_name text,
  avatar_url text,
  access_token text,
  refresh_token text,
  token_expires_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, provider)
);

ALTER TABLE oauth_providers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own OAuth providers"
  ON oauth_providers FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own OAuth providers"
  ON oauth_providers FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own OAuth providers"
  ON oauth_providers FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own OAuth providers"
  ON oauth_providers FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_oauth_providers_user_id ON oauth_providers(user_id);
CREATE INDEX IF NOT EXISTS idx_oauth_providers_provider ON oauth_providers(provider);
CREATE INDEX IF NOT EXISTS idx_oauth_providers_provider_user_id ON oauth_providers(provider_user_id);

CREATE TRIGGER update_oauth_providers_updated_at
  BEFORE UPDATE ON oauth_providers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
  `);
  console.log('-----------------------------------------------');
} else if (checkError) {
  console.error('Error checking table:', checkError);
} else {
  console.log('✅ Table already exists!');
}
