-- ============================================
-- STEP 6: VERIFY SETUP
-- ============================================
-- Run this to verify everything is configured correctly
-- ============================================

-- Check if tables exist
SELECT 'Tables Check' AS check_type;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('user_profiles', 'oauth_providers')
ORDER BY table_name;

-- Check if RLS is enabled
SELECT 'RLS Check' AS check_type;
SELECT
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('user_profiles', 'oauth_providers')
ORDER BY tablename;

-- Check policies count
SELECT 'Policies Check' AS check_type;
SELECT
  tablename,
  COUNT(policyname) AS policy_count
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('user_profiles', 'oauth_providers')
GROUP BY tablename
ORDER BY tablename;

-- Check indexes
SELECT 'Indexes Check' AS check_type;
SELECT
  tablename,
  indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('user_profiles', 'oauth_providers')
ORDER BY tablename, indexname;

-- Check triggers
SELECT 'Triggers Check' AS check_type;
SELECT
  tgname AS trigger_name,
  tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgname IN (
  'on_auth_user_created',
  'update_user_profiles_updated_at',
  'update_oauth_providers_updated_at'
)
ORDER BY tgname;

-- Expected Results:
-- Tables: user_profiles, oauth_providers
-- RLS: Both tables should have rls_enabled = true
-- Policies: user_profiles = 3, oauth_providers = 4
-- Indexes: 5 total indexes
-- Triggers: 3 triggers

-- SUCCESS MESSAGE
DO $$
BEGIN
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'SETUP VERIFICATION COMPLETE';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'If all checks pass, your database is ready!';
  RAISE NOTICE 'Next step: Configure Google OAuth in Supabase Dashboard';
END $$;
