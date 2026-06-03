const express = require('express');
const db = require('../../db');
const { dateRangeInclusive } = require('../../utils/date');

const router = express.Router();

router.get('/', (req, res) => {
  const { vehicleId, locationId, start, end } = req.query;
  if (!vehicleId || !locationId || !start || !end) {
    return res.status(400).json({ error: '缺少 vehicleId/locationId/start/end', code: 400 });
  }
  const dates = dateRangeInclusive(start, end);
  const rows = db
    .prepare(
      `SELECT date, stock, locked FROM inventory
       WHERE vehicle_id = ? AND location_id = ? AND date IN (${dates.map(() => '?').join(',')})`
    )
    .all(vehicleId, locationId, ...dates);

  const map = Object.fromEntries(rows.map((r) => [r.date, r]));
  const calendar = dates.map((date) => {
    const row = map[date];
    const available = row ? row.stock - row.locked > 0 : false;
    return { date, available, stock: row?.stock ?? 0, locked: row?.locked ?? 0 };
  });
  res.json({ calendar });
});

module.exports = router;
