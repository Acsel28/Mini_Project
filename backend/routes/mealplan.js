const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth_mw');
const { generateMealPlan, searchMealsByIngredients } = require('../services/mealplan_service');
const { fetchUserProfile } = require('../services/user_profile_service');
const { generateMealPlanNarrative, generateRecipesFromIngredients } = require('../services/ai_content_service');

// POST /api/mealplan/generate
router.post('/generate', authMiddleware, async (req, res) => {
  const userId = req.user.sub;
  try {
    const plan = await generateMealPlan(userId);
    if (!plan) return res.status(404).json({ error: 'User or data not found' });
    const profile = fetchUserProfile(userId);
    let aiNarrative = null;

    if (profile) {
      try {
        aiNarrative = await generateMealPlanNarrative({ userProfile: profile, plan });
      } catch (err) {
        console.warn('[Mealplan] Narrative generation failed:', err.message || err);
      }
    }

    res.json({
      ...plan,
      aiNarrative,
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// POST /api/mealplan/recipes-by-ingredients
router.post('/recipes-by-ingredients', authMiddleware, async (req, res) => {
  const userId = req.user.sub;
  const { ingredients = [], maxRecipes = 3 } = req.body || {};

  if (!Array.isArray(ingredients) || ingredients.length === 0) {
    return res.status(400).json({ error: 'Ingredients array is required' });
  }

  const cleanedIngredients = ingredients
    .map((item) => item && item.toString().trim())
    .filter(Boolean);

  if (!cleanedIngredients.length) {
    return res.status(400).json({ error: 'No valid ingredients provided' });
  }

  try {
    const profile = fetchUserProfile(userId);
    const pantryMatches = searchMealsByIngredients(cleanedIngredients, {
      limit: Math.max(maxRecipes * 2, 6),
    });

    let recipeResponse = { recipes: [], source: 'pantry_fallback' };
    try {
      recipeResponse = await generateRecipesFromIngredients({
        ingredients: cleanedIngredients,
        userProfile: profile,
        pantryMatches,
        maxRecipes,
      });
    } catch (err) {
      console.warn('[Mealplan] Ingredient AI generation failed:', err.message || err);
    }

    res.json({
      ingredients: cleanedIngredients,
      recipes: recipeResponse.recipes,
      source: recipeResponse.source,
      pantryMatches,
    });
  } catch (err) {
    console.error('[Mealplan] Ingredient route error:', err);
    res.status(500).json({ error: 'Unable to generate recipes' });
  }
});

module.exports = router;
