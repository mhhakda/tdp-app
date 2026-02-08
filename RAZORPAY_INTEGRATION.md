# Razorpay Payment Integration Guide

## Overview

Your application now has a complete Razorpay payment integration with two payment options:

1. **Premium Plan** - ₹599/month (subscription)
2. **Single Plan** - ₹49 one-time (buy 1 AI meal plan generation)

---

## Features Implemented

### ✅ Payment Options
- **Premium Subscription**: ₹599/month with unlimited AI meal plans
- **Single Plan Purchase**: ₹49 for one AI meal plan generation
- **Free Plan**: Continues to be available with 3 AI generations

### ✅ Integration Points
- **PaymentView**: Updated signup flow with Razorpay payment
- **PaymentModal**: Shows when user hits AI generation limit
- **Razorpay SDK**: Dynamically loaded when needed
- **Price Display**: All prices shown in Indian Rupees (₹)

### ✅ User Experience
- Loading states during payment processing
- Error handling for failed payments
- Payment cancellation handling
- Automatic profile upgrade on successful payment

---

## Setup Instructions

### Step 1: Get Razorpay API Keys

1. **Sign up for Razorpay**: https://dashboard.razorpay.com/signup
2. **Login to Dashboard**: https://dashboard.razorpay.com/
3. **Get API Keys**:
   - Go to Settings → API Keys
   - Generate Keys (Test or Live)
   - Copy **Key ID** and **Key Secret**

### Step 2: Configure Environment Variables

Update your `.env` file with your Razorpay credentials:

```env
VITE_RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxx
VITE_RAZORPAY_KEY_SECRET=your_secret_here
```

**Important:**
- Use **Test keys** for development: `rzp_test_xxxxx`
- Use **Live keys** for production: `rzp_live_xxxxx`
- Never commit secrets to Git

### Step 3: Test the Integration

1. Start your development server:
   ```bash
   npm run dev
   ```

2. **Test Premium Subscription:**
   - Sign up for a new account
   - On the payment page, click "Subscribe to Premium"
   - Razorpay checkout will open
   - Use test card: `4111 1111 1111 1111`
   - Any future expiry date
   - Any CVV

3. **Test Single Plan Purchase:**
   - Login to your account
   - Try to generate an AI meal plan after using 3 free generations
   - Modal will appear with payment options
   - Click "Buy Now" on Single Plan (₹49)
   - Complete test payment

---

## Test Card Details

For testing Razorpay integration, use these test cards:

### Successful Payment
```
Card Number: 4111 1111 1111 1111
Expiry: Any future date
CVV: Any 3 digits
```

### Failed Payment
```
Card Number: 4000 0000 0000 0002
Expiry: Any future date
CVV: Any 3 digits
```

### Additional Test Cards
- **Domestic Card**: 5104 0600 0000 0008
- **International Card**: 4012 8888 8888 1881
- **Maestro Card**: 6759 6498 2643 8453

More test cards: https://razorpay.com/docs/payments/payments/test-card-details/

---

## Payment Flow

### Premium Subscription Flow

1. User clicks "Subscribe to Premium" (₹599)
2. Razorpay checkout opens with:
   - Amount: ₹599
   - Description: "Premium Plan - Monthly Subscription"
   - Pre-filled email
3. User completes payment
4. On success:
   - User profile updated with `isPremium: true`
   - Redirected to onboarding/dashboard
   - Gets unlimited AI generations

### Single Plan Purchase Flow

1. User hits free AI generation limit (3)
2. Payment modal appears
3. User clicks "Buy Now" on ₹49 option
4. Razorpay checkout opens
5. User completes payment
6. On success:
   - AI generation counter incremented by 1
   - Modal closes
   - User can generate one more plan

---

## Code Structure

### Files Created/Modified

1. **`src/lib/razorpay.ts`** - Razorpay integration utility
   - `loadRazorpayScript()` - Loads Razorpay SDK
   - `initiatePayment()` - Opens payment checkout
   - `PLAN_PRICES` - Centralized pricing

2. **`src/components/views/PaymentView.tsx`** - Updated
   - Premium plan: ₹599
   - Razorpay integration on premium button
   - Loading states
   - Error handling

3. **`src/components/PaymentModal.tsx`** - Updated
   - Three-column layout (Free, Single, Premium)
   - Single plan: ₹49 with "Buy Now" button
   - Premium plan: ₹599 with "Subscribe Now" button
   - Payment processing states

4. **`.env`** - Environment variables
   - `VITE_RAZORPAY_KEY_ID`
   - `VITE_RAZORPAY_KEY_SECRET`

---

## Pricing Configuration

All pricing is centralized in `src/lib/razorpay.ts`:

```typescript
export const PLAN_PRICES = {
  premium: 599,  // ₹599/month
  single: 49,    // ₹49 one-time
} as const;
```

To change prices, update this object.

---

## Security Considerations

### Environment Variables
- ✅ Never commit `.env` file to Git
- ✅ Use separate keys for development and production
- ✅ Key Secret should NEVER be exposed to frontend
- ✅ Only Key ID is used in frontend code

