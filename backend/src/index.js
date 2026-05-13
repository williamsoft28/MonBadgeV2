// Polyfill util.isNullOrUndefined and util.isArray for Node 24+ (required by tfjs-node)
const util = require('util');
if (!util.isNullOrUndefined) {
  util.isNullOrUndefined = function(v) { return v === null || v === undefined; };
}
if (!util.isArray) {
  util.isArray = Array.isArray;
}

const express = require('express');
const cors = require('cors');

if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

const app = express();

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

app.get('/', (req, res) => {
  res.json({ message: 'MonBadge API is running 🚀' });
});

const authRoutes = require('./routes/authRoutes');
const coursRoutes = require('./routes/coursRoutes');
const presenceRoutes = require('./routes/presenceRoutes');
const adminRoutes = require('./routes/adminRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/cours', coursRoutes);
app.use('/api/presences', presenceRoutes);
app.use('/api/admin', adminRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`MonBadge server running on port ${PORT}`);
});

require('./config/db');