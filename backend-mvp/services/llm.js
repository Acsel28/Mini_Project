// backend-mvp/services/llm.js
const OpenAI = require('openai');

if (!process.env.OPENAI_API_KEY) {
  console.warn('[LLM] OPENAI_API_KEY is not set. LLM features will not work.');
}

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/**
 * Ask the LLM for a disease-specific exercise plan.
 *
 * context:
 *  - disease_profile_id (e.g. 'knee_pain', 'diabetes', 'pcos')
 *  - customCondition (free text from user)
 *  - age, gender, height_cm, weight_kg
 */
async function getExercisePlan(context) {
  if (!process.env.OPENAI_API_KEY) {
    throw new Error('no_openai_api_key');
  }

  const {
    disease_profile_id,
    customCondition,
    age,
    gender,
    height_cm,
    weight_kg,
  } = context;

  const systemPrompt = `
You are a certified physiotherapist and fitness expert.
You create SAFE, SIMPLE home exercise plans tailored to a user's condition.

Rules:
- Always assume beginner level unless specified.
- Avoid suggesting heavy weights, jumps, or high impact for joint issues.
- For each exercise, include: name, target_area, difficulty, sets, reps_or_duration, frequency_per_week, description, cautions.
- Use Indian context when relevant (e.g. walking, simple home routines).
- Output STRICTLY JSON in this shape:

{
  "exercises": [
    {
      "name": "string",
      "target_area": "string",
      "difficulty": "easy|medium|hard",
      "sets": 3,
      "reps_or_duration": "10 reps" or "30 seconds",
      "frequency_per_week": 4,
      "description": "short explanation",
      "cautions": "important safety notes"
    }
  ]
}
`;

  const userPrompt = `
User profile:
- Age: ${age ?? 'unknown'}
- Gender: ${gender ?? 'unknown'}
- Height: ${height_cm ?? 'unknown'} cm
- Weight: ${weight_kg ?? 'unknown'} kg

Condition:
- disease_profile_id: ${disease_profile_id ?? 'general'}
- user_description: ${customCondition ?? 'not provided'}

Task:
Generate 4–6 safe exercises that are specifically helpful for this condition.
`;

  const completion = await client.chat.completions.create({
    model: 'gpt-4.1-mini', // or any model you have access to
    response_format: { type: 'json_object' },
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt },
    ],
  });

  const content = completion.choices[0].message.content;
  let parsed;
  try {
    parsed = JSON.parse(content);
  } catch (err) {
    console.error('[LLM] JSON parse error:', err, '\nContent:', content);
    throw new Error('llm_parse_error');
  }

  let exercises = parsed;
  if (
    parsed &&
    typeof parsed === 'object' &&
    Array.isArray(parsed.exercises)
  ) {
    exercises = parsed.exercises;
  }

  if (!Array.isArray(exercises)) {
    throw new Error('llm_invalid_format');
  }

  return exercises;
}

module.exports = {
  getExercisePlan,
};
