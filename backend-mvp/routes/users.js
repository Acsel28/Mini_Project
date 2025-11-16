const express = require('express');
const router = express.Router();
const db = require('../db/database');
const { authMiddleware } = require('../middleware/auth_mw');

router.get('/me', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const user = db.prepare('SELECT id, email, created_at FROM users WHERE id = ?').get(userId);
  const profile = db.prepare('SELECT * FROM user_profiles WHERE user_id = ?').get(userId);
  res.json({ user, profile });
});

router.put('/profile', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const fields = req.body;
  const stmt = db.prepare(`INSERT OR REPLACE INTO user_profiles (user_id, name, age, gender, height_cm, weight_kg, language, target_calories, bmr, accessibility_flags, disease_profile_id)
    VALUES (?,?,?,?,?,?,?,?,?,?,?)`);
  stmt.run(
    userId,
    fields.name || '',
    fields.age || null,
    fields.gender || null,
    fields.height_cm || null,
    fields.weight_kg || null,
    fields.language || 'en',
    fields.target_calories || null,
    fields.bmr || null,
    fields.accessibility_flags ? JSON.stringify(fields.accessibility_flags) : null,
    fields.disease_profile_id || null
  );
  res.json({ ok: true });
});

module.exports = router;
