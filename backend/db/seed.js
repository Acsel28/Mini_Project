require('dotenv').config();
const db = require('./database');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcryptjs');

function seedDiseaseProfiles() {
  const insert = db.prepare(`
    INSERT OR IGNORE INTO disease_profiles
    (id, keyname, title, description, rules_json)
    VALUES (?,?,?,?,?)
  `);

  insert.run(
    uuidv4(),
    "diabetes_type2",
    "Diabetes Type 2",
    "Lower glycemic index, moderate carbs",
    JSON.stringify({
      macros: { protein_pct: [20, 30], carbs_pct: [35, 45], fat_pct: [30, 40] },
      avoid: ["refined sugar", "soda", "white bread"],
      exercise_contraindications: []
    })
  );

  insert.run(
    uuidv4(),
    "hypertension",
    "Hypertension",
    "Low sodium, balanced macros",
    JSON.stringify({
      macros: { protein_pct: [20, 30], carbs_pct: [40, 50], fat_pct: [20, 30] },
      avoid: ["salt", "processed foods"],
      exercise_contraindications: []
    })
  );

  console.log("Seeded disease profiles");
}

function seedExercises() {
  const insert = db.prepare(`
    INSERT OR IGNORE INTO exercises
    (id, name, difficulty, equipment, steps_json, contraindications_json, muscles_json)
    VALUES (?,?,?,?,?,?,?)
  `);

  insert.run(
    uuidv4(),
    "Seated Knee Extension",
    "beginner",
    "none",
    JSON.stringify(["Sit", "Extend leg", "Hold", "Lower"]),
    JSON.stringify(["recent knee surgery"]),
    JSON.stringify(["quadriceps"])
  );

  insert.run(
    uuidv4(),
    "Walking",
    "beginner",
    "none",
    JSON.stringify(["Walk at comfortable speed"]),
    JSON.stringify([]),
    JSON.stringify(["legs"])
  );

  console.log("Seeded exercises");
}

function seedMeals() {
  const file = path.join(__dirname, "sample_meals.json");
  if (!fs.existsSync(file)) {
    console.log("sample_meals.json not found. Skipping meals.");
    return;
  }

  const data = JSON.parse(fs.readFileSync(file, "utf8"));

  const insert = db.prepare(`
    INSERT INTO meals
    (id, title, calories, protein, carbs, fat, ingredients_json, recipe_json, tags)
    VALUES (?,?,?,?,?,?,?,?,?)
  `);

  for (const m of data) {
    insert.run(
      uuidv4(),
      m.title || "Untitled",
      m.calories || 0,
      m.protein || 0,
      m.carbs || 0,
      m.fat || 0,
      JSON.stringify(m.ingredients || []),
      JSON.stringify(m.recipe || {}),
      (m.tags || []).join(",")
    );
  }

  console.log("Seeded meals");
}

function seedTestUser() {
  const id = uuidv4();
  const hash = bcrypt.hashSync("test123", 10);
  const now = Math.floor(Date.now() / 1000);

  db.prepare(`
    INSERT OR IGNORE INTO users
    (id, email, password_hash, created_at)
    VALUES (?,?,?,?)
  `).run(id, "test@example.com", hash, now);

  db.prepare(`
    INSERT OR IGNORE INTO user_profiles
    (user_id, name)
    VALUES (?,?)
  `).run(id, "Test User");

  console.log("Created test user: test@example.com / test123");
}

(function run() {
  seedDiseaseProfiles();
  seedExercises();
  seedMeals();
  seedTestUser();
  console.log("Seeding complete.");
})();
