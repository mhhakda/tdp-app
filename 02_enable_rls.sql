-- ============================================
-- STEP 2: ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================
-- Run this after creating tables
-- ============================================

-- Enable RLS on user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Enable RLS on oauth_providers
ALTER TABLE oauth_providers ENABLE ROW LEVEL SECURITY;

-- SUCCESS MESSAGE
DO $$
BEGIN
  RAISE NOTICE 'RLS enabled on all tables!';
END $$;
