const express = require('express');
const router = express.Router();
const { getExercisesForDiseaseKey, getDiseaseWithDietByKey, getAllDiseases, searchDiseases } = require('../services/disease_service');
const db = require('../db/database');

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
