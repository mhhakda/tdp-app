# Database Migration Guide

## Issue Fixed
The application was using two different database tables:
- Old: `user_profiles`
- New: `user_profiles_detailed`

All components have been updated to use `user_profiles_detailed`.

## What Was Changed

### 1. OnboardingQuestionnaireView
- Updated to read from `user_profiles_detailed` using `user_id`
- Updated to save to `user_profiles_detailed`
- Field mappings:
  - `weight_kg` → `current_weight_kg`
  - `target_weight_kg` → `goal_weight_kg`
  - `fitness_goal` → `primary_goal`
  - `activity_level` → `job_activity_level`
  - `experience_level` → `training_experience_level`

### 2. ProfileSettingsView
- Updated to read from `user_profiles_detailed` using `user_id`
- Updated to save to `user_profiles_detailed`
- Same field mappings as above

### 3. App.tsx Onboarding Check
- Now checks `user_profiles_detailed` for onboarding completion
- Still checks `user_profiles` for subscription plan (for backward compatibility)

## Migrate Existing Data (Optional)

If you have data in the old `user_profiles` table that you want to migrate to `user_profiles_detailed`, run this SQL in Supabase SQL Editor:

```sql
-- Migrate existing user_profiles data to user_profiles_detailed
INSERT INTO user_profiles_detailed (
  user_id,
  first_name,
  last_name,
  age,
  gender,
  height_cm,
  current_weight_kg,
  goal_weight_kg,
  primary_goal,
  job_activity_level,
  exercise_preferences,
  dietary_restrictions,
  food_preferences,
  health_conditions,
  workout_time_available,
  workout_frequency,
  available_equipment,
  training_experience_level,
  onboarding_completed,
  created_at,
  updated_at
)
SELECT
  id as user_id,
  first_name,
  last_name,
  age,
  gender,
  height_cm,
  weight_kg as current_weight_kg,
  target_weight_kg as goal_weight_kg,
  fitness_goal as primary_goal,
  activity_level as job_activity_level,
  exercise_preferences,
  dietary_restrictions,
  food_preferences,
  health_conditions,
  workout_time_available,
  workout_frequency,
  available_equipment,
  experience_level as training_experience_level,
  onboarding_completed,
  created_at,
  updated_at
FROM user_profiles
ON CONFLICT (user_id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  age = EXCLUDED.age,
  gender = EXCLUDED.gender,
  height_cm = EXCLUDED.height_cm,
  current_weight_kg = EXCLUDED.current_weight_kg,
  goal_weight_kg = EXCLUDED.goal_weight_kg,
  primary_goal = EXCLUDED.primary_goal,
  job_activity_level = EXCLUDED.job_activity_level,
  exercise_preferences = EXCLUDED.exercise_preferences,
  dietary_restrictions = EXCLUDED.dietary_restrictions,
  food_preferences = EXCLUDED.food_preferences,
  health_conditions = EXCLUDED.health_conditions,
  workout_time_available = EXCLUDED.workout_time_available,
  workout_frequency = EXCLUDED.workout_frequency,
  available_equipment = EXCLUDED.available_equipment,
  training_experience_level = EXCLUDED.training_experience_level,
  onboarding_completed = EXCLUDED.onboarding_completed,
  updated_at = EXCLUDED.updated_at;
```

## Testing the Fix

1. Clear your browser cache and reload
2. Try completing the onboarding questionnaire
3. The "Next" button should now work properly
4. All data should save to `user_profiles_detailed`
5. Check the browser console - there should be no errors

## Verify Data

Run this query to see your data in the new table:

```sql
SELECT * FROM user_profiles_detailed
WHERE user_id = auth.uid();
```

## Notes

- The old `user_profiles` table is still used for `subscription_plan` field
- This maintains backward compatibility with existing payment system
- In the future, you may want to add `subscription_plan` to `user_profiles_detailed` and fully migrate
