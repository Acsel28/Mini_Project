const { chatCompletion } = require('./llm_client');
const {
  INDIA_CULTURE_GUARDRAILS,
  languageDirective,
  isHindiLanguage,
} = require('./ai_prompt_utils');
const { parseJsonResponse } = require('./llm_response_utils');

function buildPlanSynopsis(plan = {}) {
  const macros = plan.macros || {};
  const slots = plan.slots || {};

  const serializedSlots = Object.fromEntries(
    Object.entries(slots).map(([slot, meals]) => [
      slot,
      (meals || []).map((meal) => ({
        id: meal.id,
        title: meal.title,
        calories: meal.calories,
        protein: meal.protein,
        carbs: meal.carbs,
        fat: meal.fat,
        tags: meal.tags,
      })),
    ])
  );

  return {
    calorieTarget: plan.calorieTarget,
    dietPreference: plan.dietPreference,
    macros,
    slots: serializedSlots,
  };
}

function buildUserSnapshot(profile = {}) {
  if (!profile) return {};
  return {
    id: profile.id,
    email: profile.email,
    name: profile.name,
    age: profile.age,
    gender: profile.gender,
    height_cm: profile.height_cm,
    weight_kg: profile.weight_kg,
    target_calories: profile.target_calories,
    diet_preference: profile.diet_preference,
    fitness_goal: profile.fitness_goal,
    activity_level: profile.activity_level,
    disease: profile.disease,
  };
}

function buildPrompt({ userProfile, plan, language }) {
  const directive = languageDirective(language);
  const payload = {
    timestamp: new Date().toISOString(),
    user: buildUserSnapshot(userProfile),
    plan: buildPlanSynopsis(plan),
  };

  const schema =
    'Return strict JSON (no markdown) with keys: summary (<=60 words), macro_focus (<=40 words), hydration_tip (<=25 words), movement_tip (<=25 words).';

  return [
    {
      role: 'system',
      content: [
        'You are NutriNarrator, an Indian-first AI dietitian who explains plans in friendly, practical language.',
        directive,
        INDIA_CULTURE_GUARDRAILS,
        'Keep tone upbeat, action-focused, and rooted in common Indian kitchens.',
      ].join('\n'),
    },
    {
      role: 'user',
      content: `Context JSON:\n${JSON.stringify(payload)}`,
    },
    {
      role: 'user',
      content: `${schema}\nDraft a concise narration for the above plan.`,
    },
  ];
}

function fallbackNarrative(plan, language) {
  const macros = plan?.macros || {};
  const calories = macros.calories || plan?.calorieTarget || 0;
  const macroLine = macros.protein || macros.carbs || macros.fat
    ? `Protein ${Math.round(macros.protein || 0)}g · Carbs ${Math.round(macros.carbs || 0)}g · Fat ${Math.round(macros.fat || 0)}g`
    : null;

  if (isHindiLanguage(language)) {
    return {
      summary: `आज का भोजन प्लान लगभग ${Math.round(calories)} कैलोरी का है और हर खाने में सब्ज़ी + प्रोटीन का संतुलन रखा गया है।`,
      macro_focus: macroLine
        ? `${macroLine} — डिनर में हल्का प्रोटीन रखें।`
        : 'प्रोटीन, जटिल कार्ब्स और अच्छे फैट को बराबर रखें।',
      hydration_tip: 'हर खाने से पहले 1 गिलास पानी या छाछ लें।',
      movement_tip: 'भोजन के बाद 7 मिनट की टेरेस वॉक या सूर्य नमस्कार करें।',
      language: 'hindi',
      source: 'fallback',
    };
  }

  return {
    summary: `Your plan hovers around ${Math.round(calories)} kcal with veggie-forward plates and steady protein anchors all day.`,
    macro_focus: macroLine
      ? `${macroLine} · Add a palm-sized protein at dinner to stay on target.`
      : 'Balance each plate with half veggies, quarter protein, quarter smart carbs.',
    hydration_tip: 'Sip a glass of water or chaas 15 minutes before meals.',
    movement_tip: 'Take a 7-minute corridor walk or 4 rounds of surya namaskar post meals.',
    language: 'english',
    source: 'fallback',
  };
}

async function generateMealPlanNarrative({ userProfile, plan }) {
  if (!plan) return null;
  const language = (userProfile?.language || 'english').toString();
  const messages = buildPrompt({ userProfile, plan, language });

  try {
    const completion = await chatCompletion({
      messages,
      temperature: 0.65,
      maxTokens: 360,
      responseFormat: 'json_object',
    });

    const parsed = parseJsonResponse(completion);
    if (parsed && parsed.summary) {
      return {
        summary: parsed.summary,
        macro_focus: parsed.macro_focus,
        hydration_tip: parsed.hydration_tip,
        movement_tip: parsed.movement_tip,
        language,
        source: 'llm',
      };
    }
  } catch (err) {
    console.warn('[AI Content] Meal narrative generation failed:', err.message || err);
  }

  return fallbackNarrative(plan, language);
}

module.exports = {
  generateMealPlanNarrative,
  generateRecipesFromIngredients,
};

