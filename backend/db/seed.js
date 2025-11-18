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
    "Type 2 Diabetes",
    "Manage blood sugar through balanced diet, regular exercise, and weight management",
    JSON.stringify({
      macros: { protein_pct: [20, 30], carbs_pct: [35, 45], fat_pct: [30, 40] },
      avoid: ["refined sugar", "soda", "white bread", "sweetened beverages", "candy"],
      recommended: ["whole grains", "leafy greens", "lean proteins", "berries", "nuts"],
      exercise_frequency: "150 min/week moderate intensity",
      risk_level: "high"
    })
  );

  insert.run(
    uuidv4(),
    "hypertension",
    "High Blood Pressure",
    "Reduce sodium, manage stress, maintain healthy weight with regular exercise",
    JSON.stringify({
      macros: { protein_pct: [20, 30], carbs_pct: [40, 50], fat_pct: [20, 30] },
      sodium_limit_mg: 2300,
      avoid: ["salt", "processed foods", "cured meats", "cheese", "canned soups"],
      recommended: ["potassium-rich foods", "whole grains", "lean meats", "low-fat dairy", "fresh fruits"],
      exercise_frequency: "30 min/day moderate intensity",
      risk_level: "high"
    })
  );

  console.log("Seeded disease profiles");
}

// Add additional disease profiles with detailed rules
function seedMoreDiseaseProfiles() {
  const insert = db.prepare(`
    INSERT OR IGNORE INTO disease_profiles
    (id, keyname, title, description, rules_json)
    VALUES (?,?,?,?,?)
  `);

  insert.run(uuidv4(), 'lower_back_pain', 'Lower Back Pain', 'Strengthen core and improve flexibility with targeted exercises', JSON.stringify({
    exercise_focus: ["core strengthening", "flexibility", "low-impact"],
    avoid_exercises: ["heavy deadlifts", "intense twisting", "heavy squats"],
    recommended_activities: ["walking", "swimming", "yoga", "pilates"],
    duration_per_session: "30-45 minutes"
  }));

  insert.run(uuidv4(), 'knee_pain', 'Knee Pain', 'Low-impact exercises to strengthen knee without excess load', JSON.stringify({
    exercise_focus: ["quadriceps strengthening", "low-impact cardio", "flexibility"],
    avoid_exercises: ["running", "jumping", "high-impact sports", "heavy leg press"],
    recommended_activities: ["swimming", "cycling", "walking", "elliptical"],
    duration_per_session: "20-30 minutes"
  }));

  insert.run(uuidv4(), 'pcos', 'PCOS (Polycystic Ovary Syndrome)', 'Manage hormones through diet and consistent exercise to improve insulin sensitivity', JSON.stringify({
    macros: { protein_pct: [30, 35], carbs_pct: [35, 40], fat_pct: [25, 35] },
    avoid: ["refined carbs", "sugary foods", "trans fats", "processed meats"],
    recommended: ["lean proteins", "complex carbs", "healthy fats", "leafy greens", "seeds"],
    exercise_frequency: "4-5 days/week",
    exercise_types: ["strength training", "moderate cardio", "flexibility work"],
    risk_level: "medium"
  }));

  insert.run(uuidv4(), 'thyroid', 'Thyroid Disorder', 'Support thyroid function with iodine, selenium, and appropriate exercise', JSON.stringify({
    avoid: ["excess iodine", "goitrogenic foods", "caffeine excess", "processed foods"],
    recommended: ["selenium-rich foods", "fish", "whole grains", "vegetables", "moderate iodine"],
    exercise_frequency: "30 min/day moderate intensity",
    exercise_types: ["walking", "yoga", "light strength training"],
    medications: "take at least 4 hours apart from supplements",
    risk_level: "medium"
  }));

  insert.run(uuidv4(), 'obesity', 'Obesity', 'Sustainable weight loss through calorie deficit, healthy diet, and progressive exercise', JSON.stringify({
    macros: { protein_pct: [25, 35], carbs_pct: [40, 50], fat_pct: [20, 30] },
    calorie_deficit: "500-750 kcal/day",
    avoid: ["sugary drinks", "fried foods", "processed snacks", "high-calorie desserts"],
    recommended: ["whole grains", "vegetables", "lean proteins", "fruits", "nuts"],
    exercise_frequency: "150-300 min/week",
    exercise_progression: "start low-impact, gradually increase intensity",
    risk_level: "high"
  }));

  console.log('Seeded additional disease profiles');
}

