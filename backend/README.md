# Backend API Extensions

This backend includes new features for disease-based exercises and meal plan generation.

## New Tables

- `exercise_rules` (id, disease_id, recommended_exercise_ids, avoid_exercise_ids, warnings)
- `disease_diet_rules` (id, disease_id, avoid_foods, recommended_foods, constraints, macros_json)
- `demo_video_url` column added to `exercises` table

## New API Endpoints

- GET `/api/disease/:key/exercises` — returns recommended/avoid exercises for the given disease key
- POST `/api/mealplan/generate` — generate a personalized meal plan for the authenticated user

## Seeds

Run `npm run seed` to populate example diseases, exercises and rules.

## Notes

- The meal plan generation uses the `user_profiles` `target_calories`, `dietPreference` and `healthConditions` to filter meals.
- Exercise rules use `exercise_rules` table to map disease to recommended + avoid exercises.
