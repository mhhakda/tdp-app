# Complete Supabase Google Authentication Setup Guide

This is a comprehensive, production-ready guide for implementing Google OAuth authentication with Supabase.

---

## Part 1: Database Table Creation

### Step 1: Run SQL in Supabase SQL Editor

Go to your **Supabase Dashboard** → **SQL Editor** → **New Query**, then copy and paste this entire SQL script:

```sql
-- ============================================
-- GOOGLE AUTHENTICATION DATABASE SETUP
-- ============================================

-- 1. USER PROFILES TABLE
-- Stores additional user information beyond what Supabase Auth provides
CREATE TABLE IF NOT EXISTS user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  full_name text,
  avatar_url text,
  provider text CHECK (provider IN ('google', 'email', 'facebook', 'github')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS on user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_profiles
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_provider ON user_profiles(provider);

-- ============================================

-- 2. OAUTH PROVIDERS TABLE
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

-- Enable RLS on oauth_providers
ALTER TABLE oauth_providers ENABLE ROW LEVEL SECURITY;

-- RLS Policies for oauth_providers
CREATE POLICY "Users can view own OAuth providers"
  ON oauth_providers FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own OAuth providers"
  ON oauth_providers FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own OAuth providers"
  ON oauth_providers FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own OAuth providers"
  ON oauth_providers FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Indexes for oauth_providers
CREATE INDEX IF NOT EXISTS idx_oauth_providers_user_id ON oauth_providers(user_id);
CREATE INDEX IF NOT EXISTS idx_oauth_providers_provider ON oauth_providers(provider);

-- ============================================

-- 3. UTILITY FUNCTION: Update timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_oauth_providers_updated_at
  BEFORE UPDATE ON oauth_providers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================

-- 4. FUNCTION: Handle new user creation (Auto-create profile)
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

-- Trigger: Automatically create profile on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();
```

### Step 2: Verify Tables Were Created

Run this verification query:

```sql
-- Check tables and RLS status
SELECT
  t.tablename,
  t.rowsecurity AS rls_enabled,
  COUNT(p.policyname) AS policy_count
FROM pg_tables t
LEFT JOIN pg_policies p ON t.tablename = p.tablename
WHERE t.schemaname = 'public'
  AND t.tablename IN ('user_profiles', 'oauth_providers')
GROUP BY t.tablename, t.rowsecurity;
```

**Expected Output:**
- `user_profiles` - rls_enabled: `true`, policy_count: `3`
- `oauth_providers` - rls_enabled: `true`, policy_count: `4`

---

## Part 2: Google Cloud Console Setup

### Step 1: Create OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth 2.0 Client ID**
5. Configure OAuth consent screen (if not done):
   - **User Type**: External
   - **App name**: Your App Name
   - **User support email**: your-email@example.com
   - **Developer contact**: your-email@example.com
   - Click **Save and Continue**
6. For **Application type**, select: **Web application**
7. **Name**: "Your App - Production" (or any name)

### Step 2: Configure Authorized URLs

**Authorized JavaScript origins:**
```
http://localhost:5173
https://yourdomain.com
```

**Authorized redirect URIs:**
```
https://esyodlvfhztvowabjudx.supabase.co/auth/v1/callback
http://localhost:5173
```

### Step 3: Save Credentials

After clicking **Create**, save these values:
- **Client ID**: `1234567890-abc123def456.apps.googleusercontent.com`
- **Client Secret**: `GOCSPX-xxxxxxxxxxxxxxxxxxxxx`

---

## Part 3: Supabase Dashboard Configuration

### Step 1: Enable Google Provider

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Navigate to **Authentication** → **Providers**
4. Find **Google** in the list
5. Toggle **Enable** to ON

### Step 2: Add Google Credentials

Paste the credentials from Google Cloud Console:
- **Client ID**: Your Google Client ID
- **Client Secret**: Your Google Client Secret

### Step 3: Configure Redirect URL (if needed)

The default should be:
```
https://esyodlvfhztvowabjudx.supabase.co/auth/v1/callback
```

Click **Save** when done.

---

## Part 4: Frontend Integration

### Installation

```bash
npm install @supabase/supabase-js
```

### Environment Variables

Create `.env` file:

```env
VITE_SUPABASE_URL=https://esyodlvfhztvowabjudx.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

### Supabase Client Setup

**File: `src/lib/supabase.ts`**

```typescript
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
```

### TypeScript Types

**File: `src/types/auth.ts`**

```typescript
export interface User {
  id: string;
  email: string;
  full_name?: string;
  avatar_url?: string;
  provider?: 'google' | 'email' | 'facebook' | 'github';
  created_at: string;
}

