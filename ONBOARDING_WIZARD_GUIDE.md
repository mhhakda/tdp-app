# Onboarding Wizard Documentation

## Overview
A comprehensive 7-step onboarding wizard for TheDietPlanner that collects detailed user information to create personalized fitness and nutrition plans.

## Routes
- `/onboardingWizard` - Main multi-step onboarding flow (accessible to logged-in users only)
- `/profile` - Edit profile page where users can update their information anytime

## Database Schema

### Table: `user_profiles_detailed`
Located in migration: `create_detailed_user_profiles_table.sql`

**Key Features:**
- RLS enabled - users can only access their own data
- Automatic `updated_at` timestamp trigger
- Comprehensive validation constraints (age 10-90, height 100-250cm, weight 30-300kg, etc.)
- Supports all user profile data needed for personalized plans

## Components Structure

### Main Components
1. **OnboardingWizard** (`/src/components/views/OnboardingWizard.tsx`)
   - Main wizard component with step navigation
   - Handles validation, saving, and completion
   - Shows progress indicator with icons
   - Auto-saves on each step

2. **ProfileEditView** (`/src/components/views/ProfileEditView.tsx`)
   - Accordion-style profile editor
   - Loads existing data
   - Allows editing any section
   - Save changes button

### Step Components
All located in `/src/components/onboarding/`:

1. **PersonalInfoStep** - Name, age, gender, height, weight, preferences
2. **FitnessGoalsStep** - Goals, timeline, target areas, success definition
3. **ActivityLevelStep** - Daily activity, exercise frequency, sitting hours
4. **NutritionStep** - Diet preferences, meal frequency, allergies, eating habits
5. **HealthWellnessStep** - Medical conditions, sleep, stress, lifestyle factors
6. **WorkoutSetupStep** - Location, equipment, frequency, experience level
7. **ExperienceStep** - History, past attempts, challenges, motivation

### Form Components
Reusable inputs in `/src/components/onboarding/FormComponents.tsx`:
- TextInput
- NumberInput
- Select
- MultiSelect
- TextArea
- RadioGroup
- Slider
- Checkbox

All components include:
- Validation support with error messages
- Help text
- Accessibility attributes (aria-labels)
- Consistent styling

## Adding New Questions

### 1. Update Database Schema
```sql
-- Add new column to user_profiles_detailed table
ALTER TABLE user_profiles_detailed
ADD COLUMN new_field text;
```

### 2. Update TypeScript Types
In `/src/types/onboarding.ts`:
```typescript
export interface UserProfileDetailed {
  // ... existing fields
  new_field: string; // Add new field
}

export const defaultUserProfile: Partial<UserProfileDetailed> = {
  // ... existing defaults
  new_field: '', // Add default value
};
```

### 3. Add to Step Component
Edit the relevant step component (e.g., `PersonalInfoStep.tsx`):
```tsx
<TextInput
  label="New Field Label"
  value={profile.new_field || ''}
  onChange={(value) => updateProfile('new_field', value)}
  placeholder="Enter value"
  helpText="Helpful description"
/>
```

### 4. Add Validation (if required)
In `OnboardingWizard.tsx`, update the `validateStep` function:
```typescript
case 1: // Personal Info step
  if (!profile.new_field?.trim()) {
    newErrors.new_field = 'This field is required';
  }
  break;
```

## Validation Rules

### Step 1 - Personal Info (Required)
- first_name: Must be non-empty
- age: 10-90 years
- gender: Must be selected
- height_cm: 100-250 cm
- current_weight_kg: 30-300 kg

### Step 2 - Fitness Goals (Required)
- primary_goal: Must be selected
- target_timeline_weeks: Must be > 0

### Step 3 - Activity Level (Required)
- job_activity_level: Must be selected

### Step 4 - Nutrition (Required)
- diet_preference: Must be selected
- meals_per_day: 2-6 meals

### Step 5 - Health & Wellness (Required)
- sleep_hours: 0-24
- sleep_quality: Must be selected
- stress_level: 1-5

### Step 6 - Workout Setup (Required)
- workout_location: Must be selected
- sessions_per_week: 0-7
- session_duration_minutes: Must be > 0
- training_experience_level: Must be selected

### Step 7 - Experience
- No required fields (all optional)

## Features

### Auto-Save
- Data is automatically saved when user clicks "Next"
- Shows saving spinner and success indicator
- Prevents data loss on page refresh

