const { test, before, after, describe } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');

const dbPath = path.join(__dirname, '..', 'data', `car-test-${process.pid}.db`);

async function callApp(app, method, url, { token, body } = {}) {
  return new Promise((resolve, reject) => {
    const server = app.listen(0, () => {
      const { port } = server.address();
      const http = require('http');
      const payload = body ? JSON.stringify(body) : null;
      const req = http.request(
        {
          hostname: '127.0.0.1',
          port,
          path: url,
          method,
          headers: {
            'Content-Type': 'application/json',
            ...(token ? { Authorization: `Bearer ${token}` } : {}),
            ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
          },
        },
        (res) => {
          let raw = '';
          res.on('data', (c) => (raw += c));
          res.on('end', () => {
            server.close();
            resolve({
              status: res.statusCode,
              body: raw ? JSON.parse(raw) : null,
            });
          });
        }
      );
      req.on('error', (e) => {
        server.close();
        reject(e);
      });
      if (payload) req.write(payload);
      req.end();
    });
  });
}

function resetDb() {
  try {
    const dbModulePath = require.resolve('../src/db');
    if (require.cache[dbModulePath]) {
      require.cache[dbModulePath].exports.close();
      delete require.cache[dbModulePath];
    }
  } catch (_) {
    // ignore
  }
  [
    '../src/seed',
    '../src/index',
    '../src/utils/inventory',
    '../src/routes/api/orders',
  ].forEach((p) => delete require.cache[require.resolve(p)]);
  if (fs.existsSync(dbPath)) {
    try {
      fs.unlinkSync(dbPath);
    } catch (_) {
      // Windows lock
    }
  }
}

describe('Car Rental API', () => {
  let app;
  let token;
  let vehicleId;
  let locationId;

  before(() => {
    process.env.CAR_DB_PATH = dbPath;
    resetDb();
    const { seed } = require('../src/seed');
    seed();
    app = require('../src/index');

    const db = require('../src/db');
    vehicleId = db.prepare('SELECT id FROM vehicles LIMIT 1').get().id;
    locationId = db.prepare('SELECT id FROM locations LIMIT 1').get().id;
  });

  after(() => {
    try {
      require('../src/db').close();
    } catch (_) {
      // ignore
    }
    delete require.cache[require.resolve('../src/db')];
    delete require.cache[require.resolve('../src/index')];
    try {
      if (fs.existsSync(dbPath)) fs.unlinkSync(dbPath);
    } catch (_) {
      // ignore
    }
  });

  test('login default user', async () => {
    const res = await callApp(app, 'POST', '/api/auth/login', {
      body: { phone: '13800138000', password: '123456' },
    });
    assert.equal(res.status, 200);
    token = res.body.token;
  });

  test('license intercept blocks order', async () => {
    const res = await callApp(app, 'POST', '/api/orders', {
      token,
      body: {
        vehicleId,
        pickupLocationId: locationId,
        returnLocationId: locationId,
        pickupAt: '2030-06-01T10:00:00',
        returnAt: '2030-06-02T10:00:00',
      },
    });
    assert.equal(res.status, 403);
    assert.match(res.body.error, /驾照/);
  });

  function ensureStock(db, vid, lid, startIso, endIso, stock = 5) {
    const { datesForRental } = require('../src/utils/inventory');
    for (const date of datesForRental(startIso, endIso)) {
      db.prepare(
        'UPDATE inventory SET stock = ?, locked = 0 WHERE vehicle_id = ? AND location_id = ? AND date = ?'
      ).run(stock, vid, lid, date);
    }
  }

  test('inventory lock prevents double booking', async () => {
    await callApp(app, 'POST', '/api/license/approve-mock', { token });
    const { addDaysFromToday } = require('../src/utils/date');
    const day = addDaysFromToday(10);
    const pickupAt = `${day}T10:00:00`;
    const returnAt = `${day}T18:00:00`;

    const db = require('../src/db');
    ensureStock(db, vehicleId, locationId, pickupAt, returnAt, 1);

    const o1 = await callApp(app, 'POST', '/api/orders', {
      token,
      body: {
        vehicleId,
        pickupLocationId: locationId,
        returnLocationId: locationId,
        pickupAt,
        returnAt,
      },
    });
    assert.equal(o1.status, 201);

    const inv = db
      .prepare(
        'SELECT stock, locked FROM inventory WHERE vehicle_id = ? AND location_id = ? AND date = ?'
      )
      .get(vehicleId, locationId, day);
    assert.equal(inv.locked, 1);

    const o2 = await callApp(app, 'POST', '/api/orders', {
      token,
      body: {
        vehicleId,
        pickupLocationId: locationId,
        returnLocationId: locationId,
        pickupAt,
        returnAt,
      },
    });
    assert.equal(o2.status, 409);
    await callApp(app, 'POST', `/api/orders/${o1.body.order.id}/cancel`, { token });
  });

  test('cancel penalty within 24h before pickup', async () => {
    await callApp(app, 'POST', '/api/license/approve-mock', { token });

    const pickupAt = new Date(Date.now() + 12 * 60 * 60 * 1000).toISOString().slice(0, 19);
    const returnAt = new Date(Date.now() + 36 * 60 * 60 * 1000).toISOString().slice(0, 19);
    const db = require('../src/db');
    const vehicle2 = db.prepare('SELECT id FROM vehicles LIMIT 1 OFFSET 1').get().id;
    ensureStock(db, vehicle2, locationId, pickupAt, returnAt, 5);

    const created = await callApp(app, 'POST', '/api/orders', {
      token,
      body: {
        vehicleId: vehicle2,
        pickupLocationId: locationId,
        returnLocationId: locationId,
        pickupAt,
        returnAt,
      },
    });
    assert.equal(created.status, 201);
    const orderId = created.body.order.id;
    const total = created.body.order.total_amount;

    await callApp(app, 'POST', `/api/orders/${orderId}/pay`, { token });

    const cancelled = await callApp(app, 'POST', `/api/orders/${orderId}/cancel`, { token });
    assert.equal(cancelled.status, 200);
    assert.equal(cancelled.body.order.status, 'cancelled');
    assert.ok(cancelled.body.order.cancel_fee >= total * 0.19);
    assert.ok(cancelled.body.order.refund_amount <= total * 0.81 + 0.01);
  });
});
