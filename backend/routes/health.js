const express = require('express');
const { v4: uuidv4 } = require('uuid');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth_mw');
const db = require('../db/database');

const WATER_GOAL_ML = 3000;
const SLEEP_GOAL_HOURS = 8;
const DEFAULT_CHECKLIST = [
  'Drank 2L water',
  'Ate 5 servings of veggies',
  'Slept 7+ hours',
  'Walked 8,000+ steps',
];

db.exec(`
  CREATE TABLE IF NOT EXISTS health_checklist_items (
    user_id TEXT NOT NULL,
    label TEXT NOT NULL,
    date TEXT NOT NULL,
    done INTEGER DEFAULT 0,
    PRIMARY KEY (user_id, label, date),
    FOREIGN KEY(user_id) REFERENCES users(id)
  )
`);

function todayDate() {
  return new Date().toISOString().split('T')[0];
}

function currentTime() {
  return new Date().toISOString().split('T')[1];
}

function mapChecklistRows(rows) {
  const map = new Map(rows.map((row) => [row.label, Boolean(row.done)]));
  return DEFAULT_CHECKLIST.map((label) => ({
    label,
    done: map.get(label) || false,
  }));
}

router.post('/hydration', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const amount = parseInt(req.body?.amount, 10);

  if (!Number.isFinite(amount) || amount <= 0) {
    return res.status(400).json({ error: 'Amount in ml is required' });
  }

  try {
    const id = uuidv4();
    const date = todayDate();
    const time = currentTime();

    db.prepare(
      `INSERT INTO hydration_logs (id, user_id, amount_ml, date, time, created_at)
       VALUES (?, ?, ?, ?, ?, ?)`
    ).run(id, userId, amount, date, time, Date.now());

    res.json({ status: 'ok', id, amount, date, time });
  } catch (err) {
    console.error('[Health] Hydration log error:', err);
    res.status(500).json({ error: 'Unable to log hydration' });
  }
});

router.get('/hydration-summary', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const date = todayDate();
  try {
    const logs = db
      .prepare(
        `SELECT id, amount_ml, time FROM hydration_logs
         WHERE user_id = ? AND date = ?
         ORDER BY time DESC`
      )
      .all(userId, date);

    const totalToday = logs.reduce((sum, log) => sum + (log.amount_ml || 0), 0);
    res.json({
      totalToday,
      goal: WATER_GOAL_ML,
      percentage: Math.min((totalToday / WATER_GOAL_ML) * 100, 100),
      logs: logs.map((log) => ({ id: log.id, amount: log.amount_ml, time: log.time })),
    });
  } catch (err) {
    console.error('[Health] Hydration summary error:', err);
    res.status(500).json({ error: 'Unable to fetch hydration summary' });
  }
});

router.post('/sleep', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const hours = Number(req.body?.hours);
  const quality = (req.body?.quality || 'good').toString();

  if (!Number.isFinite(hours) || hours <= 0) {
    return res.status(400).json({ error: 'Hours of sleep are required' });
  }

  try {
    const id = uuidv4();
    const date = todayDate();

    db.prepare(
      `INSERT INTO sleep_logs (id, user_id, hours, date, quality, created_at)
       VALUES (?, ?, ?, ?, ?, ?)`
    ).run(id, userId, hours, date, quality, Date.now());

    res.json({ status: 'ok', id, hours, quality, date });
  } catch (err) {
    console.error('[Health] Sleep log error:', err);
    res.status(500).json({ error: 'Unable to log sleep' });
  }
});

router.get('/sleep-summary', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const date = todayDate();
  try {
    const sleepRow = db
      .prepare(
        `SELECT id, hours, quality, created_at FROM sleep_logs
         WHERE user_id = ? AND date = ?
         ORDER BY created_at DESC
         LIMIT 1`
      )
      .get(userId, date);

    res.json({
      hours: sleepRow?.hours || 0,
      quality: sleepRow?.quality || 'not_logged',
      goalHours: SLEEP_GOAL_HOURS,
      lastLoggedAt: sleepRow?.created_at || null,
      message: sleepRow
        ? sleepRow.hours >= 7
          ? 'Great sleep! Maintain this rhythm tonight.'
          : 'Aim for a 7-8 hour sleep window tonight.'
        : 'No sleep has been logged for today yet.',
    });
  } catch (err) {
    console.error('[Health] Sleep summary error:', err);
    res.status(500).json({ error: 'Unable to fetch sleep summary' });
  }
});

router.get('/checklist', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const date = todayDate();
  try {
    const rows = db
      .prepare(
        `SELECT label, done FROM health_checklist_items
         WHERE user_id = ? AND date = ?`
      )
      .all(userId, date);
    res.json({ checklist: mapChecklistRows(rows) });
  } catch (err) {
    console.error('[Health] Checklist fetch error:', err);
    res.status(500).json({ error: 'Unable to fetch checklist' });
  }
});

router.post('/checklist', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const { label, done } = req.body || {};

  if (!label || typeof label !== 'string') {
    return res.status(400).json({ error: 'Checklist label is required' });
  }
  if (typeof done !== 'boolean') {
    return res.status(400).json({ error: 'Checklist status must be boolean' });
  }

  const normalizedLabel = DEFAULT_CHECKLIST.find((item) => item === label.trim());
  if (!normalizedLabel) {
    return res.status(400).json({ error: 'Invalid checklist label' });
  }

  try {
    const date = todayDate();
    db.prepare(
      `INSERT INTO health_checklist_items (user_id, label, date, done)
       VALUES (?, ?, ?, ?)
       ON CONFLICT(user_id, label, date)
       DO UPDATE SET done = excluded.done`
    ).run(userId, normalizedLabel, date, done ? 1 : 0);

    const rows = db
      .prepare(
        `SELECT label, done FROM health_checklist_items
         WHERE user_id = ? AND date = ?`
      )
      .all(userId, date);

    res.json({
      status: 'ok',
      checklist: mapChecklistRows(rows),
    });
  } catch (err) {
    console.error('[Health] Checklist update error:', err);
    res.status(500).json({ error: 'Unable to update checklist' });
  }
});

module.exports = router;
