const Database = require('better-sqlite3');
const fs = require('fs');
const path = require('path');

const dataDir = path.join(__dirname, '..', 'data');
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });

const dbPath = process.env.CAR_DB_PATH || path.join(dataDir, 'car.db');
const db = new Database(dbPath);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

function initSchema() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      phone TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      password TEXT NOT NULL DEFAULT '123456',
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS sessions (
      token TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS vehicles (
      id TEXT PRIMARY KEY,
      brand TEXT NOT NULL,
      model TEXT NOT NULL,
      seats INTEGER NOT NULL DEFAULT 5,
      transmission TEXT NOT NULL CHECK(transmission IN ('auto','manual')),
      fuel_type TEXT NOT NULL DEFAULT '汽油',
      daily_rate REAL NOT NULL,
      hourly_rate REAL NOT NULL,
      deposit REAL NOT NULL,
      image_url TEXT NOT NULL DEFAULT '',
      description TEXT NOT NULL DEFAULT ''
    );

    CREATE TABLE IF NOT EXISTS locations (
      id TEXT PRIMARY KEY,
      city TEXT NOT NULL,
      name TEXT NOT NULL,
      address TEXT NOT NULL DEFAULT ''
    );

    CREATE TABLE IF NOT EXISTS inventory (
      id TEXT PRIMARY KEY,
      vehicle_id TEXT NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
      location_id TEXT NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
      date TEXT NOT NULL,
      stock INTEGER NOT NULL DEFAULT 3,
      locked INTEGER NOT NULL DEFAULT 0,
      UNIQUE(vehicle_id, location_id, date)
    );

    CREATE TABLE IF NOT EXISTS licenses (
      user_id TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
      real_name TEXT NOT NULL DEFAULT '',
      id_number TEXT NOT NULL DEFAULT '',
      status TEXT NOT NULL DEFAULT 'none' CHECK(status IN ('none','pending','approved','rejected')),
      submitted_at TEXT,
      reviewed_at TEXT
    );

    CREATE TABLE IF NOT EXISTS orders (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id),
      vehicle_id TEXT NOT NULL REFERENCES vehicles(id),
      pickup_location_id TEXT NOT NULL REFERENCES locations(id),
      return_location_id TEXT NOT NULL REFERENCES locations(id),
      pickup_at TEXT NOT NULL,
      return_at TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending_payment',
      insurance TEXT NOT NULL DEFAULT 'none',
      rental_fee REAL NOT NULL,
      insurance_fee REAL NOT NULL DEFAULT 0,
      discount REAL NOT NULL DEFAULT 0,
      total_amount REAL NOT NULL,
      deposit REAL NOT NULL,
      pickup_code TEXT,
      cancel_fee REAL NOT NULL DEFAULT 0,
      refund_amount REAL NOT NULL DEFAULT 0,
      overtime_fee REAL NOT NULL DEFAULT 0,
      fuel_fee REAL NOT NULL DEFAULT 0,
      return_breakdown_json TEXT NOT NULL DEFAULT '[]',
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      paid_at TEXT,
      pickup_confirmed_at TEXT,
      returned_at TEXT
    );

    CREATE TABLE IF NOT EXISTS order_timeline (
      id TEXT PRIMARY KEY,
      order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
      status TEXT NOT NULL,
      note TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS inventory_locks (
      id TEXT PRIMARY KEY,
      order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
      vehicle_id TEXT NOT NULL,
      location_id TEXT NOT NULL,
      date TEXT NOT NULL,
      qty INTEGER NOT NULL DEFAULT 1
    );

    CREATE TABLE IF NOT EXISTS violations (
      id TEXT PRIMARY KEY,
      order_id TEXT REFERENCES orders(id),
      user_id TEXT NOT NULL REFERENCES users(id),
      plate TEXT NOT NULL DEFAULT '',
      amount REAL NOT NULL,
      status TEXT NOT NULL DEFAULT 'unpaid',
      description TEXT NOT NULL DEFAULT '',
      occurred_at TEXT NOT NULL,
      location TEXT NOT NULL DEFAULT ''
    );

    CREATE TABLE IF NOT EXISTS invoices (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id),
      order_id TEXT REFERENCES orders(id),
      amount REAL NOT NULL,
      title TEXT NOT NULL,
      tax_no TEXT NOT NULL DEFAULT '',
      status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS tickets (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id),
      subject TEXT NOT NULL,
      content TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'open',
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS coupons (
      id TEXT PRIMARY KEY,
      code TEXT NOT NULL UNIQUE,
      title TEXT NOT NULL,
      discount REAL NOT NULL,
      min_amount REAL NOT NULL DEFAULT 0,
      expires_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS messages (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id),
      title TEXT NOT NULL,
      body TEXT NOT NULL DEFAULT '',
      read INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );
  `);
}

initSchema();

module.exports = db;