function normalizeRecipeList(recipes = [], language, maxRecipes = 3) {
  if (!Array.isArray(recipes)) return [];
  return recipes
    .filter((recipe) => recipe && recipe.title)
    .slice(0, maxRecipes)
    .map((recipe, index) => {
      const macros = recipe.macros || {};
      return {
        id: recipe.id || `ai_recipe_${Date.now()}_${index}`,
        title: recipe.title,
        description: recipe.description || '',
        calories: Math.round(recipe.calories || macros.calories || 0),
        macros: {
          protein: Math.round(macros.protein || recipe.protein || 0),
          carbs: Math.round(macros.carbs || recipe.carbs || 0),
          fat: Math.round(macros.fat || recipe.fat || 0),
        },
        ingredients: Array.isArray(recipe.ingredients)
          ? recipe.ingredients.map((item) => item.toString().trim()).filter(Boolean).slice(0, 10)
          : [],
        steps: Array.isArray(recipe.steps || recipe.instructions)
          ? (recipe.steps || recipe.instructions).map((step) => step.toString().trim()).filter(Boolean).slice(0, 8)
          : [],
        prepTime: recipe.prepTime || recipe.cookTime || '15 minutes',
        cuisine: recipe.cuisine || (isHindiLanguage(language) ? 'भारतीय' : 'Indian Fusion'),
        tags: Array.isArray(recipe.tags) ? recipe.tags.map((tag) => tag.toString()) : [],
        source: recipe.source || 'llm',
      };
    });
}

function fallbackIngredientRecipes(pantryMatches = [], language, maxRecipes = 3) {
  if (!Array.isArray(pantryMatches) || pantryMatches.length === 0) return [];
  return pantryMatches.slice(0, maxRecipes).map((meal, index) => ({
    id: meal.id || `pantry_match_${index}`,
    title: meal.title,
    description: meal.ingredients && meal.ingredients.length
      ? `Uses ${meal.ingredients.slice(0, 4).join(', ')}`
      : isHindiLanguage(language)
        ? 'घर की उपलब्ध सामग्रियों से झटपट रेसिपी'
        : 'Quick pantry-friendly recipe',
    calories: Math.round(meal.calories || 0),
    macros: {
      protein: Math.round(meal.protein || 0),
      carbs: Math.round(meal.carbs || 0),
      fat: Math.round(meal.fat || 0),
    },
    ingredients: meal.ingredients || [],
    steps: Array.isArray(meal.recipe?.instructions)
      ? meal.recipe.instructions.slice(0, 6)
      : [isHindiLanguage(language)
        ? 'चरण 1: सभी सामग्रियों को तैयार करें'
        : 'Prep the ingredients',
        isHindiLanguage(language)
          ? 'चरण 2: गैस पर पकाएँ और स्वाद देखें'
          : 'Cook on the stove and adjust seasoning'],
    prepTime: meal.recipe?.cookTime || '20 minutes',
    cuisine: meal.tags?.includes('indian') ? 'Indian' : 'Fusion',
    tags: meal.tags || [],
    source: 'pantry_fallback',
  }));
}

async function generateRecipesFromIngredients({
  ingredients = [],
  userProfile,
  pantryMatches = [],
  maxRecipes = 3,
}) {
  const cleanIngredients = ingredients
    .map((item) => item && item.toString().trim())
    .filter(Boolean);

  if (cleanIngredients.length === 0) {
    return { recipes: [], source: 'invalid_request' };
  }

  const language = (userProfile?.language || 'english').toString();
  const directive = languageDirective(language);

  const context = {
    timestamp: new Date().toISOString(),
    user: buildUserSnapshot(userProfile),
    pantryMatches: pantryMatches.slice(0, 4),
    ingredients: cleanIngredients,
    requestedRecipes: maxRecipes,
  };

  const schema = `Return strict JSON with key "recipes" (array, max ${maxRecipes}).
Each recipe object must include: id (string), title, description (<=35 words), calories (integer), macros {protein, carbs, fat}, ingredients (<=8 pantry items), steps (<=5 short sentences), prepTime, cuisine, tags (<=4 strings).`;

  const messages = [
    {
      role: 'system',
      content: [
        'You are PantryChef, an Indian-first culinary AI that turns leftover ingredients into healthy meals.',
        directive,
        INDIA_CULTURE_GUARDRAILS,
        'Stay realistic, avoid exotic ingredients unless already provided, and keep responses JSON-only.',
      ].join('\n'),
    },
    { role: 'user', content: `Context JSON:\n${JSON.stringify(context)}` },
    { role: 'user', content: `${schema}\nDraft the recipes now.` },
  ];

  try {
    const completion = await chatCompletion({
      messages,
      temperature: 0.7,
      maxTokens: 520,
      responseFormat: 'json_object',
    });
    const parsed = parseJsonResponse(completion);
    const normalized = normalizeRecipeList(parsed?.recipes, language, maxRecipes);
    if (normalized.length) {
      return { recipes: normalized, source: 'llm' };
    }
  } catch (err) {
    console.warn('[AI Content] Ingredient recipe generation failed:', err.message || err);
  }

  const fallback = fallbackIngredientRecipes(pantryMatches, language, maxRecipes);
  return { recipes: fallback, source: 'pantry_fallback' };
}
