# Payment Error Fix Guide

## Current Error: "Failed to create order"

### What's Happening

The error "Failed to create order" occurs because **Razorpay API credentials are not configured** in your Supabase Edge Function secrets.

**Error Flow:**
```
User clicks "Subscribe"
→ Frontend sends request to Edge Function
→ Edge Function checks for RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET
→ Credentials are missing or invalid
→ Returns 500 error: "Payment system not configured"
```

## Root Cause

The Edge Function needs Razorpay credentials to create orders with Razorpay's API. These credentials must be stored in **Supabase Edge Function Secrets**, not in your local `.env` file.

### Why the Error Occurs

1. **Missing Credentials:**
   - RAZORPAY_KEY_ID not set in Supabase secrets
   - RAZORPAY_KEY_SECRET not set in Supabase secrets

2. **Placeholder Values:**
   - Credentials set to `your_razorpay_key_id_here`
   - These are test values that don't work with Razorpay API

## Solution: Configure Razorpay Credentials

### Step 1: Get Razorpay API Keys

1. **Create/Login to Razorpay Account:**
   ```
   Go to: https://dashboard.razorpay.com/
   ```

2. **Navigate to API Keys:**
   ```
   Dashboard → Settings → API Keys
   OR
   Direct link: https://dashboard.razorpay.com/app/keys
   ```

3. **Choose Test Mode (for testing):**
   ```
   Toggle: Live/Test Mode → Select "Test Mode"
   ```

4. **Get Your Keys:**
   ```
   You'll see:
   ✓ Key ID (starts with rzp_test_)
   ✓ Key Secret (click "Regenerate" if needed)
   ```

5. **Copy Both Keys:**
   ```
   Key ID:     rzp_test_xxxxxxxxxxxxxxxx
   Key Secret: xxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

### Step 2: Add Keys to Supabase Secrets

**Important:** These must be added to **Supabase Dashboard**, not your local `.env` file.

1. **Open Supabase Dashboard:**
   ```
   Go to: https://supabase.com/dashboard
   Select your project: esyodlvfhztvowabjudx
   ```

2. **Navigate to Edge Functions Secrets:**
   ```
   Left Sidebar → Edge Functions → Secrets
   OR
   Settings → Edge Functions → Secrets
   ```

3. **Add RAZORPAY_KEY_ID:**
   ```
   Click "Add New Secret"
   Name:  RAZORPAY_KEY_ID
   Value: rzp_test_xxxxxxxxxxxxxxxx  (your actual key)
   Click "Save"
   ```

4. **Add RAZORPAY_KEY_SECRET:**
   ```
   Click "Add New Secret"
   Name:  RAZORPAY_KEY_SECRET
   Value: xxxxxxxxxxxxxxxxxxxxxxxxxxx  (your actual secret)
   Click "Save"
   ```

### Step 3: Test Payment Flow

1. **Refresh Your App:**
   ```
   Hard refresh: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)
   ```

2. **Try Payment Again:**
   ```
   1. Login to app
   2. Go to Plan Selection
   3. Click "Subscribe to Premium" or "Subscribe to Pro"
   4. Should open Razorpay checkout
   ```

3. **Use Test Card:**
   ```
   Card Number: 4111 1111 1111 1111
   CVV:         123
   Expiry:      Any future date
   Name:        Any name
   ```

## Enhanced Error Messages

The Edge Function now provides detailed error messages to help diagnose issues:

### Error Types You Might See:

1. **"Payment system not configured"**
   ```
   Reason: Razorpay credentials not set in Supabase secrets
   Fix: Follow Step 2 above to add credentials
   ```

2. **"Razorpay credentials are set to placeholder values"**
   ```
   Reason: Credentials contain "your_razorpay" text
   Fix: Replace with real credentials from Razorpay dashboard
   ```

3. **"Unauthorized"**
   ```
   Reason: User not logged in or session expired
   Fix: Log out and log back in
   ```

4. **"Missing required fields"**
   ```
   Reason: Request missing amountInINR, userId, or planId
   Fix: This is a code issue, check browser console
   ```

5. **Razorpay API Errors**
   ```
   Reason: Invalid API keys or network issues
   Fix: Verify keys are correct, check Razorpay dashboard
   ```

## Console Logging

The Edge Function now logs detailed information to help debug:

**In Browser Console:**
```javascript
// When you click Subscribe, you'll see:
"Creating Razorpay order..." { apiUrl, userId }
"Response status:" 200 or 500

// On success:
"Order created successfully:" { orderId, amount, currency, keyId }

// On error:
"Order creation failed:" { error, details }
"Payment error:" Error message
```

**In Supabase Edge Function Logs:**
```
To view:
1. Supabase Dashboard → Edge Functions
2. Click on "create-razorpay-order"
3. View "Logs" tab

