const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

// Test route
app.get('/', (req, res) => {
  res.json({ message: 'MonBadge API is running 🚀' });
});
const authRoutes = require('./routes/authRoutes');
app.use('/api/auth', authRoutes);
const coursRoutes = require('./routes/coursRoutes');
app.use('/api/cours', coursRoutes);
const presenceRoutes = require('./routes/presenceRoutes');
app.use('/api/presences', presenceRoutes);
const adminRoutes = require('./routes/adminRoutes');
app.use('/api/admin', adminRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`MonBadge server running on port ${PORT}`);
});