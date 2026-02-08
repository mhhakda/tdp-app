# Diet Planner Enhancement Implementation Plan

## Overview
Transform the current basic diet planner into a comprehensive AI-powered meal planning system with detailed nutritional tracking and analytics.

## Database Schema Updates ✅ COMPLETED

The database has been enhanced with the following new fields in `meal_plans` table:
- User profile data (age, gender, height, weight, activity_level)
- Dietary preferences (dietary_restrictions[], allergies[], cuisine_preferences[])
- Meal planning preferences (meal_frequency, budget_level, time_constraint)
- Health considerations (health_conditions[])
- Calculated nutritional data (bmr, tdee, fiber)
- Plan metadata (duration_days, generated_by_ai)

New `meal_completions` table created for tracking:
- Individual meal completion tracking
- Adherence statistics
- Progress monitoring

## Implementation Requirements

### 1. Enhanced Questionnaire Form (3-Step Wizard)

**Step 1: Basic Information**
- Age, gender, height, weight (with validation)
- Goal selection (lose/maintain/gain weight)
- Activity level dropdown
- Real-time calorie calculation display (BMR, TDEE, Target)

**Step 2: Dietary Preferences**
- Multi-select dietary restrictions (Vegetarian, Vegan, Keto, etc.)
- Multi-select allergies (Peanuts, Shellfish, Dairy, etc.)
- Multi-select cuisine preferences (Indian, Mediterranean, Asian, etc.)
- Multi-select health conditions (Diabetes, Hypertension, etc.)

**Step 3: Meal Planning Preferences**
- Meals per day (3-6 options)
- Budget level (Low/Medium/High)
- Time constraints for cooking (Quick/Moderate/Flexible)
- Summary preview before generation

### 2. Automatic Calorie Calculation

```javascript
// Mifflin-St Jeor Equation
BMR (Male) = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + 5
BMR (Female) = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) - 161

TDEE = BMR × Activity Factor
Target Calories = TDEE ± 500 (based on goal)

Macros:
- Protein: 2g per kg body weight
- Fats: 25% of total calories
- Carbs: Remaining calories
- Fiber: 14g per 1000 calories
```

### 3. AI Meal Generation System

**Input Parameters:**
- Calculated calorie target
- User preferences and restrictions
- Cuisine selections
- Meal frequency
- Time and budget constraints

**Output Structure (7-Day Plan):**
```javascript
{
  day: "Monday",
  dayNumber: 1,
  meals: [
    {
      type: "Breakfast",
      name: "Sabudana Khichdi",
      ingredients: ["sabudana", "peanuts", "potato", "cumin"],
      calories: 360,
      protein: 7,
      carbs: 60,
      fats: 10,
      fiber: 3,
      prepTime: 15,
      instructions: "..."
    },
    // ... more meals
  ]
}
```

**Meal Generation Logic:**
1. Calculate calories per meal (daily target / meal frequency)
2. Select cuisine-appropriate recipes
3. Filter by dietary restrictions
4. Exclude allergens
5. Match time constraints
6. Balance macros across the day
7. Ensure variety throughout the week

### 4. Detailed Meal Plan Display Component

**Features Needed:**
- Tabbed view for each day of the week
- Table format showing:
  - Meal type (Breakfast/Lunch/Dinner/Snacks)
  - Food name with icon
  - Detailed ingredients list
  - Nutritional breakdown (Calories, Protein, Carbs, Fats, Fiber)
  - Prep time indicator
  - Completion checkbox
- Daily totals row
- Expandable ingredient details
- Recipe instructions modal

### 5. Analytics & Visualization

**Charts to Implement:**
- **Weekly Calorie Distribution** (Bar Chart)
  - X-axis: Days of the week
  - Y-axis: Total calories
  - Target line overlay

- **Macronutrient Distribution** (Donut Chart)
  - Protein percentage (pink)
  - Carbs percentage (blue)
  - Fats percentage (yellow)

- **Meal-wise Calorie Breakdown** (Stacked Bar Chart)
  - Breakfast/Lunch/Dinner/Snacks contribution

- **Weekly Compliance Stats**
  - Meals completed vs planned
  - Average adherence percentage
  - Streak counter

### 6. PDF Export Functionality

**PDF Contents:**
- Cover page with plan name and date range
- User profile summary
- Weekly meal schedule table
- Shopping list (aggregated ingredients)
- Nutritional summary
- Recipe instructions
- Tips and notes

**Implementation Options:**
1. Use `jsPDF` library for client-side generation
2. Use `react-pdf` for component-based PDF
3. Use server-side PDF generation service

### 7. Meal Completion Tracking

**Dashboard Integration:**
- Click checkbox next to each meal to mark complete
- Store completion in `meal_completions` table
- Update dashboard analytics in real-time
- Show completion percentage
- Display streak and achievements

