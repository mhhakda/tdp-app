-- ============================================
-- FIX RLS PERFORMANCE AND SECURITY ISSUES
-- ============================================
-- This migration fixes all RLS policies to use (SELECT auth.uid())
-- instead of auth.uid() for better performance at scale
-- ============================================

-- ============================================
-- TABLE: signuptdp
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Authenticated users can view signups" ON public.signuptdp;
DROP POLICY IF EXISTS "Authenticated users can update signups" ON public.signuptdp;
DROP POLICY IF EXISTS "Authenticated users can delete signups" ON public.signuptdp;

-- Recreate with optimized auth function calls
CREATE POLICY "Authenticated users can view signups"
  ON public.signuptdp FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Authenticated users can update signups"
  ON public.signuptdp FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Authenticated users can delete signups"
  ON public.signuptdp FOR DELETE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- ============================================
-- TABLE: tdp signup
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Authenticated can view tdp signup" ON public."tdp signup";
DROP POLICY IF EXISTS "Authenticated can update tdp signup" ON public."tdp signup";
DROP POLICY IF EXISTS "Authenticated can delete tdp signup" ON public."tdp signup";

-- Recreate with optimized auth function calls
CREATE POLICY "Authenticated can view tdp signup"
  ON public."tdp signup" FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Authenticated can update tdp signup"
  ON public."tdp signup" FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Authenticated can delete tdp signup"
  ON public."tdp signup" FOR DELETE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- ============================================
-- TABLE: tdp_login
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own login data" ON public.tdp_login;
DROP POLICY IF EXISTS "Users can insert own login data" ON public.tdp_login;
DROP POLICY IF EXISTS "Users can update own login data" ON public.tdp_login;

-- Recreate with optimized auth function calls
CREATE POLICY "Users can view own login data"
  ON public.tdp_login FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert own login data"
  ON public.tdp_login FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can update own login data"
  ON public.tdp_login FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

-- ============================================
-- TABLE: tdpappsignup
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.tdpappsignup;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.tdpappsignup;
DROP POLICY IF EXISTS "Users can update own profile" ON public.tdpappsignup;

-- Recreate with optimized auth function calls
CREATE POLICY "Users can view own profile"
  ON public.tdpappsignup FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert own profile"
  ON public.tdpappsignup FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can update own profile"
  ON public.tdpappsignup FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

-- ============================================
-- TABLE: meal_plans
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own meal plans" ON public.meal_plans;
DROP POLICY IF EXISTS "Users can insert own meal plans" ON public.meal_plans;
DROP POLICY IF EXISTS "Users can update own meal plans" ON public.meal_plans;
DROP POLICY IF EXISTS "Users can delete own meal plans" ON public.meal_plans;

-- Recreate with optimized auth function calls
CREATE POLICY "Users can view own meal plans"
  ON public.meal_plans FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert own meal plans"
  ON public.meal_plans FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can update own meal plans"
  ON public.meal_plans FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can delete own meal plans"
  ON public.meal_plans FOR DELETE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- ============================================
-- TABLE: workout_plans
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own workout plans" ON public.workout_plans;
DROP POLICY IF EXISTS "Users can insert own workout plans" ON public.workout_plans;
DROP POLICY IF EXISTS "Users can update own workout plans" ON public.workout_plans;
DROP POLICY IF EXISTS "Users can delete own workout plans" ON public.workout_plans;

-- Recreate with optimized auth function calls
CREATE POLICY "Users can view own workout plans"
  ON public.workout_plans FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert own workout plans"
  ON public.workout_plans FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can update own workout plans"
  ON public.workout_plans FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can delete own workout plans"
  ON public.workout_plans FOR DELETE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- ============================================
-- TABLE: timer_templates
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own templates" ON public.timer_templates;
DROP POLICY IF EXISTS "Users can insert own templates" ON public.timer_templates;
DROP POLICY IF EXISTS "Users can update own templates" ON public.timer_templates;
DROP POLICY IF EXISTS "Users can delete own templates" ON public.timer_templates;

-- Recreate with optimized auth function calls
CREATE POLICY "Users can view own templates"
  ON public.timer_templates FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert own templates"
  ON public.timer_templates FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can update own templates"
  ON public.timer_templates FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can delete own templates"
  ON public.timer_templates FOR DELETE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- ============================================
-- TABLE: meal_completions
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own meal completions" ON public.meal_completions;
DROP POLICY IF EXISTS "Users can insert own meal completions" ON public.meal_completions;
DROP POLICY IF EXISTS "Users can update own meal completions" ON public.meal_completions;
DROP POLICY IF EXISTS "Users can delete own meal completions" ON public.meal_completions;

