require('dotenv').config();
const db = require('./database');
const { v4: uuidv4 } = require('uuid');

function seed() {
  const insertDisease = db.prepare(`INSERT OR IGNORE INTO disease_profiles (id, keyname, title, description, rules_json)
    VALUES (?, ?, ?, ?, ?)`);

  // example disease - Diabetes Type 2
  insertDisease.run(uuidv4(), 'diabetes_type2', 'Diabetes Type 2', 'Lower glycemic index, moderate carbs', JSON.stringify({
    macros: { protein_pct: [20,30], carbs_pct: [35,45], fat_pct: [30,40] },
    avoid: ['refined sugar', 'soda', 'white bread'],
    exercise_contraindications: []
  }));

  // sample exercise
  const insertExercise = db.prepare(`INSERT OR IGNORE INTO exercises (id, name, difficulty, equipment, steps_json, contraindications_json, muscles_json)
    VALUES (?, ?, ?, ?, ?, ?, ?)`);

  insertExercise.run(uuidv4(), 'Seated Knee Extensions', 'beginner', 'none',
    JSON.stringify(["Sit on chair", "Slowly extend leg", "Hold 2s", "Lower down"]),
    JSON.stringify(["recent knee surgery"]),
    JSON.stringify(["quadriceps"])
  );

  console.log('Seed complete');
}

seed();
