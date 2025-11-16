// This is an LLM orchestration layer. For now returns simple JSON.
// Later: switch to OpenAI / other API.

const fetch = require('node-fetch');

async function generateMealPlan({ userId, target_calories=1800, dietaryFlags=[], diseaseProfileId=null }) {
  // If you have OPENAI_API_KEY in .env, call OpenAI (example)
  const key = process.env.OPENAI_API_KEY;
  if (!key) {
    // simple rule-based plan
    return {
      meals: [
        { title: 'Oats + banana', calories: Math.round(target_calories * 0.22) },
        { title: 'Lentil soup + salad', calories: Math.round(target_calories * 0.36) },
        { title: 'Grilled fish + veggies', calories: Math.round(target_calories * 0.42) }
      ],
      total_calories: Math.round(target_calories)
    };
  }

  // Example prompt — you should expand/validate schema strictly
  const prompt = `User target_calories=${target_calories}, dietaryFlags=${JSON.stringify(dietaryFlags)}, diseaseProfile=${diseaseProfileId}. Return JSON: {meals:[{title,calories,macros:{p,c,f},ingredients:[{name,qty}],cooking_instructions:[] }], total_calories}.`;
  const r = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model: 'gpt-4o-mini',
      messages: [{ role:'system', content: 'You are a nutrition assistant' }, { role:'user', content: prompt }],
      max_tokens: 800
    })
  });
  const json = await r.json();
  // VERY IMPORTANT: validate json. Here we'll try to parse the assistant reply as JSON
  try {
    const text = json.choices?.[0]?.message?.content || '{}';
    const obj = JSON.parse(text);
    return obj;
  } catch (err) {
    console.error('LLM parse failed', err, json);
    // fallback
    return {
      meals: [
        { title: 'Fallback oats', calories: Math.round(target_calories*0.25) },
        { title: 'Fallback salad', calories: Math.round(target_calories*0.35) },
        { title: 'Fallback dinner', calories: Math.round(target_calories*0.4) }
      ],
      total_calories: target_calories
    };
  }
}

async function generateRecipeFromIngredients({ ingredients=[] }) {
  // For now return a simple structured recipe
  return {
    title: 'Auto Recipe: ' + (ingredients.slice(0,3).join(', ') || 'Mix'),
    ingredients,
    instructions: ['Combine ingredients', 'Cook until done', 'Serve warm']
  };
}

module.exports = { generateMealPlan, generateRecipeFromIngredients };
