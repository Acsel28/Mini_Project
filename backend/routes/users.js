const express = require("express");
const router = express.Router();
const db = require("../db/database");
const { authMiddleware } = require("../middleware/auth_mw");

// ------------------------------
// GET CURRENT USER /me
// ------------------------------
router.get("/me", authMiddleware, (req, res) => {
  const userId = req.user.sub;

  const u = db.prepare(`
    SELECT 
      users.id, users.email,
      p.name, p.age, p.gender,
      p.height_cm, p.weight_kg,
      p.language, p.target_calories,

      -- new frontend fields
      p.goal,
      p.dietPreference,
      p.accessibilityMode,
      p.healthConditions,
      p.activityLevel

    FROM users
    LEFT JOIN user_profiles p ON users.id = p.user_id
    WHERE users.id = ?
  `).get(userId);

  if (!u)
    return res.status(404).json({ error: "User not found" });

  res.json({
    id: u.id,
    email: u.email,
    name: u.name,
    age: u.age,
    gender: u.gender,
    height_cm: u.height_cm,
    weight_kg: u.weight_kg,
    language: u.language,
    target_calories: u.target_calories,

    // these won't crash Flutter now:
    goal: u.goal || "healthy_eating",
    dietPreference: u.dietPreference || "vegetarian",
    accessibilityMode: Boolean(u.accessibilityMode),
    healthConditions: u.healthConditions ? JSON.parse(u.healthConditions) : [],
    activityLevel: u.activityLevel || "moderately_active",
  });
});

// ------------------------------
// UPDATE PROFILE
// ------------------------------
router.put("/profile", authMiddleware, (req, res) => {
  const userId = req.user.sub;

  const {
    name,
    age,
    gender,
    height_cm,
    weight_kg,
    language,
    target_calories,

    goal,
    dietPreference,
    accessibilityMode,
    healthConditions,
    activityLevel
  } = req.body;

  db.prepare(`
    UPDATE user_profiles
    SET name=?, age=?, gender=?, height_cm=?, weight_kg=?, language=?, 
        target_calories=?, 
        goal=?, dietPreference=?, accessibilityMode=?, 
        healthConditions=?, activityLevel=?
    WHERE user_id=?
  `).run(
    name,
    age,
    gender,
    height_cm,
    weight_kg,
    language,
    target_calories,
    goal,
    dietPreference,
    accessibilityMode ? 1 : 0,
    JSON.stringify(healthConditions || []),
    activityLevel,
    userId
  );

  res.json({ success: true });
});

module.exports = router;
