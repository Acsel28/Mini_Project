// backend-mvp/scripts/reset-db.js
const path = require('path');
const Database = require('better-sqlite3');

// path to backend-mvp/db/data.sqlite
const dbPath = path.join(__dirname, '..', 'db', 'data.sqlite');
const db = new Database(dbPath);

console.log('Using DB at:', dbPath);

db.exec(`
PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS user_profiles;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL
);

CREATE TABLE user_profiles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  age INTEGER,
  gender TEXT,
  height_cm REAL,
  weight_kg REAL,
  language TEXT,
  disease_profile_id TEXT,
  target_calories INTEGER,
  accessibility_flags TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

PRAGMA foreign_keys = ON;
`);

console.log('DB reset done.');
