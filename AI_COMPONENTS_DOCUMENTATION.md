# AI Components Documentation

## Overview

This document describes the two new UI components created for tracking and displaying AI-powered meal plan generation results and analytics.

## Components Created

### 1. AI Results Display Component (`AIResultsDisplay.tsx`)

**Purpose:** Displays OpenAI-generated meal plans with detailed nutritional information and meal breakdowns.

**Location:** `/src/components/views/AIResultsDisplay.tsx`

**Features:**
- Lists all AI-generated meal plans for the authenticated user
- Expandable/collapsible view for each meal plan
- Shows comprehensive meal details including:
  - Daily nutritional targets (calories, protein, carbs, fats)
  - Cuisine preferences and dietary restrictions
  - Day-by-day meal breakdown
  - Ingredient lists with quantities
  - Preparation time for each meal
  - Nutritional information per meal
- Beautiful gradient design with AI branding
- Loading states and error handling
- Empty state for users with no AI plans
- Optional callback to view full plan details

**Key UI Elements:**
- Color-coded meal type badges (Breakfast, Lunch, Dinner, Snack)
- Nutritional macro display cards
- Expandable day sections
- Professional gradient headers
- Responsive grid layouts

**Props:**
```typescript
interface AIResultsDisplayProps {
  onViewPlanDetail?: (planId: string) => void;
}
```

### 2. AI Analytics Dashboard Component (`AIAnalyticsDashboard.tsx`)

**Purpose:** Provides comprehensive analytics and insights about AI meal plan generation usage.

**Location:** `/src/components/views/AIAnalyticsDashboard.tsx`

**Features:**
- **Usage Metrics:**
  - Total AI plans generated
  - Total generation count (lifetime)
  - Days until next generation allowed
  - Average calories across all AI plans
  - Average protein intake

- **Generation Timeline:**
  - Last generation timestamp
  - Next available generation date/time
  - Visual countdown indicator
  - Ready/waiting status badges
  - Rate limit policy information

- **Usage Insights:**
  - Most popular cuisine preference
  - Most common fitness goal
  - AI vs manual plan ratio
  - Visual usage rate progress bar
  - Breakdown of AI vs manual plans

- **Recent Activity:**
  - List of recent AI generations
  - Plan names and creation dates
  - Quick calorie information

- **Rate Limiting:**
  - 1 generation per week limit enforcement
  - Visual countdown timer
  - Clear next-available-date display
  - Status indicators (ready/waiting)

**Key UI Elements:**
- 4-column metrics grid
- Timeline cards with status badges
- Insight cards with gradient backgrounds
- Progress bars for usage percentage
- Recent activity list
- OpenAI branding and attribution

## Database Schema

### New Table: `ai_query_metrics`

Created to track detailed metrics about AI API calls:

```sql
CREATE TABLE ai_query_metrics (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id),
  query_type text DEFAULT 'meal_plan_generation',
  status text DEFAULT 'pending',
  response_time_ms integer,
  tokens_used integer,
  error_message text,
  query_params jsonb,
  created_at timestamptz DEFAULT now()
);
```

**Indexes:**
- `user_id` - Fast user-specific queries
- `created_at` - Time-based analytics
- `status` - Filter by success/error
- `query_type` - Filter by query type

**Row Level Security (RLS):**
- Users can view their own metrics
- Authenticated users can insert their own metrics

## Integration

### Routes Added

Updated `/src/App.tsx`:
- `/aiResults` - AI Results Display view
- `/aiAnalytics` - AI Analytics Dashboard view

Updated `/src/hooks/useNavigate.ts`:
- Added `'aiResults'` and `'aiAnalytics'` to ViewType

### Dashboard Integration

Updated `/src/components/views/DashboardView.tsx`:

**Quick Actions Section:**
- Added "AI Meal Plans" button (navigates to aiResults)
- Added "AI Analytics" button (navigates to aiAnalytics)
- Now displays 4 quick action cards in a grid

**Empty State:**
- Added AI-powered features section with direct links to:
  - View AI Meal Plans
  - AI Analytics

## Styling

### Custom Animations

Added to `/src/index.css`:
```css
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fadeIn {
  animation: fadeIn 0.3s ease-out;
}
```

### Design System

**Colors Used:**
- Teal/Blue gradients for AI branding
- Green for success states
- Orange for warning states
- Red for error states
- Color-coded meal types:
  - Breakfast: Yellow
  - Lunch: Orange
  - Dinner: Blue
  - Snack: Green

**Components:**
- Consistent card-based layouts
- Shadow and border styling
- Hover states with transitions
- Responsive grid layouts
- Icon-based navigation

## Usage Examples

### Viewing AI Results

