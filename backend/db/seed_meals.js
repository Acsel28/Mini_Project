const Database = require('better-sqlite3');
const path = require('path');

const DB_FILE = process.env.DATABASE_FILE || path.join(__dirname, 'data.sqlite');
const db = new Database(DB_FILE);

const seedMeals = () => {
  const meals = [
    // BREAKFAST MEALS
    {
      id: 'meal_breakfast_1',
      title: 'Oatmeal with Berries',
      calories: 350,
      protein: 12,
      carbs: 58,
      fat: 8,
      ingredients_json: JSON.stringify(['oats', 'blueberries', 'honey', 'milk']),
      recipe_json: JSON.stringify(['Cook oats with milk', 'Top with berries and honey']),
      tags: 'breakfast,vegetarian,healthy,vegan-friendly'
    },
    {
      id: 'meal_breakfast_2',
      title: 'Scrambled Eggs with Toast',
      calories: 380,
      protein: 18,
      carbs: 32,
      fat: 18,
      ingredients_json: JSON.stringify(['eggs', 'whole_wheat_bread', 'butter', 'salt', 'pepper']),
      recipe_json: JSON.stringify(['Whisk eggs', 'Scramble in butter', 'Toast bread']),
      tags: 'breakfast,vegetarian,high-protein'
    },
    {
      id: 'meal_breakfast_3',
      title: 'Greek Yogurt Parfait',
      calories: 320,
      protein: 15,
      carbs: 48,
      fat: 6,
      ingredients_json: JSON.stringify(['greek_yogurt', 'granola', 'mixed_berries', 'honey']),
      recipe_json: JSON.stringify(['Layer yogurt', 'Add granola', 'Top with berries']),
      tags: 'breakfast,vegetarian,low-fat,healthy'
    },
    {
      id: 'meal_breakfast_4',
      title: 'Smoothie Bowl',
      calories: 340,
      protein: 14,
      carbs: 55,
      fat: 7,
      ingredients_json: JSON.stringify(['banana', 'berries', 'almond_milk', 'protein_powder', 'granola']),
      recipe_json: JSON.stringify(['Blend fruits with milk', 'Pour into bowl', 'Top with granola']),
      tags: 'breakfast,vegetarian,quick,healthy'
    },
    {
      id: 'meal_breakfast_5',
      title: 'Avocado Toast',
      calories: 400,
      protein: 14,
      carbs: 38,
      fat: 20,
      ingredients_json: JSON.stringify(['whole_grain_bread', 'avocado', 'egg', 'tomato', 'lemon']),
      recipe_json: JSON.stringify(['Toast bread', 'Mash avocado', 'Add egg', 'Top with tomato']),
      tags: 'breakfast,vegetarian,healthy-fats'
    },

    // LUNCH MEALS
    {
      id: 'meal_lunch_1',
      title: 'Grilled Chicken Salad',
      calories: 450,
      protein: 45,
      carbs: 28,
      fat: 12,
      ingredients_json: JSON.stringify(['chicken_breast', 'mixed_greens', 'cherry_tomatoes', 'cucumber', 'olive_oil']),
      recipe_json: JSON.stringify(['Grill chicken', 'Chop vegetables', 'Toss with dressing']),
      tags: 'lunch,high-protein,healthy,low-carb'
    },
    {
      id: 'meal_lunch_2',
      title: 'Vegetable Stir Fry',
      calories: 380,
      protein: 12,
      carbs: 52,
      fat: 10,
      ingredients_json: JSON.stringify(['broccoli', 'bell_peppers', 'tofu', 'brown_rice', 'soy_sauce']),
      recipe_json: JSON.stringify(['Cook rice', 'Stir fry vegetables', 'Add tofu', 'Combine']),
      tags: 'lunch,vegetarian,vegan,low-fat'
    },
    {
      id: 'meal_lunch_3',
      title: 'Turkey Sandwich',
      calories: 420,
      protein: 32,
      carbs: 42,
      fat: 12,
      ingredients_json: JSON.stringify(['turkey_breast', 'whole_wheat_bread', 'lettuce', 'tomato', 'cheese']),
      recipe_json: JSON.stringify(['Toast bread', 'Layer turkey', 'Add vegetables']),
      tags: 'lunch,high-protein,quick'
    },
    {
      id: 'meal_lunch_4',
      title: 'Quinoa Buddha Bowl',
      calories: 480,
      protein: 16,
      carbs: 62,
      fat: 14,
      ingredients_json: JSON.stringify(['quinoa', 'chickpeas', 'sweet_potato', 'kale', 'tahini']),
      recipe_json: JSON.stringify(['Cook quinoa', 'Roast vegetables', 'Assemble bowl']),
      tags: 'lunch,vegetarian,vegan,high-fiber'
    },
    {
      id: 'meal_lunch_5',
      title: 'Fish Tacos',
      calories: 420,
      protein: 38,
      carbs: 35,
      fat: 14,
      ingredients_json: JSON.stringify(['white_fish', 'corn_tortillas', 'cabbage', 'cilantro', 'lime']),
      recipe_json: JSON.stringify(['Grill fish', 'Warm tortillas', 'Assemble tacos']),
      tags: 'lunch,high-protein,seafood'
    },

    // DINNER MEALS
    {
      id: 'meal_dinner_1',
      title: 'Grilled Salmon with Vegetables',
      calories: 520,
      protein: 48,
      carbs: 32,
      fat: 18,
      ingredients_json: JSON.stringify(['salmon_fillet', 'asparagus', 'sweet_potato', 'lemon', 'olive_oil']),
      recipe_json: JSON.stringify(['Grill salmon', 'Roast vegetables', 'Combine']),
      tags: 'dinner,high-protein,omega-3,healthy'
    },
    {
      id: 'meal_dinner_2',
      title: 'Spaghetti with Marinara',
      calories: 480,
      protein: 18,
      carbs: 72,
      fat: 10,
      ingredients_json: JSON.stringify(['whole_wheat_pasta', 'tomato_sauce', 'garlic', 'basil', 'parmesan']),
      recipe_json: JSON.stringify(['Cook pasta', 'Warm sauce', 'Combine and garnish']),
      tags: 'dinner,vegetarian,comfort-food'
    },
    {
      id: 'meal_dinner_3',
      title: 'Lean Beef Stir Fry',
      calories: 510,
      protein: 50,
      carbs: 35,
      fat: 14,
      ingredients_json: JSON.stringify(['lean_beef', 'broccoli', 'bell_peppers', 'brown_rice', 'ginger']),
      recipe_json: JSON.stringify(['Slice beef', 'Stir fry', 'Cook rice', 'Combine']),
      tags: 'dinner,high-protein,low-fat'
    },
    {
      id: 'meal_dinner_4',
      title: 'Vegetable Curry with Rice',
      calories: 420,
      protein: 14,
      carbs: 62,
      fat: 12,
      ingredients_json: JSON.stringify(['chickpeas', 'spinach', 'coconut_milk', 'curry_spices', 'basmati_rice']),
      recipe_json: JSON.stringify(['Cook rice', 'Make curry sauce', 'Simmer vegetables']),
      tags: 'dinner,vegetarian,vegan,flavorful'
    },
    {
      id: 'meal_dinner_5',
      title: 'Grilled Chicken Breast with Quinoa',
      calories: 520,
      protein: 55,
      carbs: 42,
      fat: 12,
      ingredients_json: JSON.stringify(['chicken_breast', 'quinoa', 'green_beans', 'garlic', 'herbs']),
      recipe_json: JSON.stringify(['Grill chicken', 'Cook quinoa', 'Steam beans', 'Combine']),
      tags: 'dinner,high-protein,healthy,low-fat'
    },
  ];

  try {
    const insertStmt = db.prepare(`
      INSERT OR REPLACE INTO meals (id, title, calories, protein, carbs, fat, ingredients_json, recipe_json, tags) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    db.exec('BEGIN TRANSACTION');

    meals.forEach((meal) => {
      insertStmt.run(
        meal.id,
        meal.title,
        meal.calories,
        meal.protein,
        meal.carbs,
        meal.fat,
        meal.ingredients_json,
        meal.recipe_json,
        meal.tags
      );
      console.log(`✓ Inserted meal: ${meal.title}`);
    });

    db.exec('COMMIT');
    console.log('\n✓ Successfully seeded meals table with 15 meals');
    db.close();
    process.exit(0);
  } catch (err) {
    console.error('Error seeding meals:', err.message);
    db.close();
    process.exit(1);
  }
};

seedMeals();
