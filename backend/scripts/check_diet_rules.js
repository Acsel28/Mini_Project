const db = require('../db/database');

// Check all diseases
const diseases = db.prepare(`
  SELECT id, keyname, title FROM disease_profiles WHERE keyname IN ('hypertension', 'diabetes_type2')
`).all();

console.log('\n=== Disease Profiles ===');
diseases.forEach(d => {
  console.log(`${d.keyname}: ${d.title} (id: ${d.id})`);
});

// Check diet rules
const dietRules = db.prepare(`
  SELECT d.keyname, d.title, dr.id, dr.avoid_foods, dr.constraints, dr.macros_json
  FROM disease_diet_rules dr
  JOIN disease_profiles d ON dr.disease_id = d.id
  WHERE d.keyname IN ('hypertension', 'diabetes_type2')
`).all();

console.log('\n=== Diet Rules ===');
dietRules.forEach(dr => {
  console.log(`\n${dr.keyname}:`);
  console.log('  Constraints:', JSON.parse(dr.constraints || '{}'));
  const avoidFoods = JSON.parse(dr.avoid_foods || '[]');
  console.log('  Avoid foods (first 3):', avoidFoods.slice(0, 3));
});
