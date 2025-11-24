const db = require('../db/database');

function parseJsonArray(payload, fallback = []) {
  try {
    const parsed = JSON.parse(payload);
    return Array.isArray(parsed) ? parsed : fallback;
  } catch (err) {
    return fallback;
  }
}

function toMealPayload(row) {
  if (!row) return null;
  let recipe = {};
  if (row.recipe_json) {
    try {
      recipe = JSON.parse(row.recipe_json);
    } catch (err) {
      recipe = {};
    }
  }
  return {
    id: row.id,
    title: row.title,
    calories: row.calories || 0,
    protein: row.protein || 0,
    carbs: row.carbs || 0,
    fat: row.fat || 0,
    ingredients: row.ingredients_json ? parseJsonArray(row.ingredients_json, []) : [],
    recipe,
    tags: (row.tags || '').split(',').map((t) => t.trim()).filter(Boolean),
  };
}

function getUserProfile(userId) {
  return db.prepare('SELECT * FROM user_profiles WHERE user_id = ?').get(userId);
}

function getDietRulesForDiseaseId(diseaseId) {
  return db.prepare('SELECT * FROM disease_diet_rules WHERE disease_id = ?').get(diseaseId);
}

function fetchMealsCandidate(filterTags) {
  if (filterTags && filterTags.length) {
    // Wildcard search on tags string (comma separated)
    // match any of the provided tags
    const tag = filterTags[0];
    const rows = db.prepare(`SELECT * FROM meals WHERE tags LIKE ? LIMIT 500`).all(`%${tag}%`);
    return rows;
  }
  return db.prepare('SELECT * FROM meals LIMIT 500').all();
}

function mealMatchesConstraints(meal, avoidFoods, recommendedFoods, dietPref) {
  // Check tags first
  const tags = (meal.tags || '').split(',').map(t => t.trim().toLowerCase()).filter(Boolean);
  if (dietPref != null && dietPref != '' && dietPref !== 'none') {
    if (dietPref === 'vegan' && tags.indexOf('vegan') === -1) return false;
    if (dietPref === 'vegetarian' && tags.indexOf('vegetarian') === -1) return false;
    if (dietPref === 'keto' && tags.indexOf('keto') === -1) return false;
  }

  const ingredients = meal.ingredients_json ? JSON.parse(meal.ingredients_json) : [];
  // If any avoid food is present in ingredients, skip
  for (const a of avoidFoods) {
    const low = a.toLowerCase();
    if (ingredients.some(i => i.toLowerCase().includes(low))) return false;
  }

  // If recommended foods exists, prefer but don't require
  return true;
}

function pickMealsForSlots(candidates, caloriesTarget) {
  // Allocation per slot: breakfast 25%, lunch 35%, dinner 30%, snacks 10%
  const slots = {
    breakfast: { pct: 0.25, calTarget: Math.round(caloriesTarget * 0.25), selected: [] },
    lunch: { pct: 0.35, calTarget: Math.round(caloriesTarget * 0.35), selected: [] },
    dinner: { pct: 0.30, calTarget: Math.round(caloriesTarget * 0.30), selected: [] },
    snacks: { pct: 0.10, calTarget: Math.round(caloriesTarget * 0.10), selected: [] }
  };
  const keys = ['breakfast', 'lunch', 'dinner', 'snacks'];
  const usedIds = new Set();

  for (const key of keys) {
    const slotInfo = slots[key];
    let best = null;
    let bestScore = Infinity;

    for (const m of candidates) {
      if (usedIds.has(m.id)) continue;

      const cal = m.calories || 0;
      const caloriesDiff = Math.abs(cal - slotInfo.calTarget);
      
      // Base score: calorie difference (lower is better)
      let score = caloriesDiff;

      // Category matching bonus: strongly prefer meals tagged with the slot name
      const tags = (m.tags || '').split(',').map(t => t.trim().toLowerCase()).filter(Boolean);
      if (tags.includes(key)) {
        score -= 50;  // strong bonus for category match
      }

      // Variety bonus: slightly penalize if similar to previously selected meals
      for (const prev of usedIds) {
        const prevMeal = candidates.find(c => c.id === prev);
        if (prevMeal) {
          const tagsIntersection = tags.filter(t => 
            (prevMeal.tags || '').split(',').map(x => x.trim().toLowerCase()).includes(t)
          );
          if (tagsIntersection.length > 1) {
            score += 10;  // slight penalty for redundant tags
          }
        }
      }

      // Small random tie-break
      score += Math.random() * 3;

      if (score < bestScore) {
        bestScore = score;
        best = m;
      }
    }

    if (best) {
      slotInfo.selected.push(best);
      usedIds.add(best.id);
    }
  }

  return {
    breakfast: slots.breakfast.selected,
    lunch: slots.lunch.selected,
    dinner: slots.dinner.selected,
    snacks: slots.snacks.selected
  };
}

