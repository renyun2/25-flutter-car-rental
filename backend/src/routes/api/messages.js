const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const items = db
    .prepare('SELECT * FROM messages WHERE user_id = ? ORDER BY created_at DESC')
    .all(req.user.id)
    .map((m) => ({
      id: m.id,
      title: m.title,
      body: m.body,
      read: m.read === 1,
      created_at: m.created_at,
    }));
  res.json({ items });
});

module.exports = router;
