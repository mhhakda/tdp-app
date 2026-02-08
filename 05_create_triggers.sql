-- ============================================
-- STEP 5: CREATE TRIGGERS AND FUNCTIONS
-- ============================================
-- Run this to enable automatic profile creation
-- ============================================

-- Function: Update timestamp automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Update user_profiles.updated_at on update
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger: Update oauth_providers.updated_at on update
CREATE TRIGGER update_oauth_providers_updated_at
  BEFORE UPDATE ON oauth_providers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function: Automatically create user profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, avatar_url, provider)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',
      NEW.email
    ),
    NEW.raw_user_meta_data->>'avatar_url',
    COALESCE(
      NEW.raw_app_meta_data->>'provider',
      'email'
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: Create profile when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- SUCCESS MESSAGE
DO $$
BEGIN
  RAISE NOTICE 'All triggers and functions created successfully!';
  RAISE NOTICE 'User profiles will now be created automatically on signup!';
END $$;
