const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');
const { calcQuote } = require('../../utils/pricing');
const { checkAvailability } = require('../../utils/inventory');

const router = express.Router();

router.post('/', authRequired, (req, res) => {
  const { vehicleId, pickupLocationId, pickupAt, returnAt, insurance, couponCode } = req.body || {};
  if (!vehicleId || !pickupLocationId || !pickupAt || !returnAt) {
    return res.status(400).json({ error: '缺少报价参数', code: 400 });
  }

  const vehicle = db.prepare('SELECT * FROM vehicles WHERE id = ?').get(vehicleId);
  if (!vehicle) return res.status(404).json({ error: '车型不存在', code: 404 });

  const avail = checkAvailability(vehicleId, pickupLocationId, pickupAt, returnAt);
  if (!avail.ok) {
    return res.status(409).json({
      error: '所选日期库存不足',
      code: 409,
      unavailable: avail.unavailable,
    });
  }

  let couponDiscount = 0;
  if (couponCode) {
    const coupon = db.prepare('SELECT * FROM coupons WHERE code = ?').get(couponCode);
    if (coupon) couponDiscount = coupon.discount;
  }

  const quote = calcQuote({
    dailyRate: vehicle.daily_rate,
    hourlyRate: vehicle.hourly_rate,
    pickupAt,
    returnAt,
    insurance: insurance || 'none',
    couponDiscount,
  });
  if (quote.error) return res.status(400).json({ error: quote.error, code: 400 });

  res.json({
    quote: {
      ...quote,
      vehicle_id: vehicleId,
      deposit: vehicle.deposit,
      pickup_at: pickupAt,
      return_at: returnAt,
    },
  });
});

module.exports = router;