export interface AuthState {
  user: User | null;
  loading: boolean;
  error: string | null;
}
```

### Google Sign-In Button Component

**File: `src/components/GoogleSignInButton.tsx`**

```typescript
import { useState } from 'react';
import { supabase } from '../lib/supabase';

interface GoogleSignInButtonProps {
  onSuccess?: () => void;
  onError?: (error: string) => void;
}

export function GoogleSignInButton({
  onSuccess,
  onError
}: GoogleSignInButtonProps) {
  const [loading, setLoading] = useState(false);

  const handleGoogleSignIn = async () => {
    try {
      setLoading(true);

      // Initiate Google OAuth flow
      const { error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}`,
          queryParams: {
            access_type: 'offline',
            prompt: 'select_account',
          },
        },
      });

      if (error) throw error;

      // OAuth flow initiated successfully
      // User will be redirected to Google
      onSuccess?.();
    } catch (error) {
      console.error('Error signing in with Google:', error);
      const errorMessage = error instanceof Error
        ? error.message
        : 'Failed to sign in with Google';
      onError?.(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <button
      onClick={handleGoogleSignIn}
      disabled={loading}
      className="flex items-center justify-center gap-3 w-full px-4 py-3 bg-white border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
    >
      {/* Google Logo SVG */}
      <svg className="w-5 h-5" viewBox="0 0 24 24">
        <path
          fill="#4285F4"
          d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
        />
        <path
          fill="#34A853"
          d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
        />
        <path
          fill="#FBBC05"
          d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
        />
        <path
          fill="#EA4335"
          d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
        />
      </svg>

      {loading ? 'Signing in...' : 'Continue with Google'}
    </button>
  );
}
```

### Authentication Hook

**File: `src/hooks/useAuth.ts`**

```typescript
import { useEffect, useState } from 'react';
import { User } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';
import { User as AppUser } from '../types/auth';

export function useAuth() {
  const [user, setUser] = useState<AppUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Check active session
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        loadUserProfile(session.user);
      } else {
        setLoading(false);
      }
    });

    // Listen for auth changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (event === 'SIGNED_IN' && session?.user) {
        await loadUserProfile(session.user);
      } else if (event === 'SIGNED_OUT') {
        setUser(null);
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const loadUserProfile = async (authUser: User) => {
    try {
      setLoading(true);
      setError(null);

      // Fetch user profile from user_profiles table
      const { data: profile, error: profileError } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('id', authUser.id)
        .maybeSingle();

      if (profileError) {
        console.error('Error loading profile:', profileError);
        setError(profileError.message);
      }

      setUser(profile);
    } catch (err) {
      console.error('Error:', err);
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  const signOut = async () => {
    try {
      setLoading(true);
      setError(null);

      const { error } = await supabase.auth.signOut();
      if (error) throw error;

      setUser(null);
    } catch (err) {
      console.error('Error signing out:', err);
      setError(err instanceof Error ? err.message : 'Failed to sign out');
    } finally {
      setLoading(false);
    }
  };

  return {
    user,
    loading,
    error,
    signOut,
    isAuthenticated: !!user,
  };
}
```

### Complete Login Page Example

**File: `src/pages/Login.tsx`**

```typescript
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { GoogleSignInButton } from '../components/GoogleSignInButton';
import { useAuth } from '../hooks/useAuth';

export function LoginPage() {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const [error, setError] = useState<string | null>(null);

  // Redirect if already authenticated
  useEffect(() => {
    if (isAuthenticated) {
      navigate('/dashboard');
    }
  }, [isAuthenticated, navigate]);

  const handleGoogleSuccess = () => {
    console.log('Google OAuth initiated');
    // User will be redirected to Google
  };

  const handleGoogleError = (errorMessage: string) => {
    setError(errorMessage);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="max-w-md w-full space-y-8">
        <div className="text-center">
          <h2 className="text-3xl font-bold text-gray-900">
            Welcome Back
          </h2>
          <p className="mt-2 text-gray-600">
            Sign in to your account
          </p>
        </div>

        <div className="bg-white rounded-lg shadow-md p-8">
          {error && (
            <div className="mb-4 p-4 bg-red-50 border border-red-200 text-red-700 rounded-lg">
              {error}
            </div>
          )}

          <GoogleSignInButton
            onSuccess={handleGoogleSuccess}
            onError={handleGoogleError}
          />

          <div className="mt-6 text-center text-sm text-gray-600">
            By signing in, you agree to our Terms of Service and Privacy Policy
          </div>
        </div>
      </div>
    </div>
  );
}
```

### User Profile Display

**File: `src/components/UserProfile.tsx`**

```typescript
import { useAuth } from '../hooks/useAuth';

export function UserProfile() {
  const { user, loading, signOut } = useAuth();

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!user) {
    return <div>Not authenticated</div>;
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <div className="flex items-center gap-4">
        {user.avatar_url && (
          <img
            src={user.avatar_url}
            alt={user.full_name || 'User'}
            className="w-16 h-16 rounded-full"
          />
        )}

        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900">
            {user.full_name || 'User'}
          </h3>
          <p className="text-sm text-gray-600">{user.email}</p>
          {user.provider && (
            <span className="inline-block mt-1 px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded">
              Signed in with {user.provider}
            </span>
          )}
        </div>

        <button
          onClick={signOut}
          className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
        >
          Sign Out
        </button>
      </div>
    </div>
  );
}
```

---

## Part 5: Testing & Verification

### Testing Checklist

1. **Test Google Sign-In**
   - [ ] Click "Continue with Google"
   - [ ] Redirected to Google login page
   - [ ] Select Google account
   - [ ] Redirected back to your app
   - [ ] User profile created in database

2. **Verify Database**
   ```sql
   -- Check if user profile was created
   SELECT * FROM user_profiles ORDER BY created_at DESC LIMIT 5;

   -- Check auth users
   SELECT id, email, created_at FROM auth.users ORDER BY created_at DESC LIMIT 5;
   ```

3. **Test Sign-Out**
   - [ ] Click sign out button
   - [ ] Session cleared
   - [ ] Redirected to login page

### Common Issues & Solutions

**Issue: "Redirect URI mismatch"**
- **Solution**: Verify the redirect URI in Google Cloud Console matches exactly:
  `https://esyodlvfhztvowabjudx.supabase.co/auth/v1/callback`

**Issue: "User profile not created"**
- **Solution**: Check that the `handle_new_user()` trigger is active:
  ```sql
  SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
  ```

**Issue: "Invalid credentials"**
- **Solution**: Double-check Client ID and Client Secret in Supabase Dashboard

**Issue: "CORS error"**
- **Solution**: Ensure your domain is added to authorized JavaScript origins in Google Cloud Console

---

## Part 6: Production Deployment

### Pre-Deployment Checklist

- [ ] Update authorized JavaScript origins with production domain
- [ ] Update authorized redirect URIs with production domain
- [ ] Set up environment variables in production environment
- [ ] Test OAuth flow in production environment
- [ ] Enable email notifications in Supabase (optional)
- [ ] Set up error monitoring (Sentry, etc.)
- [ ] Review and test RLS policies
- [ ] Set up database backups

### Security Best Practices

1. **Never commit secrets to git**
   ```bash
   # Add to .gitignore
   .env
   .env.local
   .env.production
   ```

2. **Use environment variables**
   - Store all sensitive data in environment variables
   - Use different credentials for dev/staging/production

3. **Implement rate limiting**
   - Add rate limiting to prevent abuse
   - Monitor failed login attempts

4. **Regular security audits**
   - Review RLS policies regularly
   - Update dependencies
   - Monitor Supabase logs

---

## Part 7: Advanced Features

### Email + Google Linking

Allow users to link Google account to existing email account:

```typescript
async function linkGoogleAccount() {
  const { error } = await supabase.auth.linkIdentity({
    provider: 'google',
  });

  if (error) {
    console.error('Error linking Google account:', error);
  }
}
```

### OAuth Token Storage

Save OAuth tokens for API access:

```typescript
async function saveOAuthTokens(userId: string, session: any) {
  const { error } = await supabase
    .from('oauth_providers')
    .upsert({
      user_id: userId,
      provider: 'google',
      provider_user_id: session.user.identities[0].id,
      email: session.user.email,
      access_token: session.provider_token,
      refresh_token: session.provider_refresh_token,
      token_expires_at: new Date(Date.now() + 3600000).toISOString(),
    });

  if (error) {
    console.error('Error saving OAuth tokens:', error);
  }
}
```

### Session Refresh

Handle token refresh automatically:

```typescript
supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'TOKEN_REFRESHED') {
    console.log('Session refreshed');
    // Update stored tokens if needed
  }
});
```

---

## Support & Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Supabase Discord Community](https://discord.supabase.com)
- [Stack Overflow - Supabase Tag](https://stackoverflow.com/questions/tagged/supabase)

---

## Summary

You now have a complete, production-ready Google authentication system with:

✅ Secure database tables with RLS
✅ Automatic profile creation on signup
✅ Google OAuth integration
✅ TypeScript types and hooks
✅ Error handling and loading states
✅ User session management
✅ Sign-out functionality

The system is ready for production use!
