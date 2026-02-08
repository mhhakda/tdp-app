# Troubleshooting: "Failed to create meal plan" Error

## Problem Description

**Error Message:** "Failed to create meal plan: Failed to generate meal plan"

**What's Happening:**
- The AI meal plan generation button shows "Generating Your AI Meal Plan..."
- After a few seconds, an error dialog appears
- The meal plan is not created
- Console shows: "You cancelled this message"

## Root Cause

The OpenAI Edge Function is failing because the **OpenAI API key is not configured in Supabase Edge Function secrets**.

## Solution: Configure OpenAI API Key in Supabase

### Step 1: Go to Supabase Dashboard

1. Open your browser and go to: **https://supabase.com/dashboard**
2. Log in to your account
3. Select your project: **tvmoxsrcxsormlyojebf** (or the project you're using)

### Step 2: Navigate to Edge Functions Secrets

1. In the left sidebar, click on **"Edge Functions"**
2. Look for a **"Secrets"** or **"Environment Variables"** tab/section
3. Click on it

### Step 3: Add the OpenAI API Key

1. Click the **"New Secret"** or **"Add Secret"** button
2. Enter the following:
   - **Name/Key:** `OPENAI_API_KEY`
   - **Value:** `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`
3. Click **"Save"** or **"Add"**

### Step 4: Wait for Deployment

- **Wait 2-3 minutes** for the secret to propagate to all Edge Functions
- The system needs time to update

### Step 5: Test Again

1. Go back to your Diet Planner app
2. Refresh the page (F5 or Ctrl+R)
3. Fill out the meal plan wizard (3 steps)
4. Click **"Generate AI Meal Plan"**
5. The generation should now work!

---

## Alternative: Use Fallback Plans (No OpenAI Required)

If you **don't want to configure OpenAI** or want **immediate results**, the system has a built-in fallback with high-quality static meal plans.

However, the current code requires the OpenAI key check to pass first. The fallback will automatically activate if:
- OpenAI API is down
- API key is invalid
- Rate limits are exceeded

---

## Verification Steps

### Check if the Secret is Configured

1. Go to Supabase Dashboard → **Edge Functions** → **Secrets**
2. Look for: `OPENAI_API_KEY`
3. You should see: ✅ **OPENAI_API_KEY** (value hidden)

### Check Edge Function Logs

1. Go to Supabase Dashboard → **Edge Functions**
2. Click on the **`generate-meal-plan`** function
3. Click on the **"Logs"** tab
4. You should see:
   ```
   Environment check: {
     hasSupabaseUrl: true,
     hasServiceKey: true,
     hasOpenAIKey: true,
     openaiKeyPrefix: 'sk-proj-lb...'
   }
   ```

If `hasOpenAIKey` is **false**, the secret was not configured correctly.

---

## Common Issues & Solutions

### Issue 1: "Missing Supabase configuration"
**Cause:** Supabase environment variables not set
**Solution:** This should be automatic. If you see this, the Edge Function deployment failed. Try redeploying.

### Issue 2: "No authorization header" or "Unauthorized"
**Cause:** User is not logged in or session expired
**Solution:** Log out and log back in to refresh the session.

### Issue 3: "Rate limit exceeded"
**Cause:** You already generated a meal plan within the last 7 days
**Solution:** Wait until the countdown expires, or manually reset via SQL:
```sql
DELETE FROM ai_generation_limits
WHERE user_id = 'your-user-id';
```

### Issue 4: OpenAI API returns 401 (Invalid Key)
**Cause:** The API key is incorrect or expired
**Solution:**
1. Go to https://platform.openai.com/api-keys
2. Generate a new API key
3. Update the secret in Supabase with the new key
4. Wait 2-3 minutes for propagation

### Issue 5: OpenAI API returns 429 (Rate Limit)
**Cause:** Your OpenAI account has hit its rate limit
**Solution:**
1. Check your OpenAI usage at https://platform.openai.com/usage
2. Add credits to your account
3. Wait for the rate limit to reset (usually 1 minute)
4. The fallback will automatically activate and generate a plan using static data

---

## Expected Behavior After Fix

### Successful Generation:

1. Click "Generate AI Meal Plan"
2. Button shows: "Generating Your AI Meal Plan..." with spinner
3. **Wait 10-30 seconds** (OpenAI API processing time)
4. Success screen appears: ✅ "Meal Plan Generated!"
5. **Auto-redirect to Dashboard** after 1.5 seconds
6. Your new AI meal plan appears in the dashboard

### If OpenAI Fails (Fallback Activated):

1. Click "Generate AI Meal Plan"
2. Button shows: "Generating Your AI Meal Plan..."
3. **Wait 5-10 seconds** (faster than OpenAI)
4. Success screen appears: ✅ "Meal Plan Generated!"
5. **Auto-redirect to Dashboard**
6. Your meal plan is created using high-quality static meals (35+ Indian meals, 15+ Western meals)

---

## Testing the OpenAI Integration

### Test 1: Check OpenAI Account Status

1. Go to: https://platform.openai.com/account/billing
2. Verify:
   - ✅ **Payment method added**
   - ✅ **Credits available** (not $0.00)
   - ✅ **No usage limits hit**

### Test 2: Test API Key Directly

Run this in your browser console:

```javascript
const apiKey = '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';

fetch('https://api.openai.com/v1/models', {
  headers: {
    'Authorization': `Bearer ${apiKey}`
  }
})
.then(r => r.json())
.then(data => console.log('OpenAI API Status:', data.data ? 'WORKING ✅' : 'FAILED ❌'))
.catch(err => console.error('OpenAI API Error:', err));
```

Expected result: `OpenAI API Status: WORKING ✅`

### Test 3: Check Edge Function Directly

Open your browser console and run:

```javascript
const supabaseUrl = 'https://tvmoxsrcxsormlyojebf.supabase.co';

// Get your auth token
const { data: { session } } = await supabase.auth.getSession();

if (session) {
  fetch(`${supabaseUrl}/functions/v1/generate-meal-plan`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${session.access_token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      age: 25,
      gender: 'male',
      height: 170,
      weight: 70,
      goal: 'maintain',
      activityLevel: '1.55',
      dietaryRestrictions: [],
      allergies: [],
      cuisinePreferences: ['Indian'],
      mealFrequency: 3,
      budgetLevel: 'medium',
      timeConstraint: 'moderate',
      healthConditions: [],
      bmr: 1650,
      tdee: 2546,
      targetCalories: 2546,
      protein: 140,
      carbs: 337,
      fats: 71,
      fiber: 36
    })
  })
  .then(r => r.json())
  .then(data => console.log('Edge Function Response:', data))
  .catch(err => console.error('Edge Function Error:', err));
} else {
  console.error('Not logged in');
}
```

Expected result:
```json
{
  "success": true,
  "mealPlan": [ /* 7 days of meals */ ],
  "usedFallback": false
}
```

---

## Quick Fix Checklist

- [ ] OpenAI API key added to Supabase Edge Function secrets
- [ ] Secret name is exactly: `OPENAI_API_KEY` (case-sensitive)
- [ ] Waited 2-3 minutes after adding secret
- [ ] Refreshed the Diet Planner page
- [ ] User is logged in with valid session
- [ ] OpenAI account has active billing and credits
- [ ] Tried generating a meal plan again

---

## Support

If the issue persists after following all steps:

1. **Check Supabase Edge Function Logs:**
   - Dashboard → Edge Functions → generate-meal-plan → Logs
   - Look for error messages

2. **Check Browser Console:**
   - Press F12 → Console tab
   - Look for red error messages
   - Take a screenshot

3. **Check OpenAI Status:**
   - Visit: https://status.openai.com/
   - Verify all systems are operational

4. **Verify Database Tables:**
   - Run in Supabase SQL Editor:
   ```sql
   SELECT * FROM ai_generation_limits WHERE user_id = auth.uid();
   ```

---

## Summary

**Primary Issue:** OpenAI API key not configured in Supabase Edge Function secrets

**Solution:** Add `OPENAI_API_KEY` to Supabase Dashboard → Edge Functions → Secrets

**Time to Fix:** 5 minutes (2 min to add secret + 3 min wait time)

**Fallback:** System has built-in high-quality static meal plans if OpenAI fails

---

**Last Updated:** October 19, 2025
**Status:** ⚠️ Requires manual configuration
