const express = require('express');
const db = require('../db/database');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

/**
 * PUT /api/users/profile
 * Upsert profile for the authenticated user
 * Matches: user_profiles schema from reset-db.js
 */
router.put('/profile', requireAuth, (req, res) => {
  const userId = req.user.id;
  const {
    age,
    gender,
    height_cm,
    weight_kg,
    language,
    disease_profile_id,
    target_calories,
    accessibility_flags,
  } = req.body || {};

  try {
    const existing = db
      .prepare('SELECT user_id FROM user_profiles WHERE user_id = ?')
      .get(userId);

    if (existing) {
      db.prepare(
        'UPDATE user_profiles ' +
          'SET age = ?, gender = ?, height_cm = ?, weight_kg = ?, ' +
          'language = ?, disease_profile_id = ?, ' +
          'target_calories = ?, accessibility_flags = ? ' +
          'WHERE user_id = ?'
      ).run(
        age ?? null,
        gender ?? null,
        height_cm ?? null,
        weight_kg ?? null,
        language ?? 'en',
        disease_profile_id ?? null,
        target_calories ?? null,
        accessibility_flags ? JSON.stringify(accessibility_flags) : null,
        userId
      );
    } else {
      db.prepare(
        'INSERT INTO user_profiles ' +
          '(user_id, age, gender, height_cm, weight_kg, ' +
          ' language, disease_profile_id, ' +
          ' target_calories, accessibility_flags) ' +
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
      ).run(
        userId,
        age ?? null,
        gender ?? null,
        height_cm ?? null,
        weight_kg ?? null,
        language ?? 'en',
        disease_profile_id ?? null,
        target_calories ?? null,
        accessibility_flags ? JSON.stringify(accessibility_flags) : null
      );
    }

    return res.json({ ok: true });
  } catch (err) {
    console.error('PUT /api/users/profile error:', err);
    return res.status(500).json({ error: 'db error' });
  }
});

/**
 * GET /api/users/me
 * Returns basic user and profile info
 */
router.get('/me', requireAuth, (req, res) => {
  const userId = req.user.id;

  try {
    const user = db
      .prepare('SELECT id, email FROM users WHERE id = ?')
      .get(userId);

    const profile = db
      .prepare(
        'SELECT age, gender, height_cm, weight_kg, language, ' +
          'disease_profile_id, target_calories, ' +
          'accessibility_flags ' +
          'FROM user_profiles WHERE user_id = ?'
      )
      .get(userId);

    return res.json({ user, profile });
  } catch (err) {
    console.error('GET /api/users/me error:', err);
    return res.status(500).json({ error: 'db error' });
  }
});

module.exports = router;
