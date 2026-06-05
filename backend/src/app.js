require('dotenv').config();

const express = require('express');
const cors = require('cors');

const pool = require('./db');
const authMiddleware = require('./middleware/authMiddleware');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const profileRoutes = require('./routes/profileRoutes');
const reportRoutes = require('./routes/reportRoutes');
const helpRequestRoutes = require('./routes/helpRequestRoutes');
const favoriteRoutes = require('./routes/favoriteRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

const API_ENDPOINTS = {
  health: '/health',
  database: '/test-db',
  users: '/users',
  profile: '/profile',
  reports: '/reports',
  helpRequests: '/help-requests',
  favorites: '/favorites',
  auth: {
    register: 'POST /auth/register',
    login: 'POST /auth/login',
  },
};

app.use(cors());
app.use(express.json());

// Public routes
app.get('/', (req, res) => {
  res.json({
    message: 'Inclusion Plus API',
    endpoints: API_ENDPOINTS,
  });
});

app.get('/health', (req, res) => {
  res.json({ message: 'Backend is running' });
});

app.get('/test-db', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB connection failed' });
  }
});

// Route modules
app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/profile', profileRoutes);
app.use('/reports', reportRoutes);
app.use('/help-requests', helpRequestRoutes);
app.use('/favorites', favoriteRoutes);

// Protected routes
app.get('/me', authMiddleware, (req, res) => {
  res.json(req.user);
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;
