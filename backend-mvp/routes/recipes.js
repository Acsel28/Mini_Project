const express = require('express');
const router = express.Router();
const db = require('../db/database');
const { authMiddleware } = require('../middleware/auth_mw');
const llm = require('../services/llm_service');
const { v4: uuidv4 } = require('uuid');

router.post('/from-ingredients', authMiddleware, async (req, res) => {
  const { ingredients } = req.body;
  // For MVP: simple LLM stub or heuristic
  try {
    const plan = await llm.generateRecipeFromIngredients({ ingredients });
    return res.json(plan);
  } catch (err) {
    // fallback: return a very simple recipe
    return res.json({
      title: 'Quick Stir Fry',
      ingredients,
      instructions: [
        'Chop ingredients',
        'Heat pan with oil',
        'Cook vegetables 5-7 min',
        'Season and serve'
      ]
    });
  }
});

module.exports = router;
