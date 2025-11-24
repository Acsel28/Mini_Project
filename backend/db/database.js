const Database = require('better-sqlite3');
const fs = require('fs');
const path = require('path');

const DB_FILE = process.env.DATABASE_FILE || path.join(__dirname, 'data.sqlite');
const dbExists = fs.existsSync(DB_FILE);

const db = new Database(DB_FILE);

// initialize schema if database file did not exist
if (!dbExists) {
  const initSql = fs.readFileSync(path.join(__dirname, 'init.sql'), 'utf8');
  db.exec(initSql);
  console.log('Initialized new SQLite database at', DB_FILE);
}

// If DB file exists, ensure schema upgrades are applied for new columns/tables
try {
  // Add demo_video_url to exercises if missing
  const cols = db.prepare("PRAGMA table_info('exercises')").all();
  const hasDemo = cols.some(c => c.name === 'demo_video_url');
  if (!hasDemo) {
    db.exec("ALTER TABLE exercises ADD COLUMN demo_video_url TEXT;");
    console.log('Added demo_video_url column to exercises');
  }

  // Check and add missing personalization columns to user_profiles
  const userProfileCols = db.prepare("PRAGMA table_info('user_profiles')").all();
  const colNames = userProfileCols.map(c => c.name);
  
  if (!colNames.includes('diet_preference')) {
    db.exec("ALTER TABLE user_profiles ADD COLUMN diet_preference TEXT;");
    console.log('Added diet_preference column to user_profiles');
  }
  if (!colNames.includes('meal_type')) {
    db.exec("ALTER TABLE user_profiles ADD COLUMN meal_type TEXT;");
    console.log('Added meal_type column to user_profiles');
  }
  if (!colNames.includes('allergies')) {
    db.exec("ALTER TABLE user_profiles ADD COLUMN allergies TEXT;");
    console.log('Added allergies column to user_profiles');
  }
  if (!colNames.includes('fitness_goal')) {
    db.exec("ALTER TABLE user_profiles ADD COLUMN fitness_goal TEXT;");
    console.log('Added fitness_goal column to user_profiles');
  }
  if (!colNames.includes('activity_level')) {
    db.exec("ALTER TABLE user_profiles ADD COLUMN activity_level TEXT DEFAULT 'moderately_active';");
    console.log('Added activity_level column to user_profiles');
  }

  // Ensure exercise_rules table exists when upgrading older DB
  db.exec(`CREATE TABLE IF NOT EXISTS exercise_rules (
    id TEXT PRIMARY KEY,
    disease_id TEXT NOT NULL,
    recommended_exercise_ids TEXT,
    avoid_exercise_ids TEXT,
    warnings TEXT,
    FOREIGN KEY(disease_id) REFERENCES disease_profiles(id)
  );`);

  // Ensure disease_diet_rules table exists when upgrading older DB
      // Ensure hydration_logs table exists
      db.exec(`CREATE TABLE IF NOT EXISTS hydration_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount_ml INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT,
        created_at INTEGER,
        FOREIGN KEY(user_id) REFERENCES users(id)
      );`);

      // Ensure sleep_logs table exists
      db.exec(`CREATE TABLE IF NOT EXISTS sleep_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        hours REAL NOT NULL,
        date TEXT NOT NULL,
        quality TEXT,
        created_at INTEGER,
        FOREIGN KEY(user_id) REFERENCES users(id)
      );`);
  db.exec(`CREATE TABLE IF NOT EXISTS disease_diet_rules (
    id TEXT PRIMARY KEY,
    disease_id TEXT NOT NULL,
    avoid_foods TEXT,
    recommended_foods TEXT,
    constraints TEXT,
    macros_json TEXT,
    FOREIGN KEY(disease_id) REFERENCES disease_profiles(id)
  );`);

  db.exec(`CREATE TABLE IF NOT EXISTS disease_search_history (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    query TEXT NOT NULL,
    answer_json TEXT,
    referenced_keys TEXT,
    language TEXT,
    prompt_snapshot TEXT,
    response_snapshot TEXT,
    created_at INTEGER NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(id)
  );`);

  db.exec(`CREATE TABLE IF NOT EXISTS coach_conversation_history (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    question TEXT NOT NULL,
    answer TEXT,
    language TEXT,
    metadata TEXT,
    created_at INTEGER NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(id)
  );`);
} catch (e) {
  console.warn('Schema upgrade check failed:', e.message);
}

module.exports = db;
