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
      p.disease_profile_id,

      -- disease info
      d.title as disease_name,
      d.keyname as disease_key,

      -- personalization fields
      p.diet_preference,
      p.meal_type,
      p.allergies,
      p.fitness_goal,
      p.activity_level,

      -- legacy ui fields
      p.goal,
      p.accessibilityMode,
      p.healthConditions

    FROM users
    LEFT JOIN user_profiles p ON users.id = p.user_id
    LEFT JOIN disease_profiles d ON p.disease_profile_id = d.id
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
    disease: u.disease_name,
    disease_key: u.disease_key,
    disease_profile_id: u.disease_profile_id,

    // personalization data
    diet_preference: u.diet_preference,
    meal_type: u.meal_type,
    allergies: u.allergies,
    fitness_goal: u.fitness_goal,
    activity_level: u.activity_level,

    // legacy ui fallbacks
    goal: u.goal || "healthy_eating",
    accessibilityMode: Boolean(u.accessibilityMode),
    healthConditions: u.healthConditions ? JSON.parse(u.healthConditions) : [],
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
    accessibilityMode,
    healthConditions,
    disease,
    diet_preference,
    meal_type,
    allergies,
    fitness_goal,
    activity_level
  } = req.body;

  try {
    // Prepare update query
    const updates = [];
    const values = [];

    if (name !== undefined) {
      updates.push("name = ?");
      values.push(name);
    }
    if (age !== undefined) {
      updates.push("age = ?");
      values.push(age);
    }
    if (gender !== undefined) {
      updates.push("gender = ?");
      values.push(gender);
    }
    if (height_cm !== undefined) {
      updates.push("height_cm = ?");
      values.push(height_cm);
    }
    if (weight_kg !== undefined) {
      updates.push("weight_kg = ?");
      values.push(weight_kg);
    }
    if (language !== undefined) {
      updates.push("language = ?");
      values.push(language);
    }
    if (target_calories !== undefined) {
      updates.push("target_calories = ?");
      values.push(target_calories);
    }
    if (goal !== undefined) {
      updates.push("goal = ?");
      values.push(goal);
    }
    if (accessibilityMode !== undefined) {
      updates.push("accessibilityMode = ?");
      values.push(accessibilityMode ? 1 : 0);
    }
    if (healthConditions !== undefined) {
      updates.push("healthConditions = ?");
      values.push(JSON.stringify(healthConditions || []));
    }
    if (disease !== undefined) {
      const diseaseId = disease ? db.prepare("SELECT id FROM disease_profiles WHERE keyname = ? OR title = ?").get(disease.toLowerCase(), disease)?.id : null;
      updates.push("disease_profile_id = ?");
      values.push(diseaseId || null);
    }

    // Personalization fields
    if (diet_preference !== undefined) {
      updates.push("diet_preference = ?");
      values.push(diet_preference);
    }
    if (meal_type !== undefined) {
      updates.push("meal_type = ?");
      values.push(meal_type);
    }
    if (allergies !== undefined) {
      updates.push("allergies = ?");
      values.push(allergies);
    }
    if (fitness_goal !== undefined) {
      updates.push("fitness_goal = ?");
      values.push(fitness_goal);
    }
    if (activity_level !== undefined) {
      updates.push("activity_level = ?");
      values.push(activity_level);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: "No fields to update" });
    }

    // Add user_id at the end
    values.push(userId);

    const query = `UPDATE user_profiles SET ${updates.join(", ")} WHERE user_id = ?`;
    
    const result = db.prepare(query).run(...values);

    if (result.changes === 0) {
      return res.status(404).json({ error: "User profile not found" });
    }

    console.log(`✓ Profile updated for user ${userId}:`, req.body);

    res.json({ 
      success: true, 
      message: "Profile updated successfully",
      updated_fields: Object.keys(req.body).length
    });
  } catch (err) {
    console.error("Profile update error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

module.exports = router;
