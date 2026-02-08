-- ============================================
-- STEP 4: CREATE INDEXES
-- ============================================
-- Run this to improve query performance
-- ============================================

-- Indexes for user_profiles
CREATE INDEX IF NOT EXISTS idx_user_profiles_email
  ON user_profiles(email);

CREATE INDEX IF NOT EXISTS idx_user_profiles_provider
  ON user_profiles(provider);

-- Indexes for oauth_providers
CREATE INDEX IF NOT EXISTS idx_oauth_providers_user_id
  ON oauth_providers(user_id);

CREATE INDEX IF NOT EXISTS idx_oauth_providers_provider
  ON oauth_providers(provider);

CREATE INDEX IF NOT EXISTS idx_oauth_providers_provider_user_id
  ON oauth_providers(provider_user_id);

-- SUCCESS MESSAGE
DO $$
BEGIN
  RAISE NOTICE 'All indexes created successfully!';
END $$;
