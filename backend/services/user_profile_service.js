const db = require('../db/database');

function fetchUserProfile(userId) {
  if (!userId) return null;
  return db
    .prepare(
      `SELECT 
        users.id,
        users.email,
        p.name,
        p.age,
        p.gender,
        p.height_cm,
        p.weight_kg,
        p.target_calories,
        p.diet_preference,
        p.meal_type,
        p.allergies,
        p.fitness_goal,
        p.activity_level,
        p.healthConditions,
        p.language
      FROM users
      LEFT JOIN user_profiles p ON users.id = p.user_id
      WHERE users.id = ?`
    )
    .get(userId);
}

module.exports = { fetchUserProfile };
