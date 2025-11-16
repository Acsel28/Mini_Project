const express = require('express');
const jwt = require('jsonwebtoken');
const db = require('../db/database');

const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret';
const ACCESS_TTL_SECONDS = 60 * 60 * 24 * 7; // 7 days

function signAccess(userId) {
  return jwt.sign({ sub: userId }, JWT_SECRET, {
    expiresIn: ACCESS_TTL_SECONDS,
  });
}

/**
 * POST /api/auth/register
 * Body: { email, password, name? }
 * Uses: users(id, email, password_hash)
 */
router.post('/register', (req, res) => {
  const { email, password, name } = req.body || {};

  if (!email || !password) {
    return res.status(400).json({ error: 'email and password required' });
  }

  try {
    // 1) check if email already exists
    const existing = db
      .prepare('SELECT id FROM users WHERE email = ?')
      .get(email);

    if (existing) {
      return res.status(400).json({ error: 'email exists' });
    }

    // 2) insert user (ONLY email + password_hash)
    // For this mini project we just store plain password in password_hash.
    db.prepare(
      'INSERT INTO users (email, password_hash) VALUES (?, ?)'
    ).run(email, password);

    // 3) fetch inserted user
    const user = db
      .prepare('SELECT id, email FROM users WHERE email = ?')
      .get(email);

    const userId = user.id;
    const accessToken = signAccess(userId);

    return res.json({
      user: { id: userId, email, name: name || null },
      accessToken,
    });
  } catch (err) {
    console.error('POST /api/auth/register error:', err);
    return res.status(500).json({ error: 'server error' });
  }
});

/**
 * POST /api/auth/login
 * Body: { email, password }
 * Uses: users(email, password_hash)
 */
router.post('/login', (req, res) => {
  const { email, password } = req.body || {};

  if (!email || !password) {
    return res.status(400).json({ error: 'email and password required' });
  }

  try {
    const user = db
      .prepare(
        'SELECT id, email, password_hash FROM users WHERE email = ?'
      )
      .get(email);

    // compare plain password to password_hash (for now)
    if (!user || user.password_hash !== password) {
      return res.status(400).json({ error: 'invalid credentials' });
    }

    const accessToken = signAccess(user.id);

    return res.json({
      user: { id: user.id, email: user.email },
      accessToken,
    });
  } catch (err) {
    console.error('POST /api/auth/login error:', err);
    return res.status(500).json({ error: 'server error' });
  }
});

module.exports = router;
