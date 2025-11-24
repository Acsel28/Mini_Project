const INDIA_CULTURE_GUARDRAILS = `Cultural guardrails:
- Keep every recommendation rooted in everyday Indian households (think dal, roti, sabzi, poha, upma, idli, millets, curd rice, seasonal fruits, chutneys).
- Prefer affordable pantry staples, street-side snacks made healthier, and vegetarian-friendly protein like dal, sprouts, paneer, curd, and millets; non-veg options should be basic (eggs, fish curry) rather than gourmet.
- When suggesting movement or recovery, weave in yoga flows, pranayama, surya namaskar, brisk terrace walks, or light bodyweight drills that can be done in a small apartment.
- Mindset and tone should feel like a caring Indian coach speaking to a middle-class family juggling work, commute, and elders at home; celebrate small wins and avoid fancy jargon.
- Use Indian measurements or references (glass of water, katori, ladle, pressure cooker whistle) when helpful.`;

function isHindiLanguage(language) {
  if (!language) return false;
  const normalized = language.toString().trim().toLowerCase();
  return normalized === 'hi' || normalized === 'hindi' || normalized === 'हिन्दी' || normalized === 'हिंदी';
}

function languageDirective(language) {
  return isHindiLanguage(language)
    ? 'Respond entirely in conversational Hindi using Devanagari script while keeping numerals as digits.'
    : 'Respond in clear Indian English with short, action-focused sentences.';
}

function normalizeHistory(history = []) {
  if (!Array.isArray(history)) return [];
  return history
    .map((entry) => {
      if (!entry) return null;
      const text = (entry.content || entry.message || '').toString().trim();
      if (!text) return null;
      const role = entry.role === 'assistant' || entry.role === 'coach' ? 'assistant' : 'user';
      return { role, content: text };
    })
    .filter(Boolean)
    .slice(-8);
}

function buildUserContext(profile) {
  if (!profile) return {};

  let healthConditions = [];
  if (profile.healthConditions) {
    try {
      healthConditions = JSON.parse(profile.healthConditions);
    } catch (err) {
      healthConditions = [];
    }
  }

  return {
    name: profile.name,
    age: profile.age,
    gender: profile.gender,
    height_cm: profile.height_cm,
    weight_kg: profile.weight_kg,
    target_calories: profile.target_calories,
    diet_preference: profile.diet_preference,
    fitness_goal: profile.fitness_goal,
    activity_level: profile.activity_level,
    health_conditions: healthConditions,
  };
}

module.exports = {
  INDIA_CULTURE_GUARDRAILS,
  isHindiLanguage,
  languageDirective,
  normalizeHistory,
  buildUserContext,
};