function seedExercises() {
  const insert = db.prepare(`
    INSERT OR IGNORE INTO exercises
    (id, name, difficulty, equipment, steps_json, contraindications_json, muscles_json, demo_video_url)
    VALUES (?,?,?,?,?,?,?,?)
  `);

  // Low Back Pain Exercises
  insert.run(
    uuidv4(),
    "Pelvic Tilt",
    "beginner",
    "none",
    JSON.stringify([
      "Lie on your back with knees bent, feet flat on floor",
      "Tilt pelvis toward you, tightening abdominal muscles",
      "Hold for 2-3 seconds",
      "Relax and return to neutral",
      "Repeat 15 times"
    ]),
    JSON.stringify(["severe back pain", "recent spinal surgery"]),
    JSON.stringify(["core", "lower_back"]),
    null
  );

  insert.run(
    uuidv4(),
    "Cat-Cow Stretch",
    "beginner",
    "none",
    JSON.stringify([
      "Start on hands and knees (tabletop position)",
      "Arch your back, drop your belly, look up (Cow)",
      "Hold for 1-2 seconds",
      "Round your spine, tuck chin (Cat)",
      "Hold for 1-2 seconds",
      "Repeat 10-15 times slowly"
    ]),
    JSON.stringify(["severe back pain"]),
    JSON.stringify(["back", "core", "flexibility"]),
    null
  );

  insert.run(
    uuidv4(),
    "Bird-Dog Exercise",
    "beginner",
    "none",
    JSON.stringify([
      "Start on hands and knees",
      "Extend right arm forward and left leg back, keeping back flat",
      "Hold for 2-3 seconds",
      "Return to starting position",
      "Repeat with left arm and right leg",
      "Do 10 reps per side"
    ]),
    JSON.stringify(["severe back pain"]),
    JSON.stringify(["core", "back", "stability"]),
    null
  );

  insert.run(
    uuidv4(),
    "Glute Bridges",
    "intermediate",
    "none",
    JSON.stringify([
      "Lie on back with knees bent, feet hip-width apart",
      "Press through heels and lift hips toward ceiling",
      "Squeeze glutes at the top",
      "Hold for 2-3 seconds",
      "Lower hips back down",
      "Repeat 12-15 times"
    ]),
    JSON.stringify(["acute back pain"]),
    JSON.stringify(["glutes", "hamstrings", "core"]),
    null
  );

  // Knee Pain Exercises
  insert.run(
    uuidv4(),
    "Seated Knee Extension",
    "beginner",
    "none",
    JSON.stringify([
      "Sit with back against chair, feet flat",
      "Straighten right leg in front of you",
      "Hold at the top for 2-3 seconds",
      "Lower slowly without touching ground",
      "Repeat 12 times, then switch legs"
    ]),
    JSON.stringify(["recent knee surgery", "severe knee pain"]),
    JSON.stringify(["quadriceps"]),
    null
  );

  insert.run(
    uuidv4(),
    "Straight Leg Raise",
    "intermediate",
    "none",
    JSON.stringify([
      "Lie on back, left leg bent with foot on floor",
      "Keep right leg straight and raise to hip height",
      "Hold for 2 seconds",
      "Lower without touching ground",
      "Repeat 12 times, then switch"
    ]),
    JSON.stringify(["knee_pain", "recent knee surgery"]),
    JSON.stringify(["quadriceps", "hip flexors"]),
    null
  );

  insert.run(
    uuidv4(),
    "Quad Sets",
    "beginner",
    "none",
    JSON.stringify([
      "Sit with legs extended or slight knee bend",
      "Tighten thigh muscle above knee",
      "Hold for 5 seconds",
      "Relax",
      "Repeat 15 times per leg"
    ]),
    JSON.stringify(["recent knee surgery"]),
    JSON.stringify(["quadriceps"]),
    null
  );

  // Cardiovascular & General Exercises
  insert.run(
    uuidv4(),
    "Brisk Walking",
    "beginner",
    "none",
    JSON.stringify([
      "Walk at a moderate pace (3-4 mph)",
      "Maintain upright posture",
      "Swing arms naturally",
      "Breathe steadily",
      "Duration: 20-30 minutes"
    ]),
    JSON.stringify(["unstable balance"]),
    JSON.stringify(["legs", "cardiovascular"]),
    null
  );

  insert.run(
    uuidv4(),
    "Stationary Cycling",
    "beginner",
    "bike",
    JSON.stringify([
      "Adjust seat height so knee is slightly bent at bottom",
      "Start with low resistance",
      "Pedal at steady pace (moderate intensity)",
      "Maintain upright posture",
      "Duration: 20-30 minutes"
    ]),
    JSON.stringify([]),
    JSON.stringify(["legs", "cardiovascular", "quadriceps"]),
    null
  );

  insert.run(
    uuidv4(),
    "Swimming",
    "beginner",
    "none",
    JSON.stringify([
      "Use freestyle or backstroke",
      "Focus on form over speed",
      "Maintain steady rhythm",
      "Allow full body engagement",
      "Duration: 20-30 minutes"
    ]),
    JSON.stringify(["open wounds"]),
    JSON.stringify(["full_body", "cardiovascular", "low_impact"]),
    null
  );

  // Strength Training
  insert.run(
    uuidv4(),
    "Push-ups (Modified)",
    "intermediate",
    "none",
    JSON.stringify([
      "Start on knees or against wall",
      "Hands shoulder-width apart",
      "Lower body until chest nearly touches",
      "Push back to starting position",
      "Repeat 8-12 times"
    ]),
    JSON.stringify(["shoulder injury", "wrist injury"]),
    JSON.stringify(["chest", "shoulders", "triceps"]),
    null
  );

  insert.run(
    uuidv4(),
    "Dumbbell Rows",
    "intermediate",
    "dumbbell",
    JSON.stringify([
      "Stand with feet hip-width apart, slight knee bend",
      "Hold dumbbell in right hand",
      "Pull dumbbell toward ribcage",
      "Lower with control",
      "Repeat 12 times per side"
    ]),
    JSON.stringify(["severe back pain", "shoulder injury"]),
    JSON.stringify(["back", "biceps", "core"]),
    null
  );

  // Flexibility & Balance
  insert.run(
    uuidv4(),
    "Hamstring Stretch",
    "beginner",
    "none",
    JSON.stringify([
      "Sit with legs extended",
      "Reach toward toes",
      "Hold stretch for 20-30 seconds",
      "Don't bounce",
      "Repeat 2-3 times"
    ]),
    JSON.stringify([]),
    JSON.stringify(["flexibility", "hamstrings"]),
    null
  );

  insert.run(
    uuidv4(),
    "Standing Balance (Single Leg)",
    "beginner",
    "none",
    JSON.stringify([
      "Stand on one leg",
      "Keep core engaged",
      "Hold for 20-30 seconds",
      "Switch legs",
      "Repeat 3 times per leg"
    ]),
    JSON.stringify(["vertigo", "severe balance issues"]),
    JSON.stringify(["balance", "stabilizers"]),
    null
  );

  // PCOS & Obesity Specific
  insert.run(
    uuidv4(),
    "Burpees (Modified)",
    "intermediate",
    "none",
    JSON.stringify([
      "Stand with feet hip-width apart",
      "Squat down and place hands on ground",
      "Step back into plank",
      "Step feet back to squat",
      "Stand up, repeat 10 times"
    ]),
    JSON.stringify(["joint pain", "cardiac issues"]),
    JSON.stringify(["full_body", "cardiovascular"]),
    null
  );

  insert.run(
    uuidv4(),
    "Jumping Jacks",
    "intermediate",
    "none",
    JSON.stringify([
      "Stand with feet together",
      "Jump while spreading feet and raising arms",
      "Return to starting position",
      "Maintain steady pace",
      "Do 20-30 repetitions"
    ]),
    JSON.stringify(["knee_pain", "joint issues", "balance problems"]),
    JSON.stringify(["full_body", "cardiovascular"]),
    null
  );

  // Diabetes & Hypertension
  insert.run(
    uuidv4(),
    "Yoga Sun Salutation",
    "intermediate",
    "none",
    JSON.stringify([
      "Start in mountain pose",
      "Flow through 12 movements (child's pose, downward dog, etc)",
      "Focus on breathing and form",
      "Repeat sequence 3-5 times",
      "Duration: 15-20 minutes"
    ]),
    JSON.stringify(["severe hypertension (avoid inversions)"]),
    JSON.stringify(["flexibility", "strength", "balance"]),
    null
  );

  console.log("Seeded exercises with progressions and details");
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
    // derive tags if missing
    const tags = new Set(m.tags || []);
    if (m.isVegan) tags.add('vegan');
    if (m.isVegetarian) tags.add('vegetarian');
    if (m.category) tags.add(m.category);
    // simple heuristics for keto-ish meals
    const lowCarb = (m.carbs || 0) < 25;
    if (lowCarb) tags.add('keto');

    insert.run(
      uuidv4(),
      m.title || "Untitled",
      m.calories || 0,
      m.protein || 0,
      m.carbs || 0,
      m.fat || 0,
      JSON.stringify(m.ingredients || []),
      JSON.stringify(m.recipe || {}),
      Array.from(tags).join(",")
    );
  }

  console.log("Seeded meals");
}

