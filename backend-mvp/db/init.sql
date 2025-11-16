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
  FOREIGN KEY(user_id) REFERENCES users(id)
);

-- refresh tokens (store hashed token)
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
  rules_json TEXT -- json string for macros, forbidden ingredients, contraindications
);

-- meals, recipes
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
  muscles_json TEXT
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
