const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

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