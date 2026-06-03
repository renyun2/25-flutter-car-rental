const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.post('/login', (req, res) => {
  const { phone, password } = req.body || {};
  if (!phone || !password) {
    return res.status(400).json({ error: '请输入手机号和密码', code: 400 });
  }
  const user = db
    .prepare('SELECT id, phone, name FROM users WHERE phone = ? AND password = ?')
    .get(phone, password);
  if (!user) return res.status(401).json({ error: '手机号或密码错误', code: 401 });

  const token = uuid();
  db.prepare('INSERT INTO sessions (token, user_id) VALUES (?, ?)').run(token, user.id);
  res.json({ token, user });
});

router.post('/register', (req, res) => {
  const { phone, password, name } = req.body || {};
  if (!phone || !password) {
    return res.status(400).json({ error: '请输入手机号和密码', code: 400 });
  }
  const exists = db.prepare('SELECT id FROM users WHERE phone = ?').get(phone);
  if (exists) return res.status(409).json({ error: '手机号已注册', code: 409 });

  const id = uuid();
  db.prepare('INSERT INTO users (id, phone, name, password) VALUES (?,?,?,?)').run(
    id,
    phone,
    name || `用户${phone.slice(-4)}`,
    password
  );
  db.prepare(
    'INSERT INTO licenses (user_id, real_name, id_number, status) VALUES (?,?,?,?)'
  ).run(id, '', '', 'none');

  const token = uuid();
  db.prepare('INSERT INTO sessions (token, user_id) VALUES (?, ?)').run(token, id);
  const user = { id, phone, name: name || `用户${phone.slice(-4)}` };
  res.status(201).json({ token, user });
});

router.get('/me', authRequired, (req, res) => {
  res.json({ user: req.user });
});

router.post('/logout', authRequired, (req, res) => {
  db.prepare('DELETE FROM sessions WHERE token = ?').run(req.token);
  res.json({ ok: true });
});

module.exports = router;
