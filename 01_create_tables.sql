-- ============================================
-- STEP 1: CREATE TABLES
-- ============================================
-- Copy and paste this entire file into Supabase SQL Editor
-- ============================================

-- USER PROFILES TABLE
-- Stores additional user information beyond Supabase Auth
CREATE TABLE IF NOT EXISTS user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  full_name text,
  avatar_url text,
  provider text CHECK (provider IN ('google', 'email', 'facebook', 'github')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- OAUTH PROVIDERS TABLE
-- Tracks OAuth connections and tokens
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

-- SUCCESS MESSAGE
DO $$
BEGIN
  RAISE NOTICE 'Tables created successfully!';
END $$;
