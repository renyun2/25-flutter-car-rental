const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const items = db
    .prepare('SELECT * FROM invoices WHERE user_id = ? ORDER BY created_at DESC')
    .all(req.user.id)
    .map(mapInvoice);
  res.json({ items });
});

router.post('/', authRequired, (req, res) => {
  const { orderId, title, taxNo, amount } = req.body || {};
  if (!title) return res.status(400).json({ error: '请填写发票抬头', code: 400 });

  let amt = amount;
  if (orderId) {
    const order = db
      .prepare('SELECT total_amount FROM orders WHERE id = ? AND user_id = ?')
      .get(orderId, req.user.id);
    if (!order) return res.status(404).json({ error: '订单不存在', code: 404 });
    amt = order.total_amount;
  }
  if (!amt) return res.status(400).json({ error: '缺少金额', code: 400 });

  const id = uuid();
  db.prepare(
    'INSERT INTO invoices (id, user_id, order_id, amount, title, tax_no, status) VALUES (?,?,?,?,?,?,?)'
  ).run(id, req.user.id, orderId || null, amt, title, taxNo || '', 'pending');

  res.status(201).json({ invoice: mapInvoice(db.prepare('SELECT * FROM invoices WHERE id = ?').get(id)) });
});

function mapInvoice(i) {
  return {
    id: i.id,
    order_id: i.order_id,
    amount: i.amount,
    title: i.title,
    tax_no: i.tax_no,
    status: i.status,
    created_at: i.created_at,
  };
}

module.exports = router;
