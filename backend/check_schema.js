const Database = require('better-sqlite3');
const db = new Database('./db/data.sqlite');

console.log('Checking user_profiles table schema...\n');

const cols = db.prepare("PRAGMA table_info('user_profiles')").all();

cols.forEach(col => {
  console.log(`${col.name.padEnd(25)} | ${col.type.padEnd(10)} | nullable: ${col.notnull === 0}`);
});

console.log('\n✅ Schema check complete');

// Try a sample insert
try {
  console.log('\nAttempting to insert a test user with all fields...');
  db.prepare(`
    INSERT INTO users (id, email, password_hash, created_at)
    VALUES (?, ?, ?, ?)
  `).run('test-id-123', 'schematest@test.com', 'hash', Math.floor(Date.now() / 1000));

  db.prepare(`
    INSERT INTO user_profiles (
      user_id, name, age, gender, height_cm, weight_kg,
      diet_preference, meal_type, allergies, fitness_goal, activity_level, target_calories
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    'test-id-123',
    'Test User',
    30,
    'male',
    180,
    75,
    'vegetarian',
    'high_protein',
    'peanuts',
    'weight_loss',
    'moderately_active',
    2200
  );

  console.log('✅ Insert successful! Database columns are working correctly');

  // Query it back
  const result = db.prepare(`
    SELECT * FROM user_profiles WHERE user_id = ?
  `).get('test-id-123');

  console.log('\nInserted user profile:');
  console.log(JSON.stringify(result, null, 2));

  // Clean up
  db.prepare('DELETE FROM users WHERE id = ?').run('test-id-123');
  
} catch (e) {
  console.error('❌ Insert failed:', e.message);
}

db.close();
