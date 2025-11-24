# Backend API Extensions

This backend includes new features for disease-based exercises and meal plan generation.

## New Tables

- `exercise_rules` (id, disease_id, recommended_exercise_ids, avoid_exercise_ids, warnings)
- `disease_diet_rules` (id, disease_id, avoid_foods, recommended_foods, constraints, macros_json)
- `demo_video_url` column added to `exercises` table

## New API Endpoints

- GET `/api/disease/:key/exercises` — returns recommended/avoid exercises for the given disease key
- POST `/api/mealplan/generate` — generate a personalized meal plan for the authenticated user
- POST `/api/mealplan/recipes-by-ingredients` — convert pantry ingredients into chef-style recipes with Groq + pantry fallbacks

### Ingredient-to-Recipe Flow

```http
POST /api/mealplan/recipes-by-ingredients
Authorization: Bearer <JWT>
Content-Type: application/json

{
	"ingredients": ["rice", "dal", "onion"],
	"maxRecipes": 4
}
```

Response payload sample:

```json
{
	"ingredients": ["rice", "dal", "onion"],
	"recipes": [{ "id": "ai_recipe_1", "title": "Masala Khichdi", ... }],
	"source": "llm",
	"pantryMatches": [{ "id": 12, "title": "Dal Rice Bowl", ... }]
}
```

The service first ranks SQLite pantry meals, then prompts the PantryChef LLM for suggestions. If the LLM call fails, the API automatically falls back to high-confidence pantry matches so the Flutter client always receives content.

## Seeds

Run `npm run seed` to populate example diseases, exercises and rules.

## Notes

- The meal plan generation uses the `user_profiles` `target_calories`, `dietPreference` and `healthConditions` to filter meals.
- Exercise rules use `exercise_rules` table to map disease to recommended + avoid exercises.
- LLM features now support Google Gemini (text generation, narratives). Set `GEMINI_API_KEY`, `GEMINI_MODEL`, and optionally `GEMINI_MIN_CALL_INTERVAL_MS` in `.env`. PantryChef ingredient recipes rely on Groq, so also configure `GROQ_API_KEY` (and `GROQ_MODEL`) for best results; the service falls back to pantry matches if Groq is unavailable.
