const express = require('express');
const db = require('../../db');

const router = express.Router();

router.get('/', (req, res) => {
  const { brand, seats, transmission, sort } = req.query;
  let sql = 'SELECT * FROM vehicles WHERE 1=1';
  const params = [];
  if (brand) {
    sql += ' AND brand = ?';
    params.push(brand);
  }
  if (seats) {
    sql += ' AND seats >= ?';
    params.push(Number(seats));
  }
  if (transmission) {
    sql += ' AND transmission = ?';
    params.push(transmission);
  }
  if (sort === 'price_asc') sql += ' ORDER BY daily_rate ASC';
  else if (sort === 'price_desc') sql += ' ORDER BY daily_rate DESC';
  else sql += ' ORDER BY brand, model';

  const items = db.prepare(sql).all(...params).map(mapVehicle);
  const brands = db.prepare('SELECT DISTINCT brand FROM vehicles ORDER BY brand').all();
  res.json({ items, brands: brands.map((b) => b.brand) });
});

router.get('/:id', (req, res) => {
  const row = db.prepare('SELECT * FROM vehicles WHERE id = ?').get(req.params.id);
  if (!row) return res.status(404).json({ error: '车型不存在', code: 404 });
  res.json({ vehicle: mapVehicle(row) });
});

function mapVehicle(v) {
  return {
    id: v.id,
    brand: v.brand,
    model: v.model,
    name: `${v.brand} ${v.model}`,
    seats: v.seats,
    transmission: v.transmission,
    fuel_type: v.fuel_type,
    daily_rate: v.daily_rate,
    hourly_rate: v.hourly_rate,
    deposit: v.deposit,
    image_url: v.image_url,
    description: v.description,
  };
}

module.exports = router;
