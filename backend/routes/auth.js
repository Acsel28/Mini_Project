const express = require('express');
const router = express.Router();
const db = require('../db/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const JWT_SECRET = process.env.JWT_SECRET;
const ACCESS_EXP = parseInt(process.env.JWT_ACCESS_EXP);
const REFRESH_EXP = parseInt(process.env.JWT_REFRESH_EXP);

// Create JWT access token
function createAccessToken(userId) {
  return jwt.sign({ sub: userId }, JWT_SECRET, { expiresIn: ACCESS_EXP });
}

// ------------------------
// REGISTER
// ------------------------
router.post('/register', async (req, res) => {
  const { email, password, name } = req.body;

  if (!email || !password)
    return res.status(400).json({ error: "Email & password required" });

  const existing = db.prepare("SELECT * FROM users WHERE email=?").get(email);
  if (existing) return res.status(400).json({ error: "Email already exists" });

  const id = uuidv4();
  const hash = await bcrypt.hash(password, 10);
  const now = Math.floor(Date.now() / 1000);

  db.prepare("INSERT INTO users (id,email,password_hash,created_at) VALUES (?,?,?,?)")
    .run(id, email, hash, now);

  // Create empty profile but include name
  db.prepare(`
    INSERT INTO user_profiles (user_id, name)
    VALUES (?,?)
  `).run(id, name || "");

  // Create tokens
  const accessToken = createAccessToken(id);
  const refreshPlain = uuidv4();
  const refreshHash = await bcrypt.hash(refreshPlain, 10);

  db.prepare(`
    INSERT INTO refresh_tokens (id,user_id,token_hash,expires_at,created_at)
    VALUES (?,?,?,?,?)
  `).run(uuidv4(), id, refreshHash, now + REFRESH_EXP, now);

  res.json({
    user: { id, email },
    accessToken,
    refreshToken: refreshPlain
  });
});

// ------------------------
// LOGIN
// ------------------------
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  const user = db.prepare("SELECT * FROM users WHERE email=?").get(email);
  if (!user) return res.status(400).json({ error: "Invalid credentials" });

  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) return res.status(400).json({ error: "Invalid credentials" });

  const accessToken = createAccessToken(user.id);
  const refreshPlain = uuidv4();
  const refreshHash = await bcrypt.hash(refreshPlain, 10);

  const now = Math.floor(Date.now() / 1000);
  db.prepare(`
    INSERT INTO refresh_tokens (id,user_id,token_hash,expires_at,created_at)
    VALUES (?,?,?,?,?)
  `).run(uuidv4(), user.id, refreshHash, now + REFRESH_EXP, now);

  res.json({
    user: { id: user.id, email: user.email },
    accessToken,
    refreshToken: refreshPlain
  });
});

// ------------------------
// REFRESH TOKEN
// ------------------------
router.post('/refresh', async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken)
    return res.status(400).json({ error: "refreshToken required" });

  const now = Math.floor(Date.now() / 1000);
  const tokens = db.prepare("SELECT * FROM refresh_tokens WHERE expires_at > ?").all(now);

  for (const t of tokens) {
    const match = await bcrypt.compare(refreshToken, t.token_hash);
    if (match) {
      return res.json({ accessToken: createAccessToken(t.user_id) });
    }
  }

  res.status(401).json({ error: "Invalid refresh token" });
});

module.exports = router;
