# Google Authentication - Quick Start Guide

## 🚀 3-Step Setup

### Step 1: Database Setup (5 minutes)

Open your Supabase Dashboard → SQL Editor and run these files in order:

```bash
1. 01_create_tables.sql      # Creates user_profiles and oauth_providers tables
2. 02_enable_rls.sql          # Enables Row Level Security
3. 03_create_policies.sql     # Creates security policies
4. 04_create_indexes.sql      # Creates performance indexes
5. 05_create_triggers.sql     # Creates auto-profile-creation triggers
6. 06_verify_setup.sql        # Verifies everything works
```

**Quick Copy-Paste Option:**
Run this single command in Supabase SQL Editor (combines all steps):

```sql
-- USER PROFILES TABLE
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

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE oauth_providers ENABLE ROW LEVEL SECURITY;

-- Policies for user_profiles
CREATE POLICY "Users can view own profile" ON user_profiles FOR SELECT TO authenticated USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON user_profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Policies for oauth_providers
CREATE POLICY "Users can view own OAuth providers" ON oauth_providers FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own OAuth providers" ON oauth_providers FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own OAuth providers" ON oauth_providers FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own OAuth providers" ON oauth_providers FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_provider ON user_profiles(provider);
CREATE INDEX IF NOT EXISTS idx_oauth_providers_user_id ON oauth_providers(user_id);
CREATE INDEX IF NOT EXISTS idx_oauth_providers_provider ON oauth_providers(provider);

-- Function: Update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_oauth_providers_updated_at BEFORE UPDATE ON oauth_providers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Auto-create user profile
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, avatar_url, provider)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', NEW.email),
    NEW.raw_user_meta_data->>'avatar_url',
    COALESCE(NEW.raw_app_meta_data->>'provider', 'email')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: Create profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

### Step 2: Google OAuth Setup (5 minutes)

1. **Google Cloud Console** (https://console.cloud.google.com/):
   - Create/Select Project
   - APIs & Services → Credentials
   - Create OAuth 2.0 Client ID
   - Application type: **Web application**
   - Authorized redirect URIs: `https://esyodlvfhztvowabjudx.supabase.co/auth/v1/callback`
   - Save **Client ID** and **Client Secret**

2. **Supabase Dashboard**:
   - Authentication → Providers
   - Enable **Google**
   - Paste Client ID and Client Secret
   - Click **Save**

### Step 3: Test It (2 minutes)

1. Start your app: `npm run dev`
2. Navigate to login page
3. Click "Continue with Google"
4. Sign in with Google account
5. ✅ You should be logged in!

---

## 📁 Files in This Project

### SQL Files (Database)
- `01_create_tables.sql` - Creates database tables
- `02_enable_rls.sql` - Enables security
- `03_create_policies.sql` - Creates access policies
- `04_create_indexes.sql` - Optimizes performance
- `05_create_triggers.sql` - Auto-creates user profiles
- `06_verify_setup.sql` - Verifies everything works

### Documentation
- `COMPLETE_GOOGLE_AUTH_GUIDE.md` - Full implementation guide
- `GOOGLE_LOGIN_SETUP.md` - Original setup instructions
- `GOOGLE_AUTH_QUICKSTART.md` - This file

### Frontend Code
Google login is already implemented in:
- `src/contexts/AuthContext.tsx` - Authentication logic
- `src/components/views/LoginView.tsx` - Login page with Google button
- `src/components/views/SignupView.tsx` - Signup page with Google button

---

## ✅ What's Already Working

Your app already has:
- ✅ Google login button UI
- ✅ OAuth flow handling
- ✅ Automatic profile creation
- ✅ Session management
- ✅ Sign out functionality
- ✅ Error handling

You just need to:
1. Create the database tables (Step 1)
2. Configure Google OAuth credentials (Step 2)

---

## 🔍 Verification

After setup, verify with these SQL queries in Supabase:

```sql
-- Check tables exist
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('user_profiles', 'oauth_providers');

-- Check after login: View user profiles
SELECT * FROM user_profiles ORDER BY created_at DESC LIMIT 5;

-- Check RLS is working
SELECT tablename, rowsecurity FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('user_profiles', 'oauth_providers');
```

---

## 🐛 Troubleshooting

**"Redirect URI mismatch"**
- Verify in Google Cloud Console: `https://esyodlvfhztvowabjudx.supabase.co/auth/v1/callback`

**"Table does not exist"**
- Run the database setup SQL again
- Check Supabase Table Editor to confirm tables exist

**"Invalid credentials"**
- Re-check Client ID and Client Secret in Supabase Dashboard
- Make sure you copied them correctly from Google Cloud Console

**Profile not created**
- Check if trigger exists: Run `06_verify_setup.sql`
- Manually check: `SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';`

---

## 📞 Need Help?

1. Check `COMPLETE_GOOGLE_AUTH_GUIDE.md` for detailed explanations
2. Review code in `src/contexts/AuthContext.tsx`
3. Check Supabase logs in Dashboard → Logs
4. Verify Google OAuth settings in Google Cloud Console

---

## 🎉 That's It!

Your Google authentication is production-ready once you complete the 3 steps above!