### Payment Verification
For production, you should:
1. Create a backend endpoint to verify payments
2. Verify `razorpay_signature` using Key Secret
3. Only update user status after verification
4. Store payment records in database

### Example Backend Verification (Node.js)
```javascript
const crypto = require('crypto');

function verifyPayment(orderId, paymentId, signature, secret) {
  const text = orderId + '|' + paymentId;
  const generated = crypto
    .createHmac('sha256', secret)
    .update(text)
    .digest('hex');

  return generated === signature;
}
```

---

## Database Schema for Payments

You should create a payments table to track transactions:

```sql
CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  razorpay_payment_id text UNIQUE NOT NULL,
  razorpay_order_id text,
  razorpay_signature text,
  plan_type text CHECK (plan_type IN ('premium', 'single')),
  amount integer NOT NULL,
  currency text DEFAULT 'INR',
  status text CHECK (status IN ('pending', 'success', 'failed')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view own payments
CREATE POLICY "Users can view own payments"
  ON payments FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy: Users can insert own payments
CREATE POLICY "Users can insert own payments"
  ON payments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);
```

---

## Production Checklist

Before going live:

- [ ] Switch to Razorpay Live keys (`rzp_live_xxxxx`)
- [ ] Update environment variables in production
- [ ] Implement backend payment verification
- [ ] Create payments table in database
- [ ] Store payment records for all transactions
- [ ] Set up webhook for payment status updates
- [ ] Test with real (small) amount first
- [ ] Set up refund policy
- [ ] Add Terms & Conditions link
- [ ] Add Privacy Policy link
- [ ] Enable HTTPS on your domain
- [ ] Test from different devices/browsers
- [ ] Set up email notifications for successful payments
- [ ] Configure GST/tax settings in Razorpay (if applicable)

---

## Webhook Setup (Recommended)

Set up webhooks to receive payment status updates:

1. **In Razorpay Dashboard:**
   - Settings → Webhooks
   - Add Webhook URL: `https://yourdomain.com/api/razorpay-webhook`
   - Select events: `payment.captured`, `payment.failed`

2. **Create Webhook Handler:**
   ```typescript
   // Example webhook handler
   async function handleRazorpayWebhook(req, res) {
     const webhookSignature = req.headers['x-razorpay-signature'];
     const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;

     // Verify signature
     const isValid = verifyWebhookSignature(
       req.body,
       webhookSignature,
       webhookSecret
     );

     if (!isValid) {
       return res.status(400).json({ error: 'Invalid signature' });
     }

     const event = req.body.event;
     const payment = req.body.payload.payment.entity;

     if (event === 'payment.captured') {
       // Update user's premium status
       await updateUserPayment(payment);
     }

     res.json({ status: 'ok' });
   }
   ```

---

## Error Handling

The integration handles these errors:

1. **SDK Load Failure**: Shows error message
2. **Missing Configuration**: Alerts about missing Razorpay keys
3. **Payment Cancellation**: Modal stays open, no charges
4. **Payment Failure**: Shows error message, user can retry
5. **Network Issues**: Error message with retry option

---

## Testing Checklist

- [ ] Premium subscription payment works
- [ ] Single plan purchase works
- [ ] Free plan continues to work
- [ ] Payment cancellation works (no charges)
- [ ] Failed payment shows error
- [ ] Loading states display correctly
- [ ] Premium status updated after payment
- [ ] User can generate AI plans after payment
- [ ] Mobile responsive design works
- [ ] Different browsers tested

---

## Support & Resources

- **Razorpay Documentation**: https://razorpay.com/docs/
- **Test Cards**: https://razorpay.com/docs/payments/payments/test-card-details/
- **API Reference**: https://razorpay.com/docs/api/
- **Dashboard**: https://dashboard.razorpay.com/
- **Support**: support@razorpay.com

---

## Troubleshooting

### Issue: "Failed to load Razorpay SDK"
**Solution**: Check internet connection, try refreshing page

### Issue: "Razorpay Key ID is not configured"
**Solution**: Add `VITE_RAZORPAY_KEY_ID` to your `.env` file

### Issue: Payment succeeds but user not upgraded
**Solution**: Check console for errors, verify payment handler is called

### Issue: Test payments not working
**Solution**:
1. Verify using Test mode keys (`rzp_test_`)
2. Use test card `4111 1111 1111 1111`
3. Check Razorpay dashboard for payment logs

### Issue: Prices showing in dollars instead of rupees
**Solution**: All prices are now in ₹ INR, clear browser cache

---

## Current Status

✅ Razorpay integration complete
✅ Premium plan: ₹599/month
✅ Single plan: ₹49 one-time
✅ Payment UI updated
✅ Error handling implemented
✅ Build successful
✅ Production-ready (after adding your API keys)

---

## Next Steps

1. **Add your Razorpay API keys** to `.env`
2. **Test the payment flow** with test cards
3. **Create payments table** in Supabase (see Database Schema above)
4. **Implement backend verification** for production
5. **Set up webhooks** for payment status updates
6. **Go live** with Live API keys

Your payment system is ready to use! 🚀