function calculateMacrosForMeals(meals) {
  const counts = { calories: 0, protein: 0, carbs: 0, fat: 0 };
  for (const slot of Object.keys(meals)) {
    for (const m of meals[slot]) {
      counts.calories += m.calories || 0;
      counts.protein += m.protein || 0;
      counts.carbs += m.carbs || 0;
      counts.fat += m.fat || 0;
    }
  }
  return counts;
}

async function generateMealPlan(userId) {
  const profile = getUserProfile(userId);
  if (!profile) return null;

  const targetCalories = profile.target_calories || profile.bmr || 1800;
  // Check both snake_case and camelCase for diet preference
  const dietPref = profile.diet_preference || profile.dietPreference || 'vegetarian';
  const healthConditions = profile.healthConditions ? JSON.parse(profile.healthConditions) : [];

  console.log('Generating meal plan for userId:', userId, 'dietPref:', dietPref, 'targetCalories:', targetCalories);

  // aggregate avoid and recommended foods from disease diet rules
  const avoidFoods = new Set();
  const recommendedFoods = new Set();
  for (const diseaseId of healthConditions) {
    const rule = getDietRulesForDiseaseId(diseaseId);
    if (!rule) continue;
    const avoid = rule.avoid_foods ? JSON.parse(rule.avoid_foods) : [];
    const recs = rule.recommended_foods ? JSON.parse(rule.recommended_foods) : [];
    avoid.forEach(a => avoidFoods.add(a));
    recs.forEach(r => recommendedFoods.add(r));
  }

  // fetch candidate meals by dietPref tag, then filter by avoid foods
  const candidates = fetchMealsCandidate([dietPref]).filter(m => mealMatchesConstraints(m, Array.from(avoidFoods), Array.from(recommendedFoods), dietPref));

  // For simplicity, if few candidates, relax dietPref filter
  const finalCandidates = candidates.length ? candidates : fetchMealsCandidate([]);

  console.log('Found', finalCandidates.length, 'candidate meals');

  const planSlots = pickMealsForSlots(finalCandidates, targetCalories);
  const macros = calculateMacrosForMeals(planSlots);

  // transform meals to JSON-friendly objects - include recipe, instructions
  const toMealObject = (m) => toMealPayload(m);

  return {
    userId,
    calorieTarget: targetCalories,
    dietPreference: dietPref,
    slots: {
      breakfast: planSlots.breakfast.map(toMealObject),
      lunch: planSlots.lunch.map(toMealObject),
      dinner: planSlots.dinner.map(toMealObject),
      snacks: planSlots.snacks.map(toMealObject),
    },
    macros
  };
}

module.exports = {
  generateMealPlan,
  searchMealsByIngredients
};

function searchMealsByIngredients(ingredients = [], { limit = 8 } = {}) {
  if (!Array.isArray(ingredients) || ingredients.length === 0) return [];
  const requested = ingredients
    .map((item) => item && item.toString().trim().toLowerCase())
    .filter(Boolean);

  if (!requested.length) return [];

  const rows = db.prepare('SELECT * FROM meals LIMIT 600').all();
  const scored = rows
    .map((row) => {
      const mealIngredients = row.ingredients_json
        ? parseJsonArray(row.ingredients_json, []).map((i) => i.toLowerCase())
        : [];
      const hits = requested.filter((term) =>
        mealIngredients.some((ingredient) => ingredient.includes(term))
      ).length;
      return { row, hits };
    })
    .filter((entry) => entry.hits > 0)
    .sort((a, b) => {
      if (b.hits !== a.hits) return b.hits - a.hits;
      return (b.row.protein || 0) - (a.row.protein || 0);
    })
    .slice(0, limit)
    .map((entry) => ({ ...toMealPayload(entry.row), matchCount: entry.hits }));

  return scored;
}