### Progress Tracking
- Visual stepper at top shows current position
- Step numbers with icons
- Completed steps marked with checkmarks
- Current step highlighted

### Responsive Design
- Mobile-friendly with horizontal scrollable tabs
- Responsive grid layouts
- Touch-friendly buttons and inputs

### Accessibility
- All inputs have proper labels and aria-labels
- Keyboard navigation supported
- Clear error messages
- Help text for guidance

### Success Screen
- Shows personalized message with user's first name
- "Go to Dashboard" button
- Appears after completing all steps

## User Experience Flow

### First Time Users
1. Sign up → Redirected to Profile Questionnaire
2. Complete 7-step questionnaire
3. Click "Finish" → Success screen
4. Redirected to Dashboard with personalized plan

### Returning Users
1. Can edit profile anytime from user menu → "Manage Profile"
2. Or visit `/profile` route directly
3. Accordion interface with all sections
4. Save changes anytime

### Data Persistence
- Profile loads existing data on mount
- Shows empty form if no profile exists
- Creates new record on first save
- Updates existing record on subsequent saves

## Styling Guidelines

### Colors
- Primary: Teal (bg-teal-600, text-teal-600)
- Success: Green (bg-green-500)
- Error: Red (text-red-500, border-red-500)
- Gray shades for neutral elements

### Component Patterns
- Cards: `bg-white rounded-2xl shadow-lg p-6 sm:p-8`
- Buttons: `rounded-lg` with transition effects
- Inputs: `rounded-lg border` with focus states
- Spacing: Consistent `space-y-6` for sections

## Best Practices

### Adding Questions
1. Keep questions clear and concise
2. Provide helpful descriptions
3. Use appropriate input types
4. Add validation if data is critical
5. Consider optional vs required fields

### Modifying Steps
1. Update step component
2. Update validation if needed
3. Update TypeScript types
4. Test thoroughly
5. Update this documentation

### Database Changes
1. Create migration file
2. Test with RLS policies
3. Update TypeScript interfaces
4. Handle existing data migration if needed

## Common Customizations

### Change Step Order
Edit the `steps` array in `OnboardingWizard.tsx`:
```typescript
const steps = [
  { number: 1, name: 'New Step Name', icon: IconComponent },
  // ... reorder or add steps
];
```

### Add New Step
1. Create new step component following existing pattern
2. Add to `steps` array
3. Add case in `renderStep()` switch
4. Add validation in `validateStep()`

### Modify Required Fields
Update validation in `validateStep()` function:
```typescript
case X: // Your step
  if (!profile.field?.trim()) {
    newErrors.field = 'Field is required';
  }
  break;
```

### Change Success Behavior
Modify `handleFinish()` function in `OnboardingWizard.tsx`:
```typescript
const handleFinish = async () => {
  // ... save logic
  // Custom redirect or action
  navigateTo('customRoute');
};
```

## Testing Checklist

- [ ] All required fields validate correctly
- [ ] Optional fields can be left empty
- [ ] Data saves on each step
- [ ] Page refresh preserves data
- [ ] Success screen appears after completion
- [ ] Profile edit page loads saved data
- [ ] Changes save correctly
- [ ] Mobile responsive
- [ ] Keyboard navigation works
- [ ] Error messages display properly
- [ ] Help text is helpful

## Troubleshooting

### Data Not Saving
- Check Supabase connection
- Verify RLS policies allow user access
- Check browser console for errors
- Confirm user_id is correct

### Validation Not Working
- Check field names match TypeScript interface
- Verify validateStep() includes the step
- Ensure error messages are displayed

### UI Issues
- Check Tailwind classes are correct
- Verify responsive breakpoints
- Test on different screen sizes
- Check icon imports

## Security Notes

- RLS policies ensure users can only access their own data
- All fields are validated before saving
- Sensitive health data is optional
- No authentication tokens in client code
- Profile data encrypted at rest (Supabase default)

## Performance

- Lazy load step components if needed
- Debounce auto-save for real-time updates
- Optimize large multi-select options
- Consider pagination for very long forms

## Future Enhancements

Potential improvements:
- Real-time validation as user types
- Progress percentage indicator
- Save draft functionality
- Export profile as PDF
- Compare before/after changes
- Profile completion percentage
- Gamification/achievements
- Email notifications for incomplete profiles
