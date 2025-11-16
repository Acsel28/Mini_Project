require('dotenv').config();
const usersRoute = require('./routes/users');
const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 4000;
const path = require('path');


app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(cors({ origin: true, credentials: true })); 
// static for uploads (secure in prod!)
app.use('/static', express.static(path.join(__dirname, 'uploads')));

// routes
try {
  console.log('Loading auth route...');
  const authRoute = require('./routes/auth');
  console.log('Auth route loaded:', typeof authRoute);
  app.use('/api/auth', authRoute);  
} catch (e) {
  console.error('Error loading auth route:', e.message);
  throw e;
}
try {
  console.log('Loading users route...');
  const usersRoute = require('./routes/users');
  console.log('Users route loaded:', typeof usersRoute);
  app.use('/api/users', usersRoute);
} catch (e) {
  console.error('Error loading users route:', e.message);
  throw e;
}
try {
  console.log('Loading meals route...');
  const mealsRoute = require('./routes/meals');
  console.log('Meals route loaded:', typeof mealsRoute);
  app.use('/api/meals', mealsRoute);
} catch (e) {
  console.error('Error loading meals route:', e.message);
  throw e;
}
try {
  console.log('Loading recipes route...');
  const recipesRoute = require('./routes/recipes');
  console.log('Recipes route loaded:', typeof recipesRoute);
  app.use('/api/recipes', recipesRoute);
} catch (e) {
  console.error('Error loading recipes route:', e.message);
  throw e;
}
try {
  console.log('Loading exercises route...');
  const exercisesRoute = require('./routes/exercises');
  console.log('Exercises route loaded:', typeof exercisesRoute);
  app.use('/api/exercises', exercisesRoute);
} catch (e) {
  console.error('Error loading exercises route:', e.message);
  throw e;
}
try {
  console.log('Loading images route...');
  const imagesRoute = require('./routes/images');
  console.log('Images route loaded:', typeof imagesRoute);
  app.use('/api/images', imagesRoute);
} catch (e) {
  console.error('Error loading images route:', e.message);
  throw e;
}

app.get('/', (req, res) => res.json({ ok: true, time: new Date().toISOString() }));

app.listen(port, () => {
  console.log(`API running on http://localhost:${port}`);
});
