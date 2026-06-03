const { v4: uuid } = require('uuid');
const db = require('./db');
const { addDays, todayStr } = require('./utils/date');

const BRANDS = [
  { brand: '大众', models: ['朗逸', '帕萨特', '途观'], seats: [5, 5, 5] },
  { brand: '丰田', models: ['卡罗拉', '凯美瑞', 'RAV4'], seats: [5, 5, 5] },
  { brand: '本田', models: ['思域', '雅阁', 'CR-V'], seats: [5, 5, 5] },
  { brand: '别克', models: ['英朗', '君威', 'GL8'], seats: [5, 5, 7] },
  { brand: '宝马', models: ['3系', '5系', 'X3'], seats: [5, 5, 5] },
  { brand: '奔驰', models: ['C级', 'E级', 'GLC'], seats: [5, 5, 5] },
  { brand: '奥迪', models: ['A4L', 'A6L', 'Q5L'], seats: [5, 5, 5] },
  { brand: '比亚迪', models: ['秦PLUS', '汉', '宋PLUS'], seats: [5, 5, 5] },
  { brand: '特斯拉', models: ['Model 3', 'Model Y'], seats: [5, 5] },
  { brand: '日产', models: ['轩逸', '天籁', '奇骏'], seats: [5, 5, 5] },
];

const CITIES = ['北京', '上海', '广州', '深圳', '杭州', '成都', '武汉', '西安'];

function seed() {
  const count = db.prepare('SELECT COUNT(*) AS c FROM users').get().c;
  if (count > 0) return;

  const userId = uuid();
  db.prepare('INSERT INTO users (id, phone, name, password) VALUES (?,?,?,?)').run(
    userId,
    '13800138000',
    '租车用户',
    '123456'
  );
  db.prepare(
    'INSERT INTO licenses (user_id, real_name, id_number, status) VALUES (?,?,?,?)'
  ).run(userId, '', '', 'none');

  const insertVehicle = db.prepare(
    `INSERT INTO vehicles (id, brand, model, seats, transmission, fuel_type, daily_rate, hourly_rate, deposit, image_url, description)
     VALUES (?,?,?,?,?,?,?,?,?,?,?)`
  );
  const vehicleIds = [];
  let vi = 0;
  BRANDS.forEach((b) => {
    b.models.forEach((model, mi) => {
      vi += 1;
      const id = uuid();
      vehicleIds.push(id);
      const seats = b.seats[mi] || 5;
      const transmission = vi % 3 === 0 ? 'manual' : 'auto';
      const daily = 180 + (vi % 8) * 40;
      const hourly = Math.round((daily / 8) * 10) / 10;
      insertVehicle.run(
        id,
        b.brand,
        model,
        seats,
        transmission,
        b.brand === '比亚迪' || b.brand === '特斯拉' ? '纯电' : '汽油',
        daily,
        hourly,
        daily * 2,
        `https://pics.example/car/${vi}.jpg`,
        `${b.brand} ${model}，${transmission === 'auto' ? '自动挡' : '手动挡'}，${seats}座`
      );
    });
  });

  const insertLoc = db.prepare(
    'INSERT INTO locations (id, city, name, address) VALUES (?,?,?,?)'
  );
  const locationIds = [];
  CITIES.forEach((city, ci) => {
    for (let i = 0; i < 2; i += 1) {
      const id = uuid();
      locationIds.push({ id, city });
      insertLoc.run(id, city, `${city}取还车点${i + 1}`, `${city}市租车路${100 + ci * 10 + i}号`);
    }
  });

  const insertInv = db.prepare(
    'INSERT INTO inventory (id, vehicle_id, location_id, date, stock, locked) VALUES (?,?,?,?,?,?)'
  );
  const start = todayStr();
  vehicleIds.forEach((vid, vidx) => {
    locationIds.forEach((loc, lidx) => {
      for (let d = 0; d < 30; d += 1) {
        const date = addDays(start, d);
        const stock = 2 + ((vidx + lidx + d) % 3);
        const locked = d === 5 && vidx === 0 && lidx === 0 ? 2 : 0;
        insertInv.run(uuid(), vid, loc.id, date, stock, locked);
      }
    });
  });

  const insertCoupon = db.prepare(
    'INSERT INTO coupons (id, code, title, discount, min_amount, expires_at) VALUES (?,?,?,?,?,?)'
  );
  insertCoupon.run(uuid(), 'NEW50', '新用户立减50', 50, 200, addDays(start, 90));
  insertCoupon.run(uuid(), 'VIP30', '会员减30', 30, 150, addDays(start, 60));

  db.prepare(
    'INSERT INTO messages (id, user_id, title, body, read) VALUES (?,?,?,?,?)'
  ).run(uuid(), userId, '欢迎使用共享租车', '完成驾照认证后可下单取车。', 0);

  console.log(
    `Car rental seed: ${vehicleIds.length} vehicles, ${locationIds.length} locations, 30-day inventory`
  );
}

module.exports = { seed };
