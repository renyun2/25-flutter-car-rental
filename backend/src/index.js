const express = require('express');
const cors = require('cors');
const { seed } = require('./seed');
const { releaseExpiredPendingOrders } = require('./utils/inventory');

const authRoutes = require('./routes/api/auth');
const vehiclesRoutes = require('./routes/api/vehicles');
const locationsRoutes = require('./routes/api/locations');
const availabilityRoutes = require('./routes/api/availability');
const quotesRoutes = require('./routes/api/quotes');
const ordersRoutes = require('./routes/api/orders');
const licenseRoutes = require('./routes/api/license');
const violationsRoutes = require('./routes/api/violations');
const invoicesRoutes = require('./routes/api/invoices');
const ticketsRoutes = require('./routes/api/tickets');
const couponsRoutes = require('./routes/api/coupons');
const messagesRoutes = require('./routes/api/messages');

seed();

const app = express();
const PORT = process.env.PORT || 3012;

app.use(cors({ origin: true }));
app.use(express.json());

setInterval(() => releaseExpiredPendingOrders(), 60 * 1000);

app.get('/health', (_req, res) => res.json({ ok: true, service: 'car-rental' }));

app.use('/api/auth', authRoutes);
app.use('/api/vehicles', vehiclesRoutes);
app.use('/api/locations', locationsRoutes);
app.use('/api/availability', availabilityRoutes);
app.use('/api/quotes', quotesRoutes);
app.use('/api/orders', ordersRoutes);
app.use('/api/license', licenseRoutes);
app.use('/api/violations', violationsRoutes);
app.use('/api/invoices', invoicesRoutes);
app.use('/api/tickets', ticketsRoutes);
app.use('/api/coupons', couponsRoutes);
app.use('/api/messages', messagesRoutes);

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Car rental backend running at http://localhost:${PORT}`);
    console.log(`API base: http://localhost:${PORT}/api`);
  });
}

module.exports = app;
