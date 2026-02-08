# Google Login Setup Guide

This guide will help you set up Google OAuth authentication for your application.

## Step 1: Create Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth 2.0 Client ID**
5. Configure the OAuth consent screen if prompted:
   - User Type: External
   - App name: Your app name
   - User support email: Your email
   - Developer contact information: Your email
6. For Application type, select **Web application**
7. Add **Authorized JavaScript origins**:
   - `http://localhost:5173` (for development)
   - Your production domain (e.g., `https://yourdomain.com`)
8. Add **Authorized redirect URIs**:
   - `https://esyodlvfhztvowabjudx.supabase.co/auth/v1/callback`
9. Click **Create** and save your:
   - Client ID
   - Client Secret

## Step 2: Configure Supabase Auth

1. Go to your [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Navigate to **Authentication** → **Providers**
4. Find **Google** in the list and enable it
5. Enter your Google OAuth credentials:
   - **Client ID**: Paste from Google Cloud Console
   - **Client Secret**: Paste from Google Cloud Console
6. Click **Save**

## Step 3: Create OAuth Providers Table

Run this SQL in your Supabase SQL Editor (Dashboard → SQL Editor):

\`\`\`sql
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

-- Enable RLS
ALTER TABLE oauth_providers ENABLE ROW LEVEL SECURITY;

-- Policies for oauth_providers
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

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_oauth_providers_user_id ON oauth_providers(user_id);
CREATE INDEX IF NOT EXISTS idx_oauth_providers_provider ON oauth_providers(provider);
CREATE INDEX IF NOT EXISTS idx_oauth_providers_provider_user_id ON oauth_providers(provider_user_id);

-- Trigger for updated_at (if update_updated_at_column function exists)
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
\`\`\`

## Step 4: Test the Integration

1. Start your development server: `npm run dev`
2. Navigate to the login page
3. Click **Continue with Google**
4. You should be redirected to Google's login page
5. After successful authentication, you'll be redirected back to your app

## Troubleshooting

### "Redirect URI mismatch" error
- Ensure the redirect URI in Google Cloud Console exactly matches:
  `https://esyodlvfhztvowabjudx.supabase.co/auth/v1/callback`
- Check for trailing slashes or typos

### Google login button doesn't work
- Check browser console for errors
- Verify Google provider is enabled in Supabase
- Ensure Client ID and Client Secret are correctly entered

### User profile not created after OAuth login
- Check that the `tdpappsignup` table exists
- Verify RLS policies allow authenticated users to insert
- Check browser console for profile creation errors

### "Invalid redirect URL" error
- Verify your redirect URL in the code matches your environment
- For production, update the redirect URL to your production domain

## Production Checklist

Before deploying to production:

- [ ] Update authorized JavaScript origins in Google Cloud Console
- [ ] Add production redirect URI to Google Cloud Console
- [ ] Update OAuth redirect URL in your application code
- [ ] Test OAuth flow in production environment
- [ ] Ensure all Supabase RLS policies are properly configured
- [ ] Consider adding additional OAuth providers (Facebook, GitHub, etc.)

## Security Notes

- Never commit your Client Secret to version control
- Always use HTTPS in production
- Regularly rotate OAuth credentials
- Monitor failed authentication attempts in Supabase Dashboard
- Review OAuth scopes to ensure minimum necessary permissions

## Support

For more information, visit:
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
