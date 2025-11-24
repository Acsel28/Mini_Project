const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth_mw');
const { chatCompletion } = require('../services/llm_client');
const {
  INDIA_CULTURE_GUARDRAILS,
  isHindiLanguage,
  languageDirective,
  normalizeHistory,
  buildUserContext,
} = require('../services/ai_prompt_utils');
const { fetchUserProfile } = require('../services/user_profile_service');
const {
  gatherDiseaseFactCards,
  getDiseaseSearchHistory,
  historyToPromptTurns,
  saveDiseaseSearchHistory,
  getRecentDiseaseAnswer,
} = require('../services/disease_ai_service');
const { getExercisesForDiseaseKey, getDiseaseWithDietByKey, getAllDiseases, searchDiseases } = require('../services/disease_service');
const db = require('../db/database');
const { parseJsonResponse } = require('../services/llm_response_utils');

// GET /api/disease/  -> list diseases
router.get('/', (req, res) => {
  try {
    const search = req.query.search;
    let rows;
    if (search) {
      rows = searchDiseases(search);
    } else {
      rows = getAllDiseases();
    }
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/disease/:key/exercises
router.get('/:key/exercises', (req, res) => {
  const key = req.params.key;
  try {
    const data = getExercisesForDiseaseKey(key);
    if (!data) return res.status(404).json({ error: 'Disease not found' });
    res.json(data);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/disease/:key/diet
router.get('/:key/diet', (req, res) => {
  const key = req.params.key;
  try {
    const data = getDiseaseWithDietByKey(key);
    if (!data) return res.status(404).json({ error: 'Disease not found' });
    
    // Return diet-specific data
    res.json({
      id: data.id,
      keyname: data.keyname,
      title: data.title,
      description: data.description,
      diet: data.diet
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/disease/:key/detailed - Comprehensive disease info with exercises AND diet
router.get('/:key/detailed', (req, res) => {
  const key = req.params.key;
  try {
    const diseaseWithDiet = getDiseaseWithDietByKey(key);
    if (!diseaseWithDiet) return res.status(404).json({ error: 'Disease not found' });
    
    const exerciseData = getExercisesForDiseaseKey(key);
    
    res.json({
      id: diseaseWithDiet.id,
      keyname: diseaseWithDiet.keyname,
      title: diseaseWithDiet.title,
      description: diseaseWithDiet.description,
      rules_json: diseaseWithDiet.rules_json,
      diet: diseaseWithDiet.diet,
      exercises: exerciseData ? {
        recommended: exerciseData.recommendedExercises,
        avoid: exerciseData.avoidExercises,
        warnings: exerciseData.warnings
      } : null,
      recommendations: {
        diet_focus: diseaseWithDiet.diet?.constraints?.focus || 'Balanced nutrition',
        exercise_focus: diseaseWithDiet.rules_json ? (JSON.parse(diseaseWithDiet.rules_json).exercise_focus || []) : [],
        lifestyle_notes: diseaseWithDiet.rules_json ? (JSON.parse(diseaseWithDiet.rules_json).notes || '') : ''
      }
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/disease/:key/full-profile - Complete patient education profile
router.get('/:key/full-profile', (req, res) => {
  const key = req.params.key;
  try {
    const diseaseWithDiet = getDiseaseWithDietByKey(key);
    if (!diseaseWithDiet) return res.status(404).json({ error: 'Disease not found' });
    
    const exerciseData = getExercisesForDiseaseKey(key);
    
    // Build comprehensive patient education profile
    const profile = {
      disease: {
        id: diseaseWithDiet.id,
        keyname: diseaseWithDiet.keyname,
        title: diseaseWithDiet.title,
        description: diseaseWithDiet.description
      },
      diet: diseaseWithDiet.diet ? {
        avoidFoods: diseaseWithDiet.diet.avoid_foods,
        recommendedFoods: diseaseWithDiet.diet.recommended_foods,
        mealGuidance: diseaseWithDiet.diet.constraints,
        nutritionTargets: diseaseWithDiet.diet.macros,
        summary: buildDietSummary(diseaseWithDiet.diet)
      } : null,
      exercise: exerciseData ? {
        recommendedExercises: exerciseData.recommendedExercises,
        exercisesToAvoid: exerciseData.avoidExercises,
        warnings: exerciseData.warnings,
        summary: buildExerciseSummary(exerciseData)
      } : null,
      lifestyle: {
        tips: buildLifestyleTips(diseaseWithDiet),
        monitoring: buildMonitoringGuidelines(diseaseWithDiet),
        resources: buildResources(diseaseWithDiet)
      }
    };
    
    res.json(profile);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

function ensureStringArray(value) {
  if (!Array.isArray(value)) return [];
  return value
    .map((item) => (typeof item === 'string' ? item.trim() : ''))
    .filter(Boolean);
}

function parseInsightAnswer(rawText) {
  if (!rawText) return null;
  try {
    const parsed = parseJsonResponse(rawText);
    const conditionSummary = parsed.condition_summary || parsed.summary || '';
    if (!conditionSummary) return null;

    return {
      condition_summary: conditionSummary,
      diet_guidance: ensureStringArray(parsed.diet_guidance || parsed.diet || []),
      exercise_plan: ensureStringArray(parsed.exercise_plan || parsed.exercise || []),
      lifestyle_hooks: ensureStringArray(parsed.lifestyle_hooks || parsed.lifestyle || []),
      reminders: ensureStringArray(parsed.reminders || parsed.actions || []),
      references: ensureStringArray(parsed.references || []),
      risk_flags: ensureStringArray(parsed.risk_flags || []),
    };
  } catch (err) {
    console.warn('[Disease Insights] JSON parse failed:', err);
    return null;
  }
}

function buildFallbackFromFacts(facts, language) {
  if (!Array.isArray(facts) || facts.length === 0) {
    return {
      condition_summary: isHindiLanguage(language)
        ? 'हमें अभी डेटाबेस से जानकारी नहीं मिली। कृपया डॉक्टर से सलाह लें।'
        : 'We could not find a confident match in the clinical library. Please consult a medical professional.',
      diet_guidance: [],
      exercise_plan: [],
      lifestyle_hooks: [],
      reminders: [],
      references: [],
      risk_flags: [],
    };
  }

  const primary = facts[0];
  const summary = isHindiLanguage(language)
    ? `${primary.title} के लिए संरचित सलाह हमारे डेटाबेस से ली गई है।`
    : `Curated guidance for ${primary.title} sourced from the verified database.`;

  return {
    condition_summary: summary,
    diet_guidance: primary.diet_recommended || [],
    exercise_plan: (primary.exercises?.recommended || []).map((ex) => `${ex.name} · ${ex.difficulty || 'easy'}`),
    lifestyle_hooks: primary.notes ? [primary.notes] : [],
    reminders: primary.diet_focus ? [primary.diet_focus] : [],
    references: primary.key ? [`db:${primary.key}`] : [],
    risk_flags: primary.exercises?.warnings ? Object.values(primary.exercises.warnings) : [],
  };
}

// POST /api/disease/insights - LLM-tailored condition plan
router.post('/insights', authMiddleware, async (req, res) => {
  const userId = req.user.sub;
  const { query, history = [], language } = req.body || {};

  if (!query || typeof query !== 'string' || !query.trim()) {
    return res.status(400).json({ error: 'Query is required' });
  }

  try {
    const userProfile = fetchUserProfile(userId);
    const resolvedLanguage = (language || userProfile?.language || 'english').toString();
    const cachedAnswer = getRecentDiseaseAnswer(userId, query.trim(), 20 * 60 * 1000);
    if (cachedAnswer?.answer) {
      return res.json({
        query: query.trim(),
        language: resolvedLanguage,
        answer: cachedAnswer.answer,
        facts: gatherDiseaseFactCards(query.trim(), 1),
        source: 'cache',
        memoryTrail: getDiseaseSearchHistory(userId, 2).map((row) => ({ id: row.id, query: row.query, createdAt: row.created_at })),
      });
    }
    const directive = languageDirective(resolvedLanguage);
    const factCards = gatherDiseaseFactCards(query.trim(), 2);
    const referencedKeys = factCards.map((fact) => fact.key);
    const storedHistory = getDiseaseSearchHistory(userId, 2);
    const storedTurns = historyToPromptTurns(storedHistory).reverse();
    const clientHistory = Array.isArray(history) ? history : [];
    const promptHistory = normalizeHistory([...storedTurns, ...clientHistory]);

    const schemaInstruction =
      'Return strict JSON with keys: condition_summary (<=60 words), diet_guidance (max 4 strings), exercise_plan (max 4 strings), ' +
      'lifestyle_hooks (max 3 strings), reminders (max 3 strings), references (max 3 strings), risk_flags (max 2 strings). ' +
      'Do not include Markdown, code fences, <think> sections, or prose outside JSON.';

    const promptPayload = {
      timestamp: new Date().toISOString(),
      directive,
      user: buildUserContext(userProfile),
      search_query: query.trim(),
      database_facts: factCards,
    };

    const messages = [
      {
        role: 'system',
        content:
          [
            'You are Smart Condition Curator, an Indian-first medical nutrition & movement coach.',
            'Follow INSTRUCTIONS strictly:',
            '- Cross-check every recommendation with database facts when available.',
            '- If data is missing, clearly state limitations instead of guessing.',
            '- Keep tone reassuring, action-focused, and limit replies to under 160 words.',
            '- For exercise, prioritize apartment-friendly flows, yoga, pranayama, walking drills relevant to Indian urban life.',
            INDIA_CULTURE_GUARDRAILS,
          ].join('\n'),
      },
      {
        role: 'user',
        content: `Context JSON:\n${JSON.stringify(promptPayload)}`,
      },
      ...promptHistory,
      {
        role: 'user',
        content: `${schemaInstruction}\nQuery: ${query.trim()}`,
      },
    ];

    let llmText;
    let answerPayload;

    try {
      llmText = await chatCompletion({ messages, temperature: 0.6, maxTokens: 520, responseFormat: 'json_object' });
      answerPayload = parseInsightAnswer(llmText);
    } catch (err) {
      console.error('[Disease Insights] LLM error:', err);
      llmText = null;
      answerPayload = null;
    }

    if (!answerPayload) {
      const fallback = buildFallbackFromFacts(factCards, resolvedLanguage);
      return res.status(200).json({
        query: query.trim(),
        language: resolvedLanguage,
        answer: fallback,
        facts: factCards,
        source: 'db_fallback',
        memoryTrail: storedHistory.map((row) => ({ id: row.id, query: row.query, createdAt: row.created_at })),
        error: 'llm_unavailable',
      });
    }

    saveDiseaseSearchHistory({
      userId,
      query: query.trim(),
      answer: answerPayload,
      referencedKeys,
      language: resolvedLanguage,
      promptSnapshot: JSON.stringify(promptPayload),
      responseSnapshot: llmText,
    });

    res.json({
      query: query.trim(),
      language: resolvedLanguage,
      answer: answerPayload,
      facts: factCards,
      source: 'llm',
      memoryTrail: storedHistory.map((row) => ({ id: row.id, query: row.query, createdAt: row.created_at })),
    });
  } catch (err) {
    console.error('[Disease Insights] Unexpected error:', err);
    res.status(500).json({ error: 'Unable to generate condition insights' });
  }
});

// Helper functions for comprehensive profile
function buildDietSummary(diet) {
  if (!diet) return '';
  const constraints = diet.constraints;
  const summaryParts = [];
  
  if (constraints.focus) {
    summaryParts.push(`Focus: ${constraints.focus}`);
  }
  if (constraints.sodium_limit_mg) {
    summaryParts.push(`Sodium limit: ${constraints.sodium_limit_mg}mg/day`);
  }
  if (constraints.max_daily_sugar_g) {
    summaryParts.push(`Max sugar: ${constraints.max_daily_sugar_g}g/day`);
  }
  if (constraints.meal_frequency) {
    summaryParts.push(`Meal frequency: ${constraints.meal_frequency}`);
  }
  if (constraints.calorie_deficit) {
    summaryParts.push(`Target: ${constraints.calorie_deficit}`);
  }
  
  return summaryParts.join(' | ');
}

function buildExerciseSummary(exerciseData) {
  if (!exerciseData) return '';
  const parts = [];
  if (exerciseData.recommendedExercises && exerciseData.recommendedExercises.length > 0) {
    parts.push(`Recommended: ${exerciseData.recommendedExercises.length} exercises available`);
  }
  if (exerciseData.avoidExercises && exerciseData.avoidExercises.length > 0) {
    parts.push(`Avoid: ${exerciseData.avoidExercises.length} exercises`);
  }
  return parts.join(' | ') || 'Exercise guidance available';
}

function buildLifestyleTips(disease) {
  const tips = [
    'Maintain consistent daily routine',
    'Get adequate sleep (7-9 hours)',
    'Manage stress through meditation or relaxation',
    'Stay hydrated throughout the day'
  ];
  
  if (disease.rules_json) {
    const rules = JSON.parse(disease.rules_json);
    if (rules.exercise_frequency) {
      tips.push(`Exercise: ${rules.exercise_frequency}`);
    }
  }
  
  return tips;
}

function buildMonitoringGuidelines(disease) {
  return {
    frequency: 'Regular check-ups as recommended by healthcare provider',
    trackingPoints: [
      'Progress with exercises',
      'Dietary adherence',
      'Weight and vitals',
      'Symptoms and pain levels'
    ],
    when_to_contact_doctor: [
      'New or worsening symptoms',
      'Persistent pain',
      'Adverse reactions to diet/exercise changes'
    ]
  };
}

function buildResources(disease) {
  return {
    consultation: 'Consult with healthcare provider before starting any new diet or exercise program',
    support: 'Consider joining disease-specific support groups',
    tracking: 'Use health tracking apps to monitor progress'
  };
}

module.exports = router;
