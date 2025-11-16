
const express = require('express');
const router = express.Router();
const db = require('../db/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const JWT_SECRET = process.env.JWT_SECRET || 'secret';
const ACCESS_EXP = parseInt(process.env.JWT_ACCESS_EXP || '900'); // seconds
const REFRESH_EXP = parseInt(process.env.JWT_REFRESH_EXP || '1209600'); // seconds

console.log("DB VALUE:", db);
console.log("TYPE OF DB:", typeof db);
function signAccess(userId) {
  return jwt.sign({ sub: userId }, JWT_SECRET, { expiresIn: ACCESS_EXP });
}

router.post('/register', async (req, res) => {
  const { email, password, name } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'email+password required' });
  const existing = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
  if (existing) return res.status(400).json({ error: 'email exists' });
  const id = uuidv4();
  const hash = await bcrypt.hash(password, 10);
  const now = Math.floor(Date.now()/1000);
  db.prepare('INSERT INTO users (id,email,password_hash,created_at) VALUES (?,?,?,?)').run(id, email, hash, now);
  // create basic profile
  db.prepare('INSERT INTO user_profiles (user_id, name) VALUES (?,?)').run(id, name || '');
  const access = signAccess(id);
  const refreshId = uuidv4();
  const refreshHash = await bcrypt.hash(refreshId, 10);
  db.prepare('INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at, created_at) VALUES (?,?,?,?,?)')
    .run(uuidv4(), id, refreshHash, now + REFRESH_EXP, now);
  return res.json({ user: { id, email }, accessToken: access, refreshToken: refreshId });
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email);
  if (!user) return res.status(400).json({ error: 'invalid credentials' });
  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) return res.status(400).json({ error: 'invalid credentials' });
  const access = signAccess(user.id);
  // create refresh token
  const refreshId = uuidv4();
  const refreshHash = await bcrypt.hash(refreshId, 10);
  const now = Math.floor(Date.now()/1000);
  db.prepare('INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at, created_at) VALUES (?,?,?,?,?)')
    .run(uuidv4(), user.id, refreshHash, now + REFRESH_EXP, now);
  return res.json({ user: { id: user.id, email }, accessToken: access, refreshToken: refreshId });
});

router.post('/refresh', async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(400).json({ error: 'refreshToken required' });
  // find token by scanning refresh_tokens table (we store only hashed tokens)
  const tokens = db.prepare('SELECT * FROM refresh_tokens WHERE expires_at > ?').all(Math.floor(Date.now()/1000));
  for (const t of tokens) {
    const match = await bcrypt.compare(refreshToken, t.token_hash);
    if (match) {
      // issue new access token
      const access = signAccess(t.user_id);
      return res.json({ accessToken: access });
    }
  }
  return res.status(401).json({ error: 'invalid refresh token' });
});

module.exports = router;