```typescript
import { AIResultsDisplay } from './components/views/AIResultsDisplay';

// Basic usage
<AIResultsDisplay />

// With plan detail callback
<AIResultsDisplay
  onViewPlanDetail={(planId) => {
    console.log('View plan:', planId);
  }}
/>
```

### Viewing Analytics

```typescript
import { AIAnalyticsDashboard } from './components/views/AIAnalyticsDashboard';

<AIAnalyticsDashboard />
```

### Navigation

From any component with access to `useNavigate`:

```typescript
const { navigateTo } = useNavigate();

// Navigate to AI results
navigateTo('aiResults');

// Navigate to analytics
navigateTo('aiAnalytics');
```

## Data Flow

### AI Results Display

1. Component mounts → loads AI-generated meal plans
2. Queries `meal_plans` table filtered by:
   - `user_id` = current user
   - `generated_by_ai` = true
3. Displays plans with expand/collapse functionality
4. Each plan shows full 7-day meal breakdown

### AI Analytics Dashboard

1. Component mounts → loads analytics data
2. Queries multiple sources:
   - `ai_generation_limits` - Rate limiting data
   - `meal_plans` - All plans for metrics calculation
3. Calculates:
   - AI vs manual plan ratio
   - Average nutritional values
   - Most popular preferences
   - Timeline information
4. Displays metrics in organized sections

## Security

### Authentication
- Both components require authenticated users
- All queries filtered by `auth.uid()`

### RLS Policies
- Users can only view their own data
- Enforced at database level
- Service role bypasses for system operations

### Data Privacy
- No PII displayed beyond user's own data
- Secure API key handling (server-side only)

## Performance Considerations

### Optimization
- Single database queries per load
- Efficient data aggregation
- Lazy loading of meal details (expand/collapse)
- Indexed database queries

### Loading States
- Skeleton loaders during data fetch
- Error boundaries for failed requests
- Empty states for no data

## Future Enhancements

### Potential Features
- Export meal plans to PDF/calendar
- Share meal plans with others
- Compare AI vs manual plan effectiveness
- Detailed cost tracking per generation
- Token usage visualization
- Response time analytics
- Success rate trending
- Weekly/monthly usage reports
- Custom date range filtering
- Plan favorites and bookmarks

### Analytics Expansion
- More detailed token usage tracking
- Cost per plan calculation
- A/B testing different AI models
- User satisfaction ratings
- Plan completion tracking
- Meal feedback integration

## Troubleshooting

### Common Issues

**Issue:** No AI plans showing
- **Check:** Has user generated any AI plans?
- **Solution:** Generate a plan via Diet Planner → AI Generation

**Issue:** Rate limit showing when should be available
- **Check:** Database `ai_generation_limits` table
- **Solution:** Verify `last_generation_at` timestamp is > 7 days old

**Issue:** Metrics not updating
- **Check:** Browser console for errors
- **Solution:** Verify Supabase connection and RLS policies

### Debug Mode

To check data in browser console:

```javascript
// Check current user
console.log(supabase.auth.getUser());

// Check meal plans
supabase.from('meal_plans').select('*').then(console.log);

// Check generation limits
supabase.from('ai_generation_limits').select('*').then(console.log);
```

## Technical Stack

- **Framework:** React 18 with TypeScript
- **State Management:** Zustand
- **Database:** Supabase (PostgreSQL)
- **Styling:** Tailwind CSS
- **Icons:** Lucide React
- **Build Tool:** Vite

## Files Modified/Created

### Created Files:
1. `/src/components/views/AIResultsDisplay.tsx`
2. `/src/components/views/AIAnalyticsDashboard.tsx`
3. `/supabase/migrations/[timestamp]_create_ai_query_metrics.sql`
4. `/AI_COMPONENTS_DOCUMENTATION.md`

### Modified Files:
1. `/src/App.tsx` - Added routes
2. `/src/hooks/useNavigate.ts` - Added view types
3. `/src/components/views/DashboardView.tsx` - Added quick actions
4. `/src/index.css` - Added animations

## Maintenance

### Regular Tasks
- Monitor `ai_query_metrics` table size
- Archive old metrics after 90 days
- Review RLS policies quarterly
- Update OpenAI API version references
- Monitor query performance

### Database Cleanup

```sql
-- Clean up old metrics (older than 90 days)
DELETE FROM ai_query_metrics
WHERE created_at < NOW() - INTERVAL '90 days';
```

## Support

For issues or questions:
1. Check console logs for errors
2. Verify database connectivity
3. Review Supabase Edge Function logs
4. Check OpenAI API status
5. Verify user authentication state

---

**Last Updated:** October 19, 2025
**Version:** 1.0.0
**Component Status:** ✅ Production Ready
