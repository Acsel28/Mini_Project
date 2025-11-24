const { v4: uuidv4 } = require('uuid');
const db = require('../db/database');
const { getAllDiseases, getDiseaseWithDietByKey, getExercisesForDiseaseKey, searchDiseases } = require('./disease_service');

function gatherDiseaseFactCards(query, limit = 2) {
  const normalized = (query || '').trim();
  let matches = normalized ? searchDiseases(normalized) : getAllDiseases();
  if (!Array.isArray(matches) || matches.length === 0) {
    matches = getAllDiseases();
  }

  return matches
    .slice(0, limit)
    .map((disease) => {
      const exerciseData = getExercisesForDiseaseKey(disease.keyname) || {};
      return {
        key: disease.keyname,
        title: disease.title,
        description: disease.description,
        diet_recommended: disease.diet?.recommended_foods || [],
        diet_avoid: disease.diet?.avoid_foods || [],
        diet_focus: disease.diet?.constraints?.focus || '',
        notes: disease.diet?.constraints?.notes || '',
        macros: disease.diet?.macros || {},
        exercises: {
          recommended: exerciseData.recommendedExercises || [],
          avoid: exerciseData.avoidExercises || [],
          warnings: exerciseData.warnings || {},
        },
      };
    });
}

function getDiseaseSearchHistory(userId, limit = 5) {
  if (!userId) return [];
  return db
    .prepare(
      `SELECT * FROM disease_search_history
       WHERE user_id = ?
       ORDER BY created_at DESC
       LIMIT ?`
    )
    .all(userId, limit);
}

function historyToPromptTurns(historyRows = []) {
  if (!Array.isArray(historyRows)) return [];
  return [...historyRows]
    .sort((a, b) => a.created_at - b.created_at)
    .flatMap((row) => {
      const turns = [];
      if (row.query) {
        turns.push({ role: 'user', content: row.query });
      }
      if (row.answer_json) {
        turns.push({ role: 'assistant', content: row.answer_json });
      }
      return turns;
    });
}

function saveDiseaseSearchHistory({
  userId,
  query,
  answer,
  referencedKeys = [],
  language,
  promptSnapshot,
  responseSnapshot,
}) {
  if (!userId || !query) return;
  const id = uuidv4();
  const payload = {
    id,
    user_id: userId,
    query,
    answer_json: JSON.stringify(answer || {}),
    referenced_keys: JSON.stringify(referencedKeys),
    language,
    prompt_snapshot: promptSnapshot || null,
    response_snapshot: responseSnapshot || null,
    created_at: Date.now(),
  };

  db.prepare(
    `INSERT INTO disease_search_history
      (id, user_id, query, answer_json, referenced_keys, language, prompt_snapshot, response_snapshot, created_at)
     VALUES (:id, :user_id, :query, :answer_json, :referenced_keys, :language, :prompt_snapshot, :response_snapshot, :created_at)`
  ).run(payload);
}

function getRecentDiseaseAnswer(userId, query, ttlMs = 0) {
  if (!userId || !query) return null;
  const row = db
    .prepare(
      `SELECT * FROM disease_search_history
       WHERE user_id = ? AND query = ?
       ORDER BY created_at DESC
       LIMIT 1`
    )
    .get(userId, query);

  if (!row) return null;
  if (ttlMs && Date.now() - row.created_at > ttlMs) {
    return null;
  }

  let answer;
  try {
    answer = row.answer_json ? JSON.parse(row.answer_json) : null;
  } catch (err) {
    answer = null;
  }

  return {
    ...row,
    answer,
  };
}

module.exports = {
  gatherDiseaseFactCards,
  getDiseaseSearchHistory,
  historyToPromptTurns,
  saveDiseaseSearchHistory,
  getRecentDiseaseAnswer,
};
