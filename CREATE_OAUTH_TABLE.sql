-- ============================================
-- GOOGLE OAUTH TABLE CREATION
-- ============================================
-- Copy and paste this entire file into your Supabase SQL Editor
-- Dashboard → SQL Editor → New Query → Paste → Run
-- ============================================

-- Create oauth_providers table
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

-- Enable Row Level Security
ALTER TABLE oauth_providers ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own OAuth providers
CREATE POLICY "Users can view own OAuth providers"
  ON oauth_providers FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own OAuth providers
CREATE POLICY "Users can insert own OAuth providers"
  ON oauth_providers FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own OAuth providers
CREATE POLICY "Users can update own OAuth providers"
  ON oauth_providers FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own OAuth providers
CREATE POLICY "Users can delete own OAuth providers"
  ON oauth_providers FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_oauth_providers_user_id ON oauth_providers(user_id);
CREATE INDEX IF NOT EXISTS idx_oauth_providers_provider ON oauth_providers(provider);
CREATE INDEX IF NOT EXISTS idx_oauth_providers_provider_user_id ON oauth_providers(provider_user_id);

-- Create trigger for updated_at (if the function exists)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column'
  ) THEN
    CREATE TRIGGER update_oauth_providers_updated_at
      BEFORE UPDATE ON oauth_providers
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- ============================================
-- VERIFICATION
-- ============================================
-- Run this query to verify the table was created successfully:
-- SELECT * FROM oauth_providers LIMIT 1;
-- ============================================
