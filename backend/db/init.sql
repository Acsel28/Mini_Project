-- users + profile
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS user_profiles (
  user_id TEXT PRIMARY KEY,
  name TEXT,
  age INTEGER,
  gender TEXT,
  height_cm REAL,
  weight_kg REAL,
  language TEXT DEFAULT 'en',
  target_calories INTEGER,
  bmr REAL,
  accessibility_flags TEXT,
  disease_profile_id TEXT,

  -- Diet & Nutrition
  diet_preference TEXT,
  meal_type TEXT,
  allergies TEXT,

  -- Fitness & Activity
  fitness_goal TEXT,
  activity_level TEXT DEFAULT 'moderately_active',

  -- UI fields
  goal TEXT DEFAULT 'healthy_eating',
  accessibilityMode INTEGER DEFAULT 0,
  healthConditions TEXT DEFAULT '[]',

  FOREIGN KEY(user_id) REFERENCES users(id)
);


-- refresh tokens
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  token_hash TEXT NOT NULL,
  expires_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY(user_id) REFERENCES users(id)
);

-- disease profiles
CREATE TABLE IF NOT EXISTS disease_profiles (
  id TEXT PRIMARY KEY,
  keyname TEXT UNIQUE,
  title TEXT,
  description TEXT,
  rules_json TEXT
);

-- exercise rules - map disease to recommended/avoid exercises
CREATE TABLE IF NOT EXISTS exercise_rules (
  id TEXT PRIMARY KEY,
  disease_id TEXT NOT NULL,
  recommended_exercise_ids TEXT,
  avoid_exercise_ids TEXT,
  warnings TEXT,
  FOREIGN KEY(disease_id) REFERENCES disease_profiles(id)
);

-- meals
CREATE TABLE IF NOT EXISTS meals (
  id TEXT PRIMARY KEY,
  title TEXT,
  calories INTEGER,
  protein INTEGER,
  carbs INTEGER,
  fat INTEGER,
  ingredients_json TEXT,
  recipe_json TEXT,
  tags TEXT
);

CREATE TABLE IF NOT EXISTS meal_plans (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  date TEXT,
  meals_json TEXT,
  total_calories INTEGER,
  meta_json TEXT,
  FOREIGN KEY(user_id) REFERENCES users(id)
);

-- exercises
CREATE TABLE IF NOT EXISTS exercises (
  id TEXT PRIMARY KEY,
  name TEXT,
  difficulty TEXT,
  equipment TEXT,
  steps_json TEXT,
  contraindications_json TEXT,
  muscles_json TEXT,
  demo_video_url TEXT
);

CREATE TABLE IF NOT EXISTS exercise_logs (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  exercise_id TEXT,
  reps INTEGER,
  duration_sec INTEGER,
  date TEXT,
  FOREIGN KEY(user_id) REFERENCES users(id)
);

-- uploads
CREATE TABLE IF NOT EXISTS uploads (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  path TEXT,
  type TEXT,
  created_at INTEGER
);

-- disease diet rules - maps diseases to food preferences & macros
CREATE TABLE IF NOT EXISTS disease_diet_rules (
  id TEXT PRIMARY KEY,
  disease_id TEXT NOT NULL,
  avoid_foods TEXT,
  recommended_foods TEXT,
  constraints TEXT,
  macros_json TEXT,
  FOREIGN KEY(disease_id) REFERENCES disease_profiles(id)
);

-- Health tracking tables
CREATE TABLE IF NOT EXISTS hydration_logs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  amount_ml INTEGER NOT NULL,
  date TEXT NOT NULL,
  time TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS sleep_logs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  hours REAL NOT NULL,
  date TEXT NOT NULL,
  quality TEXT DEFAULT 'good',
  created_at INTEGER NOT NULL,
  FOREIGN KEY(user_id) REFERENCES users(id)
);
