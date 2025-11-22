const db = require('../db/database');

function getDiseaseByKey(key) {
  return db.prepare('SELECT * FROM disease_profiles WHERE keyname = ?').get(key);
}

function formatDiseaseWithDietRules(disease) {
  if (!disease) return null;
  
  const dietRules = db.prepare(`
    SELECT * FROM disease_diet_rules WHERE disease_id = ? ORDER BY rowid DESC LIMIT 1
  `).get(disease.id);

  return {
    ...disease,
    diet: dietRules ? {
      avoid_foods: JSON.parse(dietRules.avoid_foods || '[]'),
      recommended_foods: JSON.parse(dietRules.recommended_foods || '[]'),
      constraints: JSON.parse(dietRules.constraints || '{}'),
      macros: JSON.parse(dietRules.macros_json || '{}')
    } : null
  };
}

function getAllDiseases() {
  const diseases = db.prepare('SELECT * FROM disease_profiles ORDER BY title').all();
  return diseases.map(formatDiseaseWithDietRules);
}

function getDiseaseById(id) {
  const disease = db.prepare('SELECT * FROM disease_profiles WHERE id = ?').get(id);
  return formatDiseaseWithDietRules(disease);
}

function getDiseaseWithDietByKey(key) {
  const disease = getDiseaseByKey(key);
  return formatDiseaseWithDietRules(disease);
}

function searchDiseases(query) {
  const diseases = db.prepare(`
    SELECT * FROM disease_profiles 
    WHERE title LIKE ? OR description LIKE ?
    ORDER BY title
  `).all(`%${query}%`, `%${query}%`);
  
  return diseases.map(formatDiseaseWithDietRules);
}

function getExerciseRuleByDiseaseId(diseaseId) {
  return db.prepare('SELECT * FROM exercise_rules WHERE disease_id = ?').get(diseaseId);
}

function fetchExercisesByIds(ids) {
  if (!Array.isArray(ids) || ids.length === 0) return [];
  ids = ids.filter(Boolean);
  const placeholders = ids.map(() => '?').join(',');
  const rows = db.prepare(`SELECT * FROM exercises WHERE id IN (${placeholders})`).all(...ids);
  return rows.map(r => ({
    id: r.id,
    name: r.name,
    difficulty: r.difficulty,
    equipment: r.equipment,
    steps: r.steps_json ? JSON.parse(r.steps_json) : [],
    contraindications: r.contraindications_json ? JSON.parse(r.contraindications_json) : [],
    muscles: r.muscles_json ? JSON.parse(r.muscles_json) : [],
    demo_video_url: r.demo_video_url || null
  }));
}

function getExercisesForDiseaseKey(key) {
  const disease = getDiseaseByKey(key);
  if (!disease) return null;

  const rule = getExerciseRuleByDiseaseId(disease.id) || {};
  const recIds = rule.recommended_exercise_ids ? JSON.parse(rule.recommended_exercise_ids) : [];
  const avoidIds = rule.avoid_exercise_ids ? JSON.parse(rule.avoid_exercise_ids) : [];

  const recommendedExercises = fetchExercisesByIds(recIds);
  const avoidExercises = fetchExercisesByIds(avoidIds);

  const warnings = rule.warnings ? JSON.parse(rule.warnings) : {};

  return {
    disease: {
      id: disease.id,
      keyname: disease.keyname,
      title: disease.title,
      description: disease.description
    },
    recommendedExercises,
    avoidExercises,
    warnings
  };
}

module.exports = {
  getExercisesForDiseaseKey,
  getAllDiseases,
  getDiseaseById,
  getDiseaseWithDietByKey,
  searchDiseases
};
