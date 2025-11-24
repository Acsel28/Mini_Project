const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth_mw');
const db = require('../db/database');

// GET /api/analytics/user-stats
router.get('/user-stats', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  try {
    const user = db.prepare(`
        SELECT 
          users.id, 
          p.name, 
          p.age, 
          p.weight_kg, 
          p.height_cm, 
          p.target_calories,
          p.activity_level,
          p.healthConditions,
          p.diet_preference
        FROM users
        LEFT JOIN user_profiles p ON users.id = p.user_id
        WHERE users.id = ?
      `).get(userId);

    if (!user) return res.status(404).json({ error: 'User not found' });

    // Calculate BMI
    const height = user.height_cm ? user.height_cm / 100 : null;
    const bmi = height && user.weight_kg ? user.weight_kg / (height * height) : 0;

    // Calculate BMR
    let bmr = 0;
    if (user.age && user.weight_kg && user.height_cm) {
      // Using Mifflin-St Jeor formula (simplified)
      bmr = 10 * user.weight_kg + 6.25 * user.height_cm - 5 * user.age + 5;
    }

    // Activity multipliers
    const activityMultipliers = {
      'sedentary': 1.2,
      'lightly_active': 1.375,
      'moderately_active': 1.55,
      'very_active': 1.725,
      'extremely_active': 1.9
    };

    const activityLevel = user.activity_level || 'moderately_active';
    const tdee = bmr * (activityMultipliers[activityLevel] || 1.55);
    const calorieTarget = user.target_calories || Math.round(tdee) || 2000;
    const macroTargets = estimateMacroTargets(calorieTarget);

    res.json({
      user: {
        id: user.id,
        name: user.name,
        age: user.age,
        weight: user.weight_kg,
        height: user.height_cm,
        targetCalories: calorieTarget,
        activityLevel
      },
      metrics: {
        bmi: parseFloat(bmi.toFixed(2)),
        bmiCategory: getBMICategory(bmi),
        bmr: parseFloat(bmr.toFixed(2)),
        tdee: parseFloat(tdee.toFixed(2)),
        calories: calorieTarget,
        protein: macroTargets.protein,
        carbs: macroTargets.carbs,
        fat: macroTargets.fat
      },
      healthConditions: user.healthConditions ? JSON.parse(user.healthConditions) : [],
      goals: {
        dailyCalories: calorieTarget,
        dailyWater: 3000,
        dailySteps: 10000,
        weeklyWorkout: 150
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/analytics/recommendations
router.get('/recommendations', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  try {
    const user = db.prepare(`
        SELECT 
          p.name, 
          p.weight_kg, 
          p.height_cm,
          p.age,
          p.target_calories,
          p.healthConditions,
          p.diet_preference,
          p.activity_level
        FROM users
        LEFT JOIN user_profiles p ON users.id = p.user_id
        WHERE users.id = ?
      `).get(userId);

    if (!user) return res.status(404).json({ error: 'User not found' });

    const healthConditions = user.healthConditions ? JSON.parse(user.healthConditions) : [];
    const heightMeters = user.height_cm ? user.height_cm / 100 : null;
    const bmi = heightMeters && user.weight_kg ? user.weight_kg / (heightMeters ** 2) : 0;
    const dietPreference = user.diet_preference || 'vegetarian';
    const activityLevel = user.activity_level || 'moderately_active';

    const recommendations = [];

    if (bmi > 25) {
      recommendations.push({
        id: 'weight_loss',
        title: 'Weight Management',
        description: 'Your BMI suggests focusing on gradual fat loss via balanced plates and 20-minute walks.',
        priority: 'high',
        icon: 'fitness_center',
        color: 'error'
      });
    } else if (bmi > 0 && bmi < 18.5) {
      recommendations.push({
        id: 'weight_gain',
        title: 'Nutrition Boost',
        description: 'Add calorie-dense snacks like nuts, paneer paratha, or besan chilla twice a day.',
        priority: 'high',
        icon: 'restaurant',
        color: 'warning'
      });
    }

    if (healthConditions.length > 0) {
      recommendations.push({
        id: 'disease_diet',
        title: 'Disease-Specific Diet',
        description: `Customize your meal plan for ${healthConditions.length} tracked condition(s).`,
        priority: 'high',
        icon: 'medical_services',
        color: 'primary'
      });
    }

    recommendations.push({
      id: 'preference',
      title: 'Diet Preference',
      description: `Stick to a ${dietPreference.replace('_', ' ')} rhythm to keep energy stable all week.`,
      priority: 'medium',
      icon: 'restaurant',
      color: 'secondary'
    });

    recommendations.push({
      id: 'activity_level',
      title: 'Movement Reminder',
      description: `Current activity level: ${activityLevel.replace('_', ' ')}. Add 5-min terrace walks after meals to upgrade it.`,
      priority: 'medium',
      icon: 'directions_walk',
      color: 'info'
    });

    recommendations.push({
      id: 'hydration',
      title: 'Stay Hydrated',
      description: 'Drink at least 3-4 liters of water or chaas for joint and gut comfort.',
      priority: 'medium',
      icon: 'water_drop',
      color: 'info'
    });

    recommendations.push({
      id: 'sleep',
      title: 'Sleep Quality',
      description: 'Aim for 7-9 hours nightly; keep devices away 30 minutes before bed.',
      priority: 'medium',
      icon: 'dark_mode',
      color: 'info'
    });

    recommendations.push({
      id: 'exercise',
      title: 'Regular Exercise',
      description: 'Stack 150 minutes/week of moderate activity using brisk walks + yoga flow.',
      priority: 'medium',
      icon: 'directions_run',
      color: 'success'
    });

    res.json({
      recommendations,
      personalized: true
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/analytics/meal-suggestions
router.get('/meal-suggestions', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const { mealType = 'breakfast', count = 5 } = req.query;

  try {
    const user = db.prepare(`
        SELECT healthConditions, diet_preference, goal
        FROM user_profiles
        WHERE user_id = ?
      `).get(userId);

    if (!user) {
      return res.status(404).json({ error: 'User profile not found' });
    }

    const healthConditions = user.healthConditions ? JSON.parse(user.healthConditions) : [];
    const dietPreference = user.diet_preference || 'vegetarian';

    let query = `
      SELECT id, title, calories, protein, carbs, fat, tags
      FROM meals
      WHERE tags LIKE ?
    `;
    const params = [`%${mealType}%`];

    if (dietPreference && dietPreference !== 'any') {
      query += ' AND tags LIKE ?';
      params.push(`%${dietPreference}%`);
    }

    query += ' LIMIT ?';
    params.push(parseInt(count, 10) || 5);

    const meals = db.prepare(query).all(...params);

    if (meals.length === 0) {
      return res.json({
        mealType,
        meals: [
          {
            id: 'default_1',
            title: `Healthy ${mealType}`,
            calories: mealType === 'breakfast' ? 400 : mealType === 'lunch' ? 600 : 500,
            macros: { protein: 20, carbs: 50, fat: 15 },
            tags: ['healthy', mealType, dietPreference]
          }
        ]
      });
    }

    res.json({
      mealType,
      userDietPreference: dietPreference,
      healthConditions,
      meals: meals.map((meal) => ({
        id: meal.id,
        title: meal.title,
        calories: meal.calories,
        macros: {
          protein: meal.protein,
          carbs: meal.carbs,
          fat: meal.fat
        },
        tags: meal.tags ? meal.tags.split(',').map((tag) => tag.trim()) : []
      }))
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/analytics/health-insights
router.get('/health-insights', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  try {
    const user = db.prepare(`
      SELECT p.weight_kg, p.height_cm, p.age, p.target_calories
      FROM users
      LEFT JOIN user_profiles p ON users.id = p.user_id
      WHERE users.id = ?
    `).get(userId);

    if (!user) return res.status(404).json({ error: 'User not found' });

    const insights = [];
    const bmi = user.weight_kg / ((user.height_cm / 100) ** 2);

    // BMI insight
    if (bmi < 18.5) {
      insights.push({
        type: 'warning',
        title: 'Underweight Status',
        message: 'You may need to increase calorie intake. Consult a healthcare provider.',
        actionable: true
      });
    } else if (bmi > 25) {
      insights.push({
        type: 'alert',
        title: 'Overweight Status',
        message: 'Consider adopting a balanced diet and regular exercise routine.',
        actionable: true
      });
    } else {
      insights.push({
        type: 'success',
        title: 'Healthy Weight',
        message: 'You are maintaining a healthy weight. Keep it up!',
        actionable: false
      });
    }

    // Calorie insight
    insights.push({
      type: 'info',
      title: 'Daily Calorie Target',
      message: `Your recommended daily intake is approximately ${user.target_calories} calories.`,
      actionable: false
    });

    // Nutrition insight
    insights.push({
      type: 'info',
      title: 'Balanced Nutrition',
      message: 'Aim for 50% carbs, 30% protein, 20% fats in your daily diet.',
      actionable: true
    });

    res.json({ insights });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});


// Helper function
function getBMICategory(bmi) {
  if (bmi < 18.5) return 'underweight';
  if (bmi < 25) return 'healthy';
  if (bmi < 30) return 'overweight';
  return 'obese';
}

function estimateMacroTargets(calories) {
  const safeCalories = Math.max(Number(calories) || 0, 1200);
  return {
    protein: Math.round((safeCalories * 0.3) / 4),
    carbs: Math.round((safeCalories * 0.4) / 4),
    fat: Math.round((safeCalories * 0.3) / 9)
  };
}

// --- Trends & Prediction Endpoints ---
// GET /api/analytics/trends
router.get('/trends', (req, res) => {
  res.json({
    trends: [
      { label: 'Weight', data: [70, 69.5, 69, 68.8, 68.5, 68.2, 68] },
      { label: 'BMI', data: [24.5, 24.3, 24.1, 24.0, 23.9, 23.8, 23.7] },
      { label: 'Calories', data: [2000, 1950, 1900, 1850, 1800, 1750, 1700] },
    ],
    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  });
});

// GET /api/analytics/predict
router.get('/predict', (req, res) => {
  res.json({
    prediction: {
      message: 'If you keep this up, you will reach your goal weight in 3 weeks!',
      weightProjection: [68, 67.8, 67.5, 67.2, 67],
      labels: ['Now', '+1w', '+2w', '+3w', 'Goal'],
    },
  });
});

// GET /api/analytics/dynamic-insights (based on logged data)
router.get('/dynamic-insights', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  try {
    const today = new Date().toISOString().split('T')[0];
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    
    // Fetch hydration data
    const hydrationToday = db.prepare(`
      SELECT SUM(amount_ml) as total FROM hydration_logs
      WHERE user_id = ? AND date = ?
    `).get(userId, today);
    const hydrationYesterday = db.prepare(`
      SELECT SUM(amount_ml) as total FROM hydration_logs
      WHERE user_id = ? AND date = ?
    `).get(userId, yesterday);

    // Fetch sleep data
    const sleepToday = db.prepare(`
      SELECT hours, quality FROM sleep_logs
      WHERE user_id = ? AND date = ?
      LIMIT 1
    `).get(userId, today);
    const sleepYesterday = db.prepare(`
      SELECT hours, quality FROM sleep_logs
      WHERE user_id = ? AND date = ?
      LIMIT 1
    `).get(userId, yesterday);

    // Fetch last 7 days of data for trends
    const sevenDaysAgo = new Date(Date.now() - (7 * 86400000)).toISOString().split('T')[0];
    const hydrationWeekly = db.prepare(`
      SELECT date, SUM(amount_ml) as total FROM hydration_logs
      WHERE user_id = ? AND date >= ?
      GROUP BY date
      ORDER BY date DESC
    `).all(userId, sevenDaysAgo);

    const sleepWeekly = db.prepare(`
      SELECT date, AVG(hours) as avg_hours FROM sleep_logs
      WHERE user_id = ? AND date >= ?
      GROUP BY date
      ORDER BY date DESC
    `).all(userId, sevenDaysAgo);

    const insights = [];

    // Hydration insights
    const todayWater = hydrationToday?.total || 0;
    const yesterdayWater = hydrationYesterday?.total || 0;

    if (todayWater > 3000) {
      insights.push({
        type: 'success',
        title: 'Excellent Hydration',
        message: `You've logged ${(todayWater / 1000).toFixed(1)}L of water today. Great job staying hydrated!`,
        icon: 'water_drop',
        priority: 'high'
      });
    } else if (todayWater > 1500) {
      insights.push({
        type: 'info',
        title: 'Good Hydration Progress',
        message: `You've logged ${(todayWater / 1000).toFixed(1)}L so far. Aim for 3L total.`,
        icon: 'water_drop',
        priority: 'medium'
      });
    } else if (todayWater > 0) {
      insights.push({
        type: 'warning',
        title: 'Stay Hydrated',
        message: `You've only logged ${(todayWater / 1000).toFixed(1)}L. Try to reach 3L by end of day.`,
        icon: 'water_drop',
        priority: 'medium'
      });
    }

    if (todayWater > yesterdayWater && yesterdayWater > 0) {
      insights.push({
        type: 'success',
        title: 'Improving Hydration',
        message: `Your water intake increased by ${((todayWater - yesterdayWater) / 1000).toFixed(1)}L compared to yesterday.`,
        priority: 'low'
      });
    }

    // Sleep insights
    if (sleepToday) {
      if (sleepToday.hours >= 8) {
        insights.push({
          type: 'success',
          title: 'Excellent Sleep',
          message: `You slept ${sleepToday.hours} hours of ${sleepToday.quality} quality sleep. Perfect!`,
          icon: 'dark_mode',
          priority: 'high'
        });
      } else if (sleepToday.hours >= 7) {
        insights.push({
          type: 'info',
          title: 'Good Sleep Quality',
          message: `${sleepToday.hours} hours of ${sleepToday.quality} sleep is great. Try for 8 hours tonight.`,
          icon: 'dark_mode',
          priority: 'medium'
        });
      } else if (sleepToday.hours > 0) {
        insights.push({
          type: 'warning',
          title: 'Sleep Deficit',
          message: `You only slept ${sleepToday.hours} hours. Aim for at least 7-8 hours.`,
          icon: 'dark_mode',
          priority: 'high'
        });
      }
    }

    // Sleep improvement
    if (sleepToday && sleepYesterday && sleepToday.hours > sleepYesterday.hours) {
      insights.push({
        type: 'success',
        title: 'Sleep Improvement',
        message: `Great work! You slept ${(sleepToday.hours - sleepYesterday.hours).toFixed(1)} more hours than yesterday.`,
        priority: 'low'
      });
    }

    // Weekly trends
    if (hydrationWeekly.length > 1) {
      const avgWeeklyWater = hydrationWeekly.reduce((sum, day) => sum + (day.total || 0), 0) / hydrationWeekly.length;
      if (todayWater > avgWeeklyWater * 1.1) {
        insights.push({
          type: 'success',
          title: 'Above Weekly Average',
          message: `Your water intake today exceeds your weekly average by 10%!`,
          priority: 'low'
        });
      }
    }

    res.json({
      insights: insights.sort((a, b) => {
        const priorityMap = { high: 0, medium: 1, low: 2 };
        return priorityMap[a.priority] - priorityMap[b.priority];
      }),
      metrics: {
        todayWater,
        yesterdayWater,
        todaySleep: sleepToday?.hours || 0,
        yesterdaySleep: sleepYesterday?.hours || 0,
        weeklyHydrationAverage: hydrationWeekly.length > 0 ? 
          Math.round(hydrationWeekly.reduce((sum, day) => sum + (day.total || 0), 0) / hydrationWeekly.length) : 0,
        weeklySleepAverage: sleepWeekly.length > 0 ?
          parseFloat((sleepWeekly.reduce((sum, day) => sum + (day.avg_hours || 0), 0) / sleepWeekly.length).toFixed(1)) : 0
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// POST /api/analytics/coach-response
// Save coach chatbot responses to database
router.post('/coach-response', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const { questionId, selectedOption, answer } = req.body;

  if (!questionId || !selectedOption) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    // Create table if it doesn't exist
    db.exec(`
      CREATE TABLE IF NOT EXISTS coach_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        question_id INTEGER NOT NULL,
        selected_option TEXT NOT NULL,
        answer TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    `);

    // Insert response
    const stmt = db.prepare(`
      INSERT INTO coach_responses (user_id, question_id, selected_option, answer)
      VALUES (?, ?, ?, ?)
    `);
    stmt.run(userId, questionId, selectedOption, answer);

    console.log(`[Coach] Saved response for user ${userId}: Q${questionId} -> ${selectedOption}`);

    res.json({ 
      success: true, 
      message: 'Coach response saved',
      questionId,
      selectedOption
    });
  } catch (err) {
    console.error('[Coach] Error saving response:', err);
    res.status(500).json({ error: 'Failed to save response' });
  }
});

// GET /api/analytics/coach-responses
// Get all coach responses for a user
router.get('/coach-responses', authMiddleware, (req, res) => {
  const userId = req.user.sub;

  try {
    const responses = db.prepare(`
      SELECT * FROM coach_responses 
      WHERE user_id = ? 
      ORDER BY created_at DESC
    `).all(userId);

    res.json({ 
      success: true,
      count: responses.length,
      responses
    });
  } catch (err) {
    console.error('[Coach] Error fetching responses:', err);
    res.status(500).json({ error: 'Failed to fetch responses' });
  }
});

module.exports = router;
