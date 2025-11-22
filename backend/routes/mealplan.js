const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth_mw');
const { generateMealPlan } = require('../services/mealplan_service');

// POST /api/mealplan/generate
router.post('/generate', authMiddleware, async (req, res) => {
  const userId = req.user.sub;
  try {
    const plan = await generateMealPlan(userId);
    if (!plan) return res.status(404).json({ error: 'User or data not found' });
    res.json(plan);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
