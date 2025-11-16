const express = require('express');
const router = express.Router();
const db = require('../db/database');
const { authMiddleware } = require('../middleware/auth_mw');
const llm = require('../services/llm_service');
const { v4: uuidv4 } = require('uuid');

/**
 * GET /meals - list meals (filter via query)
 */
router.get('/', authMiddleware, (req, res) => {
  const rows = db.prepare('SELECT id, title, calories, protein, carbs, fat, tags FROM meals LIMIT 100').all();
  res.json(rows);
});

/**
 * POST /meal-plans/generate
 * body: { date, target_calories, dietaryFlags: [], disease_profile_id }
 */
router.post('/generate', authMiddleware, async (req, res) => {
  const userId = req.user.sub;
  const body = req.body;
  // For MVP: call LLM service that returns structured JSON, but we provide a simple fallback plan
  try {
    const plan = await llm.generateMealPlan({
      userId,
      target_calories: body.target_calories || 1800,
      dietaryFlags: body.dietaryFlags || [],
      diseaseProfileId: body.disease_profile_id || null
    });

    // save plan in DB
    const id = uuidv4();
    db.prepare('INSERT INTO meal_plans (id, user_id, date, meals_json, total_calories, meta_json) VALUES (?,?,?,?,?,?)')
      .run(id, userId, body.date || new Date().toISOString().slice(0,10), JSON.stringify(plan.meals), plan.total_calories, JSON.stringify(plan.meta || {}));

    res.json({ id, plan });
  } catch (err) {
    console.error(err);
    // fallback simple static plan
    const fallback = {
      meals: [
        { title: 'Oats with fruit', calories: 400 },
        { title: 'Grilled chicken salad', calories: 600 },
        { title: 'Stir fry veggies + tofu', calories: 600 }
      ],
      total_calories: 1600,
      meta: { source: 'fallback' }
    };
    res.json({ id: uuidv4(), plan: fallback });
  }
});

module.exports = router;
