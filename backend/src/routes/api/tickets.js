const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const items = db
    .prepare('SELECT * FROM tickets WHERE user_id = ? ORDER BY updated_at DESC')
    .all(req.user.id)
    .map(mapTicket);
  res.json({ items });
});

router.get('/:id', authRequired, (req, res) => {
  const t = db
    .prepare('SELECT * FROM tickets WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!t) return res.status(404).json({ error: '工单不存在', code: 404 });
  res.json({ ticket: mapTicket(t) });
});

router.post('/', authRequired, (req, res) => {
  const { subject, content } = req.body || {};
  if (!subject || !content) {
    return res.status(400).json({ error: '请填写主题和内容', code: 400 });
  }
  const id = uuid();
  db.prepare(
    'INSERT INTO tickets (id, user_id, subject, content, status) VALUES (?,?,?,?,?)'
  ).run(id, req.user.id, subject, content, 'open');
  res.status(201).json({ ticket: mapTicket(db.prepare('SELECT * FROM tickets WHERE id = ?').get(id)) });
});

router.patch('/:id', authRequired, (req, res) => {
  const t = db
    .prepare('SELECT * FROM tickets WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!t) return res.status(404).json({ error: '工单不存在', code: 404 });
  const { status, content } = req.body || {};
  if (status) {
    db.prepare(
      `UPDATE tickets SET status = ?, updated_at = datetime('now') WHERE id = ?`
    ).run(status, t.id);
  }
  if (content) {
    db.prepare(
      `UPDATE tickets SET content = ?, updated_at = datetime('now') WHERE id = ?`
    ).run(content, t.id);
  }
  res.json({ ticket: mapTicket(db.prepare('SELECT * FROM tickets WHERE id = ?').get(t.id)) });
});

router.delete('/:id', authRequired, (req, res) => {
  const r = db
    .prepare('DELETE FROM tickets WHERE id = ? AND user_id = ?')
    .run(req.params.id, req.user.id);
  if (r.changes === 0) return res.status(404).json({ error: '工单不存在', code: 404 });
  res.json({ ok: true });
});

function mapTicket(t) {
  return {
    id: t.id,
    subject: t.subject,
    content: t.content,
    status: t.status,
    created_at: t.created_at,
    updated_at: t.updated_at,
  };
}

module.exports = router;