-- Recreate with optimized auth function calls
CREATE POLICY "Users can view own meal completions"
  ON public.meal_completions FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert own meal completions"
  ON public.meal_completions FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can update own meal completions"
  ON public.meal_completions FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can delete own meal completions"
  ON public.meal_completions FOR DELETE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- ============================================
-- TABLE: ai_generation_limits
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own generation limits" ON public.ai_generation_limits;
DROP POLICY IF EXISTS "Users can insert own generation limits" ON public.ai_generation_limits;
DROP POLICY IF EXISTS "Users can update own generation limits" ON public.ai_generation_limits;

-- Recreate with optimized auth function calls
CREATE POLICY "Users can view own generation limits"
  ON public.ai_generation_limits FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert own generation limits"
  ON public.ai_generation_limits FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can update own generation limits"
  ON public.ai_generation_limits FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

-- ============================================
-- TABLE: ai_query_metrics
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own AI metrics" ON public.ai_query_metrics;
DROP POLICY IF EXISTS "System can insert AI metrics" ON public.ai_query_metrics;

-- Recreate with optimized auth function calls
CREATE POLICY "Users can view own AI metrics"
  ON public.ai_query_metrics FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "System can insert AI metrics"
  ON public.ai_query_metrics FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

-- ============================================
-- TABLE: user_plans
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can read own plan" ON public.user_plans;
DROP POLICY IF EXISTS "Users can insert own plan" ON public.user_plans;
DROP POLICY IF EXISTS "Users can update own plan" ON public.user_plans;

-- Recreate with optimized auth function calls
CREATE POLICY "Users can read own plan"
  ON public.user_plans FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert own plan"
  ON public.user_plans FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can update own plan"
  ON public.user_plans FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

-- ============================================
-- FIX FUNCTION SEARCH PATH
-- ============================================

-- Fix update_updated_at_column function with immutable search path
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public, pg_temp
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- ============================================
-- DROP UNUSED INDEXES (Optional - Uncomment if needed)
-- ============================================

-- Uncomment these lines if you want to remove unused indexes
-- WARNING: Only do this if you're sure these indexes won't be needed

-- DROP INDEX IF EXISTS public.idx_signuptdp_email;
-- DROP INDEX IF EXISTS public.idx_signuptdp_created_at;
-- DROP INDEX IF EXISTS public.idx_meal_completions_user_id;
-- DROP INDEX IF EXISTS public.idx_meal_completions_meal_plan_id;
-- DROP INDEX IF EXISTS public.idx_meal_completions_completed_at;
-- DROP INDEX IF EXISTS public.idx_meals_meal_type;
-- DROP INDEX IF EXISTS public.idx_ai_query_metrics_user_id;
-- DROP INDEX IF EXISTS public.idx_ai_query_metrics_created_at;
-- DROP INDEX IF EXISTS public.idx_ai_query_metrics_status;
-- DROP INDEX IF EXISTS public.idx_tdpappsignup_email;
-- DROP INDEX IF EXISTS public.idx_ai_query_metrics_query_type;
-- DROP INDEX IF EXISTS public.idx_timer_templates_user_id;
-- DROP INDEX IF EXISTS public.idx_timer_templates_builtin;

-- ============================================
-- VERIFICATION
-- ============================================

-- Check RLS policies are enabled
SELECT
  schemaname,
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'signuptdp', 'tdp signup', 'tdp_login', 'tdpappsignup',
    'meal_plans', 'workout_plans', 'timer_templates',
    'meal_completions', 'ai_generation_limits', 'ai_query_metrics',
    'user_plans'
  )
ORDER BY tablename;

-- Count policies per table
SELECT
  tablename,
  COUNT(*) as policy_count
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'RLS PERFORMANCE FIXES APPLIED SUCCESSFULLY';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'All auth.uid() calls have been optimized to (SELECT auth.uid())';
  RAISE NOTICE 'Function search_path has been fixed';
  RAISE NOTICE 'All RLS policies are now performant at scale';
  RAISE NOTICE '';
  RAISE NOTICE 'NEXT STEPS:';
  RAISE NOTICE '1. Enable "Leaked Password Protection" in Supabase Dashboard';
  RAISE NOTICE '   Dashboard → Authentication → Settings → Password Requirements';
  RAISE NOTICE '2. Review unused indexes (commented out in this script)';
  RAISE NOTICE '3. Run verification queries above to confirm changes';
END $$;
