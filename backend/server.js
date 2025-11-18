require('dotenv').config();
const express = require('express');
const cors = require("cors");
const app = express();
const port = process.env.PORT || 4000;
const path = require('path');
const userRoutes = require('./routes/users');

// DB
const db = require('./db/database');

// Routes
const authRoutes = require('./routes/auth');
const diseaseRoutes = require('./routes/disease');
const mealplanRoutes = require('./routes/mealplan');
const analyticsRoutes = require('./routes/analytics');

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static file serving for uploads
app.use('/static', express.static(path.join(__dirname, 'uploads')));

// ------------ AUTH ROUTES -------------
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/disease', diseaseRoutes);
app.use('/api/mealplan', mealplanRoutes);
app.use('/api/analytics', analyticsRoutes);

// ------------ HEALTH CHECK -------------
app.get('/', (req, res) => {
  res.json({
    ok: true,
    message: 'Backend is running!',
    time: new Date().toISOString()
  });
});

// ------------ SAMPLE ROUTE (meals) -------------
app.get('/api/meals', (req, res) => {
  try {
    const tags = req.query.tags; // comma-separated or single
    if (tags) {
      // use first tag for a simple LIKE filter
      const t = (Array.isArray(tags) ? tags[0] : tags).toString();
      const rows = db.prepare('SELECT id, title, calories, protein, carbs, fat, tags FROM meals WHERE tags LIKE ? LIMIT 200').all(`%${t}%`);
      return res.json(rows);
    }
    const rows = db.prepare('SELECT id, title, calories, protein, carbs, fat, tags FROM meals LIMIT 200').all();
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// ------------ SERVER LISTEN -------------
app.listen(port, () => {
  console.log(`Backend server running at http://localhost:${port}`);
});
