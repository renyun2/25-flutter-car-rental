const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');
const { calcQuote, calcCancelRefund } = require('../../utils/pricing');
const {
  checkAvailability,
  lockInventory,
  releaseInventory,
  releaseExpiredPendingOrders,
} = require('../../utils/inventory');

const router = express.Router();

function randomPickupCode() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

function getLicenseStatus(userId) {
  const lic = db.prepare('SELECT status FROM licenses WHERE user_id = ?').get(userId);
  return lic?.status || 'none';
}

function mapOrder(row) {
  const vehicle = db.prepare('SELECT brand, model, image_url FROM vehicles WHERE id = ?').get(row.vehicle_id);
  const pickupLoc = db.prepare('SELECT name, city FROM locations WHERE id = ?').get(row.pickup_location_id);
  const returnLoc = db.prepare('SELECT name, city FROM locations WHERE id = ?').get(row.return_location_id);
  const timeline = db
    .prepare('SELECT status, note, created_at FROM order_timeline WHERE order_id = ? ORDER BY created_at')
    .all(row.id);
  return {
    id: row.id,
    vehicle_id: row.vehicle_id,
    vehicle_name: vehicle ? `${vehicle.brand} ${vehicle.model}` : '',
    image_url: vehicle?.image_url || '',
    pickup_location_id: row.pickup_location_id,
    pickup_location_name: pickupLoc ? `${pickupLoc.city} ${pickupLoc.name}` : '',
    return_location_id: row.return_location_id,
    return_location_name: returnLoc ? `${returnLoc.city} ${returnLoc.name}` : '',
    pickup_at: row.pickup_at,
    return_at: row.return_at,
    status: row.status,
    insurance: row.insurance,
    rental_fee: row.rental_fee,
    insurance_fee: row.insurance_fee,
    discount: row.discount,
    total_amount: row.total_amount,
    deposit: row.deposit,
    pickup_code: row.pickup_code,
    cancel_fee: row.cancel_fee,
    refund_amount: row.refund_amount,
    overtime_fee: row.overtime_fee,
    fuel_fee: row.fuel_fee,
    return_breakdown: JSON.parse(row.return_breakdown_json || '[]'),
    created_at: row.created_at,
    paid_at: row.paid_at,
    timeline,
  };
}

function addTimeline(orderId, status, note) {
  db.prepare('INSERT INTO order_timeline (id, order_id, status, note) VALUES (?,?,?,?)').run(
    uuid(),
    orderId,
    status,
    note
  );
}

router.use((req, res, next) => {
  releaseExpiredPendingOrders();
  next();
});

router.get('/', authRequired, (req, res) => {
  const tab = req.query.tab || 'active';
  const activeStatuses = ['pending_payment', 'pending_pickup', 'in_use', 'pending_return'];
  let rows;
  if (tab === 'history') {
    rows = db
      .prepare(
        `SELECT * FROM orders WHERE user_id = ? AND status IN ('completed','cancelled') ORDER BY created_at DESC`
      )
      .all(req.user.id);
  } else {
    rows = db
      .prepare(
        `SELECT * FROM orders WHERE user_id = ? AND status IN (${activeStatuses.map(() => '?').join(',')}) ORDER BY created_at DESC`
      )
      .all(req.user.id, ...activeStatuses);
  }
  res.json({ items: rows.map(mapOrder) });
});