function seedExerciseRules() {
  const select = (key) => db.prepare('SELECT id from disease_profiles WHERE keyname = ?').get(key);
  const selEx = (name) => db.prepare('SELECT id FROM exercises WHERE name = ?').get(name);
  const insert = db.prepare(`
    INSERT OR IGNORE INTO exercise_rules
    (id, disease_id, recommended_exercise_ids, avoid_exercise_ids, warnings)
    VALUES (?,?,?,?,?)
  `);
  // selEx and select functions set above

  // lower back pain
  const lb = select('lower_back_pain');
  const lbrId = lb ? lb.id : null;
  if (lbrId) {
    const pelvic = selEx('Pelvic Tilt');
    const catcow = selEx('Cat-Cow');
    const birddog = selEx('Bird-Dog');
    const deadlift = selEx('Deadlift');
    const recs = [pelvic && pelvic.id, catcow && catcow.id, birddog && birddog.id].filter(Boolean);
    const avoids = [deadlift && deadlift.id].filter(Boolean);
    insert.run(uuidv4(), lbrId, JSON.stringify(recs), JSON.stringify(avoids), JSON.stringify({ warning: 'Avoid heavy spinal loading' }));
  }

  // knee pain
  const kp = select('knee_pain');
  if (kp) {
    const kneeExt = selEx('Seated Knee Extension');
    const deepSquat = selEx('Deep Squat');
    const walk = selEx('Walking');
    const recs = [kneeExt && kneeExt.id, walk && walk.id].filter(Boolean);
    const avoids = [deepSquat && deepSquat.id].filter(Boolean);
    insert.run(uuidv4(), kp.id, JSON.stringify(recs), JSON.stringify(avoids), JSON.stringify({ warning: 'Avoid deep, loaded squats' }));
  }

  // diabetes
  const d = select('diabetes_type2');
  if (d) {
    const walk = selEx('Walking');
    const recs = [walk && walk.id].filter(Boolean);
    insert.run(uuidv4(), d.id, JSON.stringify(recs), JSON.stringify([]), JSON.stringify({ warning: 'Prefer aerobic activities and light resistance' }));
  }

  console.log('Seeded exercise rules (placeholder)');
}

