// backend-mvp/routes/images.js
const express = require('express');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

/**
 * POST /api/images/scan
 * Accepts base64 image and returns placeholder nutrition/ingredient detection
 */
router.post('/scan', requireAuth, (req, res) => {
  const userId = req.user.id;
  const { base64Image } = req.body || {};

  if (!base64Image) {
    return res.status(400).json({ error: 'base64Image is required' });
  }

  console.log('Image scan request by:', userId);

  // Stub response — replace with ML model later
  return res.json({
    detected_items: ['rice', 'dal', 'roti'], 
    confidence: 0.92
  });
});

/**
 * (Optional) GET /api/images/test
 */
router.get('/test', requireAuth, (req, res) => {
  res.json({ message: 'image route working' });
});

module.exports = router;