router.get('/:id', authRequired, (req, res) => {
  const row = db
    .prepare('SELECT * FROM orders WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!row) return res.status(404).json({ error: '订单不存在', code: 404 });
  res.json({ order: mapOrder(row) });
});

router.post('/', authRequired, (req, res) => {
  const licenseStatus = getLicenseStatus(req.user.id);
  if (licenseStatus !== 'approved') {
    return res.status(403).json({
      error: '驾照未通过认证，无法下单',
      code: 403,
      license_status: licenseStatus,
    });
  }

  const {
    vehicleId,
    pickupLocationId,
    returnLocationId,
    pickupAt,
    returnAt,
    insurance,
    couponCode,
  } = req.body || {};
  if (!vehicleId || !pickupLocationId || !returnLocationId || !pickupAt || !returnAt) {
    return res.status(400).json({ error: '缺少订单参数', code: 400 });
  }

  const vehicle = db.prepare('SELECT * FROM vehicles WHERE id = ?').get(vehicleId);
  if (!vehicle) return res.status(404).json({ error: '车型不存在', code: 404 });

  const avail = checkAvailability(vehicleId, pickupLocationId, pickupAt, returnAt);
  if (!avail.ok) {
    return res.status(409).json({ error: '库存不足', code: 409, unavailable: avail.unavailable });
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

  const orderId = uuid();
  try {
    const create = db.transaction(() => {
      db.prepare(
        `INSERT INTO orders (
          id, user_id, vehicle_id, pickup_location_id, return_location_id,
          pickup_at, return_at, status, insurance, rental_fee, insurance_fee,
          discount, total_amount, deposit, pickup_code
        ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`
      ).run(
        orderId,
        req.user.id,
        vehicleId,
        pickupLocationId,
        returnLocationId,
        pickupAt,
        returnAt,
        'pending_payment',
        insurance || 'none',
        quote.rentalFee,
        quote.insuranceFee,
        quote.discount,
        quote.total,
        vehicle.deposit,
        null
      );
      lockInventory(orderId, vehicleId, pickupLocationId, pickupAt, returnAt);
      addTimeline(orderId, 'pending_payment', '订单已创建，请在15分钟内完成支付');
    });
    create();
  } catch (e) {
    return res.status(409).json({ error: e.message || '锁定库存失败', code: 409 });
  }

  const order = mapOrder(db.prepare('SELECT * FROM orders WHERE id = ?').get(orderId));
  res.status(201).json({ order });
});

router.post('/:id/pay', authRequired, (req, res) => {
  const row = db
    .prepare('SELECT * FROM orders WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!row) return res.status(404).json({ error: '订单不存在', code: 404 });
  if (row.status !== 'pending_payment') {
    return res.status(400).json({ error: '订单状态不可支付', code: 400 });
  }

  const code = randomPickupCode();
  db.prepare(
    `UPDATE orders SET status = 'pending_pickup', pickup_code = ?, paid_at = datetime('now') WHERE id = ?`
  ).run(code, row.id);
  addTimeline(row.id, 'pending_pickup', `支付成功，取车码 ${code}`);
  res.json({ order: mapOrder(db.prepare('SELECT * FROM orders WHERE id = ?').get(row.id)) });
});

router.post('/:id/cancel', authRequired, (req, res) => {
  const row = db
    .prepare('SELECT * FROM orders WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!row) return res.status(404).json({ error: '订单不存在', code: 404 });
  if (!['pending_payment', 'pending_pickup'].includes(row.status)) {
    return res.status(400).json({ error: '当前状态不可取消', code: 400 });
  }

  let cancelFee = 0;
  let refundAmount = 0;
  if (row.status === 'pending_payment') {
    refundAmount = 0;
  } else {
    const calc = calcCancelRefund(row.total_amount, row.pickup_at);
    cancelFee = calc.penalty;
    refundAmount = calc.refund;
  }

  releaseInventory(row.id);
  db.prepare(
    `UPDATE orders SET status = 'cancelled', cancel_fee = ?, refund_amount = ? WHERE id = ?`
  ).run(cancelFee, refundAmount, row.id);
  addTimeline(row.id, 'cancelled', cancelFee > 0 ? `取消扣违约金 ${cancelFee}` : '订单已取消');
  res.json({ order: mapOrder(db.prepare('SELECT * FROM orders WHERE id = ?').get(row.id)) });
});

router.post('/:id/pickup', authRequired, (req, res) => {
  const row = db
    .prepare('SELECT * FROM orders WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!row) return res.status(404).json({ error: '订单不存在', code: 404 });
  if (row.status !== 'pending_pickup') {
    return res.status(400).json({ error: '订单状态不可取车', code: 400 });
  }

  db.prepare(
    `UPDATE orders SET status = 'in_use', pickup_confirmed_at = datetime('now') WHERE id = ?`
  ).run(row.id);
  addTimeline(row.id, 'in_use', '已取车，行程开始');
  res.json({ order: mapOrder(db.prepare('SELECT * FROM orders WHERE id = ?').get(row.id)) });
});

router.post('/:id/return', authRequired, (req, res) => {
  const row = db
    .prepare('SELECT * FROM orders WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!row) return res.status(404).json({ error: '订单不存在', code: 404 });
  if (row.status !== 'in_use' && row.status !== 'pending_return') {
    return res.status(400).json({ error: '订单状态不可还车', code: 400 });
  }

  const overtimeFee = 45;
  const fuelFee = 30;
  const breakdown = [
    { label: '租金', amount: row.rental_fee },
    { label: '保险', amount: row.insurance_fee },
    { label: '超时费', amount: overtimeFee },
    { label: '油费补差', amount: fuelFee },
  ];
  if (row.discount > 0) breakdown.push({ label: '优惠', amount: -row.discount });

  db.prepare(
    `UPDATE orders SET status = 'completed', overtime_fee = ?, fuel_fee = ?,
     return_breakdown_json = ?, returned_at = datetime('now') WHERE id = ?`
  ).run(overtimeFee, fuelFee, JSON.stringify(breakdown), row.id);
  addTimeline(row.id, 'completed', '还车结算完成');
  res.json({ order: mapOrder(db.prepare('SELECT * FROM orders WHERE id = ?').get(row.id)) });
});

module.exports = router;
