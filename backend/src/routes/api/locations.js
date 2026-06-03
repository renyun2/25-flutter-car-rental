const express = require('express');
const db = require('../../db');

const router = express.Router();

router.get('/', (req, res) => {
  const { city } = req.query;
  let items;
  if (city) {
    items = db
      .prepare('SELECT * FROM locations WHERE city = ? ORDER BY name')
      .all(city)
      .map(mapLoc);
  } else {
    items = db.prepare('SELECT * FROM locations ORDER BY city, name').all().map(mapLoc);
  }
  const cities = db.prepare('SELECT DISTINCT city FROM locations ORDER BY city').all();
  res.json({ items, cities: cities.map((c) => c.city) });
});

function mapLoc(l) {
  return {
    id: l.id,
    city: l.city,
    name: l.name,
    address: l.address,
  };
}

module.exports = router;
