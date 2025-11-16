// backend-mvp/routes/meals.js
const express = require('express');
const db = require('../db/database');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

/**
 * GET /api/meals/today
 * Example protected route that fetches today's meals for the logged-in user
 */
router.get('/today', requireAuth, (req, res) => {
  const userId = req.user.id;
  try {
    const meals = db
      .prepare(
        `SELECT id, user_id, date, meal_type, calories, protein, carbs, fats
         FROM meals
         WHERE user_id = ? AND date = date('now', 'localtime')`
      )
      .all(userId);

    return res.json({ meals });
  } catch (err) {
    console.error('GET /meals/today error:', err);
    return res.status(500).json({ error: 'internal server error' });
  }
});

/**
 * (Optional) GET /api/meals
 * List all meals for current user
 */
router.get('/', requireAuth, (req, res) => {
  const userId = req.user.id;
  try {
    const meals = db
      .prepare(
        `SELECT id, user_id, date, meal_type, calories, protein, carbs, fats
         FROM meals
         WHERE user_id = ?
         ORDER BY date DESC`
      )
      .all(userId);

    return res.json({ meals });
  } catch (err) {
    console.error('GET /meals error:', err);
    return res.status(500).json({ error: 'internal server error' });
  }
});

/**
 * (Optional) POST /api/meals
 * Create a new meal for current user
 */
router.post('/', requireAuth, (req, res) => {
  const userId = req.user.id;
  const {
    date,
    meal_type,
    calories,
    protein,
    carbs,
    fats,
  } = req.body;

  try {
    const stmt = db.prepare(
      `INSERT INTO meals (user_id, date, meal_type, calories, protein, carbs, fats)
       VALUES (?, ?, ?, ?, ?, ?, ?)`
    );

    const result = stmt.run(
      userId,
      date || new Date().toISOString().slice(0, 10), // yyyy-mm-dd
      meal_type || 'other',
      calories ?? 0,
      protein ?? 0,
      carbs ?? 0,
      fats ?? 0
    );

    return res.status(201).json({
      id: result.lastInsertRowid,
      user_id: userId,
      date,
      meal_type,
      calories,
      protein,
      carbs,
      fats,
    });
  } catch (err) {
    console.error('POST /meals error:', err);
    return res.status(500).json({ error: 'internal server error' });
  }
});

module.exports = router;
