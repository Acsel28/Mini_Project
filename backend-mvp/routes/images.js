const express = require('express');
const router = express.Router();
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });
const { authMiddleware } = require('../middleware/auth_mw');
const { v4: uuidv4 } = require('uuid');
const db = require('../db/database');

router.post('/upload', authMiddleware, upload.single('file'), (req, res) => {
  const uid = req.user.sub;
  const file = req.file;
  const id = uuidv4();
  db.prepare('INSERT INTO uploads (id, user_id, path, type, created_at) VALUES (?,?,?,?,?)')
    .run(id, uid, file.path, file.mimetype, Math.floor(Date.now()/1000));
  // For MVP we return the file path which frontend can fetch from server (expose static route)
  res.json({ id, path: `/static/${file.filename}`, originalname: file.originalname });
});

module.exports = router;
