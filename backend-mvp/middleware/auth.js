// backend-mvp/middleware/auth.js
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret';

function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ')
    ? authHeader.slice(7)
    : null;

  if (!token) {
    return res.status(401).json({ error: 'no token' });
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET);

    // We assume when you created tokens, you used user id as `sub`
    // e.g. signAccess(userId) => { sub: userId, ... }
    const userId = payload.sub || payload.userId || payload.id;
    if (!userId) {
      return res.status(401).json({ error: 'invalid token payload' });
    }

    req.user = { id: userId };
    next();
  } catch (err) {
    console.error('Auth middleware error:', err);
    return res.status(401).json({ error: 'invalid token' });
  }
}

module.exports = { requireAuth };
