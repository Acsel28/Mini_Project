// backend-mvp/routes/exercises.js
const express = require('express');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

/**
 * GET /api/exercises
 * Optional query: ?condition=diabetes / hypertension / obesity / pcos / heart
 *
 * Returns a list of exercises tailored to that condition, or a general set.
 */
router.get('/', requireAuth, (req, res) => {
  const raw = (req.query.condition || 'general').toString().toLowerCase();

  let condition = raw;
  if (raw === 'diabetes_type2') condition = 'diabetes';
  if (raw === 'bp') condition = 'hypertension';
  if (raw === 'weight_loss') condition = 'obesity';

  let exercises;

  switch (condition) {
    case 'diabetes':
      exercises = [
        {
          id: 'ex-di-1',
          name: 'Brisk Walking',
          duration: '30 mins',
          intensity: 'low–medium',
          frequency: '5 days/week',
          description: 'Steady pace walking that slightly raises heart rate; ideal after meals.',
          caution: 'Carry water and a small carb snack in case of low sugar.',
        },
        {
          id: 'ex-di-2',
          name: 'Stationary Cycling',
          duration: '20 mins',
          intensity: 'medium',
          frequency: '3 days/week',
          description: 'Low-impact cardio that helps improve insulin sensitivity.',
          caution: 'Monitor blood sugar before and after longer sessions.',
        },
        {
          id: 'ex-di-3',
          name: 'Light Resistance Training',
          duration: '15–20 mins',
          intensity: 'low',
          frequency: '2–3 days/week',
          description: 'Bodyweight squats, wall pushups, light dumbbells.',
          caution: 'Avoid holding breath; exhale during effort.',
        },
      ];
      break;

    case 'hypertension':
      exercises = [
        {
          id: 'ex-ht-1',
          name: 'Slow Walking',
          duration: '25–30 mins',
          intensity: 'low',
          frequency: '5 days/week',
          description: 'Comfortable pace walking, able to speak full sentences.',
          caution: 'Avoid sudden sprints or very steep inclines.',
        },
        {
          id: 'ex-ht-2',
          name: 'Yoga & Deep Breathing',
          duration: '15 mins',
          intensity: 'low',
          frequency: 'daily',
          description: 'Gentle asanas plus diaphragmatic breathing.',
          caution: 'Skip inverted poses without medical advice.',
        },
        {
          id: 'ex-ht-3',
          name: 'Stretching Routine',
          duration: '10–15 mins',
          intensity: 'very low',
          frequency: 'daily',
          description: 'Neck, shoulder, hamstring and calf stretches.',
          caution: 'No bouncing; hold stretches steadily.',
        },
      ];
      break;

    case 'obesity':
      exercises = [
        {
          id: 'ex-ob-1',
          name: 'Walk–Rest Intervals',
          duration: '20–30 mins',
          intensity: 'low',
          frequency: '5 days/week',
          description: '1–2 mins brisk walk, 1 min slow walk, repeat.',
          caution: 'Stop if you feel chest pain, dizziness, or severe breathlessness.',
        },
        {
          id: 'ex-ob-2',
          name: 'Chair Exercises',
          duration: '15 mins',
          intensity: 'low',
          frequency: '3–4 days/week',
          description: 'Seated marches, leg raises, arm circles with/without light weights.',
          caution: 'Use a stable chair without wheels.',
        },
        {
          id: 'ex-ob-3',
          name: 'Beginner Strength Routine',
          duration: '15–20 mins',
          intensity: 'low–medium',
          frequency: '3 days/week',
          description: 'Wall pushups, sit-to-stand, supported lunges.',
          caution: 'Focus on good form, skip if joints hurt badly.',
        },
      ];
      break;

    case 'pcos':
      exercises = [
        {
          id: 'ex-pc-1',
          name: 'Moderate Walking',
          duration: '30 mins',
          intensity: 'medium',
          frequency: '5 days/week',
          description: 'Steady walk to support insulin sensitivity and mood.',
          caution: 'Stay hydrated, avoid walking in extreme heat.',
        },
        {
          id: 'ex-pc-2',
          name: 'Low-Impact Cardio',
          duration: '20 mins',
          intensity: 'medium',
          frequency: '3 days/week',
          description: 'Cycling, elliptical, or dance workout without jumping.',
          caution: 'Avoid very high-intensity intervals without guidance.',
        },
        {
          id: 'ex-pc-3',
          name: 'Strength Training',
          duration: '20 mins',
          intensity: 'medium',
          frequency: '2–3 days/week',
          description: 'Full-body routine using bands or light weights.',
          caution: 'Warm up first; progress weights slowly.',
        },
      ];
      break;

    case 'heart':
    case 'cardiac':
      exercises = [
        {
          id: 'ex-ca-1',
          name: 'Cardiac Rehab Walk',
          duration: '10–20 mins',
          intensity: 'very low–low',
          frequency: '5–6 days/week',
          description: 'Very gentle walk; stop if chest pain or unusual symptoms occur.',
          caution: 'Follow cardiologist’s advice strictly.',
        },
        {
          id: 'ex-ca-2',
          name: 'Breathing & Relaxation',
          duration: '10 mins',
          intensity: 'very low',
          frequency: 'daily',
          description: 'Slow breathing, guided relaxation, or meditation.',
          caution: 'Comfortable seated or lying posture.',
        },
      ];
      break;

    default:
      // GENERAL PLAN
      exercises = [
        {
          id: 'ex-gen-1',
          name: 'Brisk Walking',
          duration: '30 mins',
          intensity: 'medium',
          frequency: '5 days/week',
          description: 'Easy to start, low impact and great for overall health.',
          caution: 'Wear comfortable shoes and stay hydrated.',
        },
        {
          id: 'ex-gen-2',
          name: 'Bodyweight Strength',
          duration: '20 mins',
          intensity: 'medium',
          frequency: '2–3 days/week',
          description: 'Squats, pushups (wall or knee), glute bridges, planks.',
          caution: 'Avoid movements that cause sharp joint pain.',
        },
        {
          id: 'ex-gen-3',
          name: 'Flexibility Routine',
          duration: '10–15 mins',
          intensity: 'low',
          frequency: 'daily',
          description: 'Gentle stretching after a warm shower or walk.',
          caution: 'No sudden jerks; breathe normally.',
        },
      ];
      break;
  }

  return res.json({ condition, exercises });
});

/**
 * POST /api/exercises/log
 * (optional logging stub)
 */
router.post('/log', requireAuth, (req, res) => {
  const userId = req.user.id;
  const { exercise_id, duration, notes } = req.body || {};

  console.log('Exercise log from:', userId, { exercise_id, duration, notes });

  // Later: insert into DB
  return res.json({ status: 'logged', exercise_id, duration, notes });
});

module.exports = router;
