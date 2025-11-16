// backend-mvp/routes/recipes.js
const express = require('express');
const { requireAuth } = require('../middleware/auth');
const db = require('../db/database'); // only if you want to log/save later

const router = express.Router();

/**
 * POST /api/recipes/generate
 * Body: { ingredients: string[], diet_type?: string, calories?: number }
 * For now we just return a dummy recipe so frontend works.
 */
router.post('/generate', requireAuth, (req, res) => {
  const userId = req.user.id;
  const { ingredients = [], diet_type, calories } = req.body || {};

  console.log('Recipe generate request from user:', userId, req.body);

  // Dummy response to unblock frontend for now
  const recipe = {
    title: 'Sample Healthy Bowl',
    description: 'A balanced bowl based on your ingredients.',
    ingredients: ingredients.length > 0 ? ingredients : ['oats', 'milk', 'banana'],
    steps: [
      'Combine the ingredients in a bowl.',
      'Cook or serve chilled as preferred.',
      'Enjoy your meal!',
    ],
    calories: calories || 450,
    diet_type: diet_type || 'general',
    protein: 20,
    carbs: 60,
    fats: 10,
  };

  return res.json({ recipe });
});

/**
 * (Optional) POST /api/recipes/from-mealplan
 * Example of another protected route
 */
router.post('/from-mealplan', requireAuth, (req, res) => {
  const userId = req.user.id;
  console.log('Recipe from-mealplan request from user:', userId, req.body);

  // Just return a placeholder for now
  return res.json({
    message: 'This endpoint will generate recipes from meal plan (stub).',
  });
});

module.exports = router;
