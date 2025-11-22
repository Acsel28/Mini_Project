const express = require('express');
const router = express.Router();
const db = require('../db/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const JWT_SECRET = process.env.JWT_SECRET;
const ACCESS_EXP = parseInt(process.env.JWT_ACCESS_EXP);
const REFRESH_EXP = parseInt(process.env.JWT_REFRESH_EXP);
const BCRYPT_ROUNDS = parseInt(process.env.BCRYPT_ROUNDS || '12');

// Create JWT access token
function createAccessToken(userId) {
  return jwt.sign({ sub: userId }, JWT_SECRET, { expiresIn: ACCESS_EXP });
}

// Helper to get disease profile ID from disease name/keyname
function getDiseaseIdByKeyname(keyname) {
  if (!keyname) return null;
  const disease = db.prepare("SELECT id FROM disease_profiles WHERE keyname = ? OR title = ?").get(keyname.toLowerCase(), keyname);
  return disease ? disease.id : null;
}

function isPasswordStrong(password = '') {
  const hasLength = password.length >= 8;
  const hasUpper = /[A-Z]/.test(password);
  const hasNumber = /\d/.test(password);
  const hasSymbol = /[^A-Za-z0-9]/.test(password);
  return hasLength && hasUpper && hasNumber && hasSymbol;
}

// ------------------------
// REGISTER
// ------------------------
router.post('/register', async (req, res) => {
  const { 
    email, password, name, height_cm, weight_kg, age, gender,
    disease, diet_preference, meal_type, allergies, 
    fitness_goal, activity_level, target_calories
  } = req.body;

  if (!email || !password)
    return res.status(400).json({ error: "Email & password required" });

  if (!isPasswordStrong(password)) {
    return res.status(400).json({
      error: "Password must be at least 8 characters and include an uppercase letter, number, and symbol",
    });
  }

  const existing = db.prepare("SELECT * FROM users WHERE email=?").get(email);
  if (existing) return res.status(400).json({ error: "Email already exists" });

  const id = uuidv4();
  const hash = await bcrypt.hash(password, BCRYPT_ROUNDS);
  const now = Math.floor(Date.now() / 1000);

  db.prepare("INSERT INTO users (id,email,password_hash,created_at) VALUES (?,?,?,?)")
    .run(id, email, hash, now);

  // Get disease ID if provided
  const disease_profile_id = disease ? getDiseaseIdByKeyname(disease) : null;

  // Create profile with all user data
  db.prepare(`
    INSERT INTO user_profiles (
      user_id, name, age, gender, height_cm, weight_kg, disease_profile_id,
      diet_preference, meal_type, allergies, fitness_goal, activity_level, target_calories
    )
    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
  `).run(
    id, 
    name || "", 
    age || null, 
    gender || null, 
    height_cm || null, 
    weight_kg || null, 
    disease_profile_id,
    diet_preference || null,
    meal_type || null,
    allergies || null,
    fitness_goal || null,
    activity_level || 'moderately_active',
    target_calories || 2000
  );

  // Create tokens
  const accessToken = createAccessToken(id);
  const refreshPlain = uuidv4();
  const refreshHash = await bcrypt.hash(refreshPlain, BCRYPT_ROUNDS);

  db.prepare(`
    INSERT INTO refresh_tokens (id,user_id,token_hash,expires_at,created_at)
    VALUES (?,?,?,?,?)
  `).run(uuidv4(), id, refreshHash, now + REFRESH_EXP, now);

  // Fetch the created profile to return complete user data
  const profile = db.prepare(`
    SELECT 
      p.name, p.age, p.gender, p.height_cm, p.weight_kg, p.disease_profile_id,
      p.diet_preference, p.meal_type, p.allergies, p.fitness_goal, p.activity_level, p.target_calories,
      d.title as disease_name, d.keyname as disease_key
    FROM user_profiles p
    LEFT JOIN disease_profiles d ON p.disease_profile_id = d.id
    WHERE p.user_id = ?
  `).get(id);

  res.json({
    user: { 
      id, 
      email,
      name: profile?.name || name,
      age: profile?.age,
      gender: profile?.gender,
      height_cm: profile?.height_cm,
      weight_kg: profile?.weight_kg,
      target_calories: profile?.target_calories,
      disease: profile?.disease_name,
      disease_key: profile?.disease_key,
      diet_preference: profile?.diet_preference,
      meal_type: profile?.meal_type,
      allergies: profile?.allergies,
      fitness_goal: profile?.fitness_goal,
      activity_level: profile?.activity_level
    },
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
  const refreshHash = await bcrypt.hash(refreshPlain, BCRYPT_ROUNDS);

  const now = Math.floor(Date.now() / 1000);
  db.prepare(`
    INSERT INTO refresh_tokens (id,user_id,token_hash,expires_at,created_at)
    VALUES (?,?,?,?,?)
  `).run(uuidv4(), user.id, refreshHash, now + REFRESH_EXP, now);

  // Fetch user profile with all personalization data
  const profile = db.prepare(`
    SELECT 
      p.name, p.age, p.gender, p.height_cm, p.weight_kg, p.disease_profile_id,
      p.diet_preference, p.meal_type, p.allergies, p.fitness_goal, p.activity_level, p.target_calories,
      d.title as disease_name, d.keyname as disease_key
    FROM user_profiles p
    LEFT JOIN disease_profiles d ON p.disease_profile_id = d.id
    WHERE p.user_id = ?
  `).get(user.id);

  res.json({
    user: { 
      id: user.id, 
      email: user.email,
      name: profile?.name,
      age: profile?.age,
      gender: profile?.gender,
      height_cm: profile?.height_cm,
      weight_kg: profile?.weight_kg,
      target_calories: profile?.target_calories,
      disease: profile?.disease_name,
      disease_key: profile?.disease_key,
      diet_preference: profile?.diet_preference,
      meal_type: profile?.meal_type,
      allergies: profile?.allergies,
      fitness_goal: profile?.fitness_goal,
      activity_level: profile?.activity_level
    },
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
