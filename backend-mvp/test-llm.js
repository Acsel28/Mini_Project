// backend-mvp/test-llm.js
require('dotenv').config();  // 👈 load .env for this process

const { getExercisePlan } = require('./services/llm');

(async () => {
  try {
    console.log('Loaded API KEY?', process.env.OPENAI_API_KEY ? 'YES' : 'NO');

    const exercises = await getExercisePlan({
      disease_profile_id: 'knee_pain',
      customCondition: 'pain while climbing stairs and squatting',
      age: 24,
      gender: 'male',
      height_cm: 175,
      weight_kg: 70,
    });

    console.log('LLM EXERCISES:\n', exercises);
  } catch (e) {
    console.error('LLM test error:', e);
  }
})();