**Database Operations:**
```sql
INSERT INTO meal_completions (
  user_id, meal_plan_id, day_number,
  meal_type, completed_at
) VALUES (...)
```

### 8. Auto-Generated Plan Names

**Format:** `[Goal] [Diet Type] [Cuisine] Plan - [Date]`

**Examples:**
- "Weight Loss Vegetarian Indian Plan - Jan 15, 2025"
- "Muscle Gain Keto Mediterranean Plan - Jan 15, 2025"
- "Maintenance Vegan Asian Plan - Jan 15, 2025"

## API Integration Options

### Option 1: OpenAI GPT API
```javascript
const prompt = `Generate a 7-day ${goal} meal plan for:
- Calories: ${calories}/day
- Dietary restrictions: ${restrictions.join(', ')}
- Cuisines: ${cuisines.join(', ')}
- Format: JSON with meals, ingredients, and nutrition`;

const response = await openai.chat.completions.create({
  model: "gpt-4",
  messages: [{ role: "user", content: prompt }]
});
```

### Option 2: Nutrition APIs
- **Spoonacular API**: Recipe search and nutritional data
- **Edamam API**: Nutrition analysis and recipe search
- **USDA FoodData Central**: Comprehensive nutrition database

### Option 3: Local/Simulated AI (Current Implementation)
- Pre-defined recipe database
- Rule-based meal selection
- Randomized variety
- Fast and no API costs

## Technical Implementation Steps

### Phase 1: Form & Calculation (Priority: High)
1. Create 3-step wizard component
2. Implement multi-select buttons
3. Add real-time calorie calculation
4. Add form validation
5. Store all preferences in state

### Phase 2: AI Generation (Priority: High)
1. Build meal generation algorithm
2. Create recipe database
3. Implement filtering logic
4. Generate 7-day plans
5. Save to database with all metadata

### Phase 3: Display & Visualization (Priority: High)
1. Create tabbed day view
2. Build meal table component
3. Add charts (using Chart.js or Recharts)
4. Implement responsive design
5. Add loading states

### Phase 4: Tracking System (Priority: Medium)
1. Add completion checkboxes
2. Implement `meal_completions` CRUD
3. Calculate adherence statistics
4. Update dashboard integration
5. Add streak tracking

### Phase 5: PDF Export (Priority: Low)
1. Choose PDF library
2. Design PDF template
3. Generate shopping list
4. Add download button
5. Test PDF output

## File Structure

```
src/
├── components/
│   └── views/
│       ├── DietPlannerView.tsx (Questionnaire wizard)
│       └── MealPlanDetailView.tsx (NEW - Detailed display)
├── components/
│   └── meal-plan/
│       ├── QuestionnaireStep1.tsx (Basic info)
│       ├── QuestionnaireStep2.tsx (Preferences)
│       ├── QuestionnaireStep3.tsx (Final review)
│       ├── MealPlanTable.tsx (7-day table display)
│       ├── NutritionCharts.tsx (Analytics charts)
│       ├── MealCompletionTracker.tsx (Checkboxes)
│       └── PDFExporter.tsx (PDF generation)
├── lib/
│   ├── mealGenerator.ts (AI logic)
│   ├── calorieCalculator.ts (Nutritional calculations)
│   └── recipeDatabase.ts (Recipe data)
└── types/
    └── meal-plan.ts (TypeScript interfaces)
```

## Current Status

✅ Database schema updated
✅ Basic questionnaire structure ready
✅ Calorie calculation implemented
✅ Simple meal generation logic working
✅ Dashboard integration exists

## Next Steps (Priority Order)

1. **Enhance questionnaire UI** - Add all preference options
2. **Expand meal generation** - Add more recipes and better logic
3. **Create detailed display component** - Build the table view shown in screenshots
4. **Add charts** - Implement analytics visualization
5. **Implement tracking** - Add completion checkboxes
6. **Add PDF export** - Implement download functionality

## Testing Checklist

- [ ] All form fields validate correctly
- [ ] Calorie calculation matches formulas
- [ ] Meal generation respects all restrictions
- [ ] No allergens in generated meals
- [ ] Macros balance correctly
- [ ] 7-day plan shows variety
- [ ] Charts display correctly
- [ ] Meal completion saves to database
- [ ] Dashboard updates with tracking data
- [ ] PDF generates with all information
- [ ] Responsive on all devices
- [ ] Loading states work properly
- [ ] Error handling for API failures

## Notes

- The current implementation uses simulated AI (rule-based selection)
- Real AI integration would require API keys and additional costs
- The meal database can be expanded with more recipes
- Charts should be interactive and responsive
- PDF export is optional but highly valuable
- Tracking system is crucial for user engagement
