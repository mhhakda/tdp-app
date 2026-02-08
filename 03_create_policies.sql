-- ============================================
-- STEP 3: CREATE RLS POLICIES
-- ============================================
-- Run this after enabling RLS
-- ============================================

-- ============================================
-- USER_PROFILES POLICIES
-- ============================================

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Policy: Users can insert their own profile
CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================
-- OAUTH_PROVIDERS POLICIES
-- ============================================

-- Policy: Users can view their own OAuth providers
CREATE POLICY "Users can view own OAuth providers"
  ON oauth_providers FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own OAuth providers
CREATE POLICY "Users can insert own OAuth providers"
  ON oauth_providers FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own OAuth providers
CREATE POLICY "Users can update own OAuth providers"
  ON oauth_providers FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own OAuth providers
CREATE POLICY "Users can delete own OAuth providers"
  ON oauth_providers FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- SUCCESS MESSAGE
DO $$
BEGIN
  RAISE NOTICE 'All RLS policies created successfully!';
END $$;
