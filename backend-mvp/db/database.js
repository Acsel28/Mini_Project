const Database = require('better-sqlite3');
const fs = require('fs');
const path = require('path');

const DB_FILE = process.env.DATABASE_FILE || path.join(__dirname, 'data.sqlite');
const dbExists = fs.existsSync(DB_FILE);
const db = new Database(DB_FILE);

// initialize schema if not exists
if (!dbExists) {
  const initSql = fs.readFileSync(path.join(__dirname, 'init.sql'), 'utf8');
  db.exec(initSql);
}

module.exports = db;
