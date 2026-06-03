const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

function seedViolationsIfNeeded(userId) {
  const count = db.prepare('SELECT COUNT(*) AS c FROM violations WHERE user_id = ?').get(userId).c;
  if (count > 0) return;
  const order = db
    .prepare(`SELECT id FROM orders WHERE user_id = ? AND status = 'completed' LIMIT 1`)
    .get(userId);
  db.prepare(
    `INSERT INTO violations (id, order_id, user_id, plate, amount, status, description, occurred_at, location)
     VALUES (?,?,?,?,?,?,?,?,?)`
  ).run(
    uuid(),
    order?.id || null,
    userId,
    '京A12345',
    200,
    'unpaid',
    '超速行驶',
    '2025-05-10T14:00:00',
    '北京市朝阳区'
  );
}

router.get('/', authRequired, (req, res) => {
  seedViolationsIfNeeded(req.user.id);
  const items = db
    .prepare('SELECT * FROM violations WHERE user_id = ? ORDER BY occurred_at DESC')
    .all(req.user.id)
    .map((v) => ({
      id: v.id,
      order_id: v.order_id,
      plate: v.plate,
      amount: v.amount,
      status: v.status,
      description: v.description,
      occurred_at: v.occurred_at,
      location: v.location,
    }));
  res.json({ items });
});

router.get('/:id', authRequired, (req, res) => {
  const v = db
    .prepare('SELECT * FROM violations WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!v) return res.status(404).json({ error: '记录不存在', code: 404 });
  res.json({
    violation: {
      id: v.id,
      order_id: v.order_id,
      plate: v.plate,
      amount: v.amount,
      status: v.status,
      description: v.description,
      occurred_at: v.occurred_at,
      location: v.location,
    },
  });
});

module.exports = router;
