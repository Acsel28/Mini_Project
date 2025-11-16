const express = require('express');
const router = express.Router();
const db = require('../db/database');
const { authMiddleware } = require('../middleware/auth_mw');
const { v4: uuidv4 } = require('uuid');

router.get('/', authMiddleware, (req, res) => {
  const rows = db.prepare('SELECT id, name, difficulty, equipment FROM exercises').all();
  res.json(rows);
});

router.post('/log', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const { exercise_id, reps, duration_sec, date } = req.body;
  const id = uuidv4();
  db.prepare('INSERT INTO exercise_logs (id, user_id, exercise_id, reps, duration_sec, date) VALUES (?,?,?,?,?,?)')
    .run(id, userId, exercise_id, reps || 0, duration_sec || 0, date || new Date().toISOString());
  res.json({ ok: true, id });
});

module.exports = router;
