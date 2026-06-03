const db = require('../db');
const { dateRangeInclusive } = require('./date');

function datesForRental(pickupAt, returnAt) {
  const start = pickupAt.slice(0, 10);
  const end = returnAt.slice(0, 10);
  return dateRangeInclusive(start, end);
}

function checkAvailability(vehicleId, locationId, pickupAt, returnAt) {
  const dates = datesForRental(pickupAt, returnAt);
  const rows = db
    .prepare(
      `SELECT date, stock, locked FROM inventory
       WHERE vehicle_id = ? AND location_id = ? AND date IN (${dates.map(() => '?').join(',')})`
    )
    .all(vehicleId, locationId, ...dates);

  const map = Object.fromEntries(rows.map((r) => [r.date, r]));
  const unavailable = [];
  for (const d of dates) {
    const row = map[d];
    const available = row ? row.stock - row.locked : 0;
    if (available < 1) unavailable.push(d);
  }
  return { ok: unavailable.length === 0, unavailable, dates };
}

function lockInventory(orderId, vehicleId, locationId, pickupAt, returnAt) {
  const dates = datesForRental(pickupAt, returnAt);
  const lock = db.transaction(() => {
    for (const date of dates) {
      const row = db
        .prepare(
          'SELECT id, stock, locked FROM inventory WHERE vehicle_id = ? AND location_id = ? AND date = ?'
        )
        .get(vehicleId, locationId, date);
      if (!row || row.stock - row.locked < 1) {
        throw new Error(`库存不足: ${date}`);
      }
      db.prepare('UPDATE inventory SET locked = locked + 1 WHERE id = ?').run(row.id);
      db.prepare(
        'INSERT INTO inventory_locks (id, order_id, vehicle_id, location_id, date, qty) VALUES (?,?,?,?,?,1)'
      ).run(
        require('uuid').v4(),
        orderId,
        vehicleId,
        locationId,
        date
      );
    }
  });
  lock();
}

function releaseInventory(orderId) {
  const locks = db.prepare('SELECT * FROM inventory_locks WHERE order_id = ?').all(orderId);
  const release = db.transaction(() => {
    for (const l of locks) {
      const row = db
        .prepare(
          'SELECT id, locked FROM inventory WHERE vehicle_id = ? AND location_id = ? AND date = ?'
        )
        .get(l.vehicle_id, l.location_id, l.date);
      if (row && row.locked > 0) {
        db.prepare('UPDATE inventory SET locked = locked - 1 WHERE id = ?').run(row.id);
      }
    }
    db.prepare('DELETE FROM inventory_locks WHERE order_id = ?').run(orderId);
  });
  release();
}

function releaseExpiredPendingOrders() {
  const expired = db
    .prepare(
      `SELECT id FROM orders
       WHERE status = 'pending_payment'
       AND datetime(created_at) < datetime('now', '-15 minutes')`
    )
    .all();
  for (const o of expired) {
    releaseInventory(o.id);
    db.prepare(
      `UPDATE orders SET status = 'cancelled', cancel_fee = 0, refund_amount = 0 WHERE id = ?`
    ).run(o.id);
    db.prepare(
      'INSERT INTO order_timeline (id, order_id, status, note) VALUES (?,?,?,?)'
    ).run(require('uuid').v4(), o.id, 'cancelled', '超时未支付，库存已释放');
  }
  return expired.length;
}

module.exports = {
  datesForRental,
  checkAvailability,
  lockInventory,
  releaseInventory,
  releaseExpiredPendingOrders,
};
