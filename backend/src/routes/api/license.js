const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const lic = db.prepare('SELECT * FROM licenses WHERE user_id = ?').get(req.user.id);
  if (!lic) {
    return res.json({
      license: { status: 'none', real_name: '', id_number: '' },
    });
  }
  res.json({
    license: {
      status: lic.status,
      real_name: lic.real_name,
      id_number: lic.id_number,
      submitted_at: lic.submitted_at,
      reviewed_at: lic.reviewed_at,
    },
  });
});

router.post('/', authRequired, (req, res) => {
  const { realName, idNumber } = req.body || {};
  if (!realName || !idNumber) {
    return res.status(400).json({ error: '请填写姓名和证件号', code: 400 });
  }

  const existing = db.prepare('SELECT * FROM licenses WHERE user_id = ?').get(req.user.id);
  if (existing?.status === 'approved') {
    return res.status(400).json({ error: '已通过认证', code: 400 });
  }

  const status = 'pending';
  if (existing) {
    db.prepare(
      `UPDATE licenses SET real_name = ?, id_number = ?, status = ?, submitted_at = datetime('now'), reviewed_at = NULL
       WHERE user_id = ?`
    ).run(realName, idNumber, status, req.user.id);
  } else {
    db.prepare(
      `INSERT INTO licenses (user_id, real_name, id_number, status, submitted_at) VALUES (?,?,?,?,datetime('now'))`
    ).run(req.user.id, realName, idNumber, status);
  }

  setTimeout(() => {
    db.prepare(
      `UPDATE licenses SET status = 'approved', reviewed_at = datetime('now') WHERE user_id = ? AND status = 'pending'`
    ).run(req.user.id);
  }, 100);

  res.json({
    license: {
      status: 'pending',
      real_name: realName,
      id_number: idNumber,
      message: '已提交，Mock 审核将自动通过',
    },
  });
});

router.post('/approve-mock', authRequired, (req, res) => {
  db.prepare(
    `UPDATE licenses SET status = 'approved', reviewed_at = datetime('now') WHERE user_id = ?`
  ).run(req.user.id);
  res.json({ ok: true, status: 'approved' });
});

module.exports = router;