You'll see:
- "Create Razorpay Order - Request received"
- "User authenticated: [user-id]"
- "Request body: {...}"
- "Razorpay credentials check: {...}"
- "Creating Razorpay order: {...}"
- "Razorpay API response status: 200"
- "Razorpay order created successfully: [order-id]"
```

## Testing Checklist

### Before Testing:
- [ ] Razorpay account created
- [ ] Test mode enabled in Razorpay
- [ ] API keys copied from Razorpay dashboard
- [ ] Keys added to Supabase Edge Function secrets
- [ ] App refreshed (hard refresh)

### During Testing:
- [ ] User logged in
- [ ] Navigate to plan selection page
- [ ] Click Subscribe button
- [ ] See "Processing..." state
- [ ] Check browser console for logs
- [ ] Razorpay checkout opens
- [ ] Enter test card details
- [ ] Payment processes successfully

### If Error Occurs:
- [ ] Check browser console for error details
- [ ] Check Supabase Edge Function logs
- [ ] Verify credentials in Supabase secrets
- [ ] Confirm keys don't have spaces or quotes
- [ ] Try regenerating keys in Razorpay dashboard

## Local Development vs Production

### Local Development:
- Uses test keys (rzp_test_xxx)
- No real money processed
- Can test unlimited times
- Use test card numbers

### Production:
- Needs live keys (rzp_live_xxx)
- Real money processed
- Must complete Razorpay KYC
- Must enable live mode in Razorpay

## File Changes Made

### 1. Edge Function Enhanced
**File:** `supabase/functions/create-razorpay-order/index.ts`

**Changes:**
- ✅ Added detailed console logging
- ✅ Added credential validation
- ✅ Added placeholder value detection
- ✅ Enhanced error messages with details
- ✅ Better Razorpay API error parsing
- ✅ Added request/response logging

### 2. Frontend Error Handling Improved
**File:** `src/components/views/PlanSelectionView.tsx`

**Changes:**
- ✅ Show detailed error messages from Edge Function
- ✅ Display `error.details` to user
- ✅ Better error message composition
- ✅ Maintained existing error handling

## Common Issues and Solutions

### Issue 1: "Failed to create order"
**Solution:** Add Razorpay credentials to Supabase secrets (see Step 2)

### Issue 2: "CORS error"
**Solution:** Already fixed - CORS headers properly configured

### Issue 3: "Razorpay script not loaded"
**Solution:** Hard refresh the page (Ctrl+Shift+R)

### Issue 4: "Unauthorized"
**Solution:** Log out and log back in

### Issue 5: Keys not working
**Checklist:**
- [ ] Copied entire key (no spaces)
- [ ] Using test keys (rzp_test_xxx) in test mode
- [ ] No quotes around keys in Supabase
- [ ] Keys saved in Edge Function secrets, not project settings
- [ ] Edge Function redeployed after adding secrets

### Issue 6: Payment succeeds but not updating database
**Check:**
1. Verify webhook handler is working
2. Check verify-razorpay-payment Edge Function
3. Check database RLS policies
4. View Edge Function logs for verification step

## Quick Fix Summary

**TL;DR - Steps to Fix:**

1. **Get Keys:** https://dashboard.razorpay.com/app/keys
   - Copy Key ID (starts with rzp_test_)
   - Copy Key Secret

2. **Add to Supabase:**
   - Go to Supabase Dashboard
   - Edge Functions → Secrets
   - Add: RAZORPAY_KEY_ID = [your key]
   - Add: RAZORPAY_KEY_SECRET = [your secret]

3. **Test:**
   - Refresh app
   - Try payment
   - Use card: 4111 1111 1111 1111

## Need Help?

If you're still seeing errors after following this guide:

1. **Check Browser Console:**
   - Open DevTools (F12)
   - Go to Console tab
   - Look for error messages

2. **Check Edge Function Logs:**
   - Supabase Dashboard
   - Edge Functions → create-razorpay-order
   - View Logs tab

3. **Verify Credentials:**
   - Double-check keys in Supabase secrets
   - Ensure no typos or extra spaces
   - Confirm test mode in Razorpay dashboard

## Success Indicators

When everything is working correctly:

✅ **Console shows:**
```
Creating Razorpay order...
Response status: 200
Order created successfully: { orderId: "order_xxx..." }
```

✅ **UI shows:**
```
1. "Processing..." on button
2. Razorpay checkout modal opens
3. Can enter payment details
4. Payment processes
5. Redirects to dashboard
```

✅ **Database shows:**
```
- User subscription updated
- Transaction recorded
- Plan features activated
```

## Build Status

✅ Application built successfully
✅ All TypeScript types correct
✅ No compilation errors
✅ Edge Function deployed
✅ Enhanced error logging active

---

**The payment system is ready once you add valid Razorpay credentials to Supabase Edge Function secrets!**
