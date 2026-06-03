const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (_req, res) => {
  const items = db
    .prepare(`SELECT * FROM coupons WHERE expires_at >= date('now') ORDER BY discount DESC`)
    .all()
    .map((c) => ({
      id: c.id,
      code: c.code,
      title: c.title,
      discount: c.discount,
      min_amount: c.min_amount,
      expires_at: c.expires_at,
    }));
  res.json({ items });
});

module.exports = router;