function seedDietRules() {
  const select = (key) => db.prepare('SELECT id from disease_profiles WHERE keyname = ?').get(key);
  const insert = db.prepare(`
    INSERT OR IGNORE INTO disease_diet_rules
    (id, disease_id, avoid_foods, recommended_foods, constraints, macros_json)
    VALUES (?,?,?,?,?,?)
  `);

  // Type 2 Diabetes
  const diabetes = select('diabetes_type2');
  if (diabetes) {
    insert.run(uuidv4(), diabetes.id,
      JSON.stringify([
        'refined sugar', 'soda', 'white bread', 'pastries', 'candy',
        'fruit juices', 'sweetened cereals', 'chocolate bars', 'cookies',
        'white rice', 'instant noodles', 'desserts'
      ]),
      JSON.stringify([
        'oats', 'brown rice', 'quinoa', 'lentils', 'chickpeas',
        'leafy greens', 'broccoli', 'spinach', 'berries', 'apples',
        'fish', 'chicken breast', 'tofu', 'nuts', 'seeds', 'olive oil'
      ]),
      JSON.stringify({
        max_daily_sugar_g: 25,
        min_fiber_g: 30,
        meal_frequency: '3 main + 2 snacks',
        portion_control: 'important'
      }),
      JSON.stringify({
        protein_pct: [20, 30],
        carbs_pct: [35, 45],
        fat_pct: [25, 35],
        gi_max: 'medium',
        specific_carbs: 'complex carbs only'
      })
    );
  }

  // Hypertension
  const hypertension = select('hypertension');
  if (hypertension) {
    insert.run(uuidv4(), hypertension.id,
      JSON.stringify([
        'salt', 'processed foods', 'canned soups', 'pickles', 'papad',
        'cured meats', 'bacon', 'sausages', 'cheese', 'butter',
        'fried foods', 'frozen meals', 'salty snacks', 'fast food',
        'high-sodium broths'
      ]),
      JSON.stringify([
        'potassium-rich fruits (banana, orange, avocado)', 'leafy greens',
        'low-fat dairy', 'whole grains', 'fish (salmon, mackerel)',
        'beans', 'nuts (unsalted)', 'garlic', 'onions', 'herbs & spices',
        'vegetables (broccoli, carrot, sweet potato)', 'berries'
      ]),
      JSON.stringify({
        sodium_limit_mg: 2300,
        potassium_target_mg: 3500,
        meal_frequency: '3-4 smaller meals',
        cooking_method: 'boil, grill, bake - avoid frying'
      }),
      JSON.stringify({
        protein_pct: [20, 30],
        carbs_pct: [40, 50],
        fat_pct: [20, 30],
        sodium_restriction: 'critical',
        dash_diet: 'recommended'
      })
    );
  }

  // Lower Back Pain
  const lbp = select('lower_back_pain');
  if (lbp) {
    insert.run(uuidv4(), lbp.id,
      JSON.stringify([
        'excessive caffeine', 'alcohol', 'spicy foods (may increase inflammation)',
        'processed meats', 'refined grains', 'sugary drinks', 'trans fats'
      ]),
      JSON.stringify([
        'fatty fish (salmon, sardines - omega-3s)', 'turmeric', 'ginger',
        'leafy greens', 'berries', 'nuts', 'seeds', 'whole grains',
        'fruits high in vitamin C (orange, kiwi)', 'low-fat dairy',
        'magnesium-rich foods (pumpkin seeds, spinach)'
      ]),
      JSON.stringify({
        focus: 'anti-inflammatory diet',
        hydration: 'minimum 8 glasses water/day',
        meal_frequency: '3-4 meals',
        nutrient_focus: 'Omega-3s, magnesium, calcium'
      }),
      JSON.stringify({
        protein_pct: [20, 30],
        carbs_pct: [40, 50],
        fat_pct: [25, 35],
        omega3_emphasis: 'high',
        anti_inflammatory: 'critical'
      })
    );
  }

  // Knee Pain
  const kneePain = select('knee_pain');
  if (kneePain) {
    insert.run(uuidv4(), kneePain.id,
      JSON.stringify([
        'fried foods', 'processed snacks', 'sugary drinks', 'refined grains',
        'excessive salt', 'trans fats', 'alcohol', 'caffeine excess'
      ]),
      JSON.stringify([
        'anti-inflammatory foods (fatty fish, turmeric)', 'citrus fruits',
        'berries', 'leafy greens', 'bell peppers', 'broccoli', 'garlic',
        'ginger', 'green tea', 'olive oil', 'nuts', 'seeds', 'low-fat dairy',
        'foods rich in glucosamine (bone broth, eggs)'
      ]),
      JSON.stringify({
        focus: 'anti-inflammatory, joint health',
        weight_management: 'reduce load on knee',
        hydration: 'at least 8 glasses/day',
        nutrient_focus: 'Vitamin C, anthocyanins, glucosamine'
      }),
      JSON.stringify({
        protein_pct: [25, 35],
        carbs_pct: [35, 45],
        fat_pct: [25, 35],
        anti_inflammatory: 'critical',
        joint_support: 'high priority'
      })
    );
  }

  // PCOS
  const pcos = select('pcos');
  if (pcos) {
    insert.run(uuidv4(), pcos.id,
      JSON.stringify([
        'refined carbohydrates', 'sugary foods', 'processed meals',
        'trans fats', 'high-fat dairy', 'red meat excess', 'fried foods',
        'refined grains', 'sweetened beverages', 'candy', 'pastries'
      ]),
      JSON.stringify([
        'lean proteins (chicken, fish, tofu)', 'eggs', 'beans', 'lentils',
        'complex carbs (oats, brown rice, sweet potato)', 'leafy greens',
        'berries', 'nuts', 'seeds', 'avocado', 'olive oil', 'low-fat yogurt',
        'vegetables (broccoli, bell peppers)', 'whole grain bread'
      ]),
      JSON.stringify({
        focus: 'low GI, high protein, insulin sensitivity',
        carb_quality: 'complex carbs only',
        meal_frequency: '3-4 meals + snacks',
        protein_per_meal: '25-30g',
        blood_sugar_stable: 'important'
      }),
      JSON.stringify({
        protein_pct: [30, 40],
        carbs_pct: [35, 40],
        fat_pct: [25, 35],
        gi_max: 'low to medium',
        fiber_min_g: 25,
        insulin_sensitivity: 'focus'
      })
    );
  }

  // Thyroid Disorder
  const thyroid = select('thyroid');
  if (thyroid) {
    insert.run(uuidv4(), thyroid.id,
      JSON.stringify([
        'goitrogenic foods (raw broccoli, cabbage, kale - cook to reduce)',
        'excess iodine', 'processed foods', 'trans fats', 'excess caffeine',
        'alcohol', 'soy (if hypothyroid - in large amounts)', 'refined grains'
      ]),
      JSON.stringify([
        'selenium-rich foods (Brazil nuts, fish, chicken)', 'iodized salt (moderate)',
        'zinc-rich foods (oysters, beef, chickpeas)', 'iron-rich foods (spinach, lentils)',
        'fish (mackerel, sardines)', 'whole grains', 'vegetables (cooked preferred)',
        'lean proteins', 'eggs', 'dairy', 'fruit', 'olive oil'
      ]),
      JSON.stringify({
        focus: 'selenium, zinc, iron support',
        timing: 'medications 4+ hours apart from supplements',
        cooking: 'cook cruciferous vegetables',
        meal_frequency: '3 meals daily',
        supplement_interaction: 'critical'
      }),
      JSON.stringify({
        protein_pct: [20, 30],
        carbs_pct: [40, 50],
        fat_pct: [25, 35],
        selenium_critical: true,
        zinc_important: true,
        iron_moderate: true
      })
    );
  }

  // Obesity
  const obesity = select('obesity');
  if (obesity) {
    insert.run(uuidv4(), obesity.id,
      JSON.stringify([
        'sugary drinks', 'fried foods', 'processed snacks', 'candy', 'desserts',
        'high-calorie sauces', 'fatty meats', 'full-fat dairy', 'fast food',
        'alcohol', 'high-calorie coffee drinks', 'pastries', 'chips'
      ]),
      JSON.stringify([
        'lean proteins (chicken, fish, turkey)', 'eggs', 'legumes', 'vegetables',
        'fruits (especially low-sugar)', 'whole grains', 'low-fat dairy',
        'nuts (small portions)', 'olive oil', 'herbs & spices', 'green tea',
        'water', 'plain yogurt', 'lean beef (occasional)'
      ]),
      JSON.stringify({
        focus: 'calorie deficit 500-750 kcal/day',
        portion_control: 'critical',
        meal_frequency: '3-4 meals + controlled snacks',
        water_intake: 'at least 10 glasses/day',
        mindful_eating: 'important',
        progression: 'gradual calorie reduction'
      }),
      JSON.stringify({
        protein_pct: [25, 35],
        carbs_pct: [40, 50],
        fat_pct: [20, 30],
        calorie_deficit: 'essential',
        high_satiety_foods: 'prioritize',
        processed_foods: 'minimize'
      })
    );
  }

  console.log('Seeded comprehensive diet rules');
}

function seedTestUser() {
  const email = 'test@example.com';
  const existing = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
  let id;
  const now = Math.floor(Date.now() / 1000);

  if (existing && existing.id) {
    id = existing.id;
  } else {
    id = uuidv4();
    const hash = bcrypt.hashSync('test123', 10);
    db.prepare(`
      INSERT INTO users (id, email, password_hash, created_at) VALUES (?,?,?,?)
    `).run(id, email, hash, now);
  }

  // Insert or update profile for the user id
  const profileExists = db.prepare('SELECT user_id FROM user_profiles WHERE user_id = ?').get(id);
  if (!profileExists) {
    db.prepare(`
      INSERT INTO user_profiles (user_id, name) VALUES (?,?)
    `).run(id, 'Test User');
  } else {
    db.prepare(`
      UPDATE user_profiles SET name = ? WHERE user_id = ?
    `).run('Test User', id);
  }

  console.log(`Created/ensured test user: ${email} / test123 (id=${id})`);
}

(function run() {
  seedDiseaseProfiles();
  seedMoreDiseaseProfiles();
  seedExercises();
  seedMeals();
  seedExerciseRules();
  seedDietRules();
  seedTestUser();
  console.log("Seeding complete.");
})();
