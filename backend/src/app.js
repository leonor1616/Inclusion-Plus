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
const postRoutes = require('./routes/postRoutes');
const locationRoutes = require('./routes/locationsRoutes');
const elevatorRoutes = require('./routes/elevatorRoutes');
const campusAlertRoutes = require('./routes/campusAlertRoutes');
const accessibilityFeatureRoutes = require('./routes/accessibilityFeatureRoutes');
const academicEventRoutes = require('./routes/academicEventRoutes');
const routeRoutes = require('./routes/routeRoutes');
const externalLocationRoutes = require('./routes/externalLocationRoutes');
const uploadRoutes = require('./routes/uploadRoutes');
const countryRoutes = require('./routes/countryRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

const API_ENDPOINTS = {
  health: '/health',
  database: '/test-db',
  users: '/users',
  profile: '/profile',
  reports: '/reports',
  countries: '/countries',
  helpRequests: '/help-requests',
  favorites: '/favorites',
  posts: '/posts',
  locations: '/locations',
  elevators: '/elevators',
  campusAlerts: '/campus-alerts',
  academicEvents: '/academic-events',
  routes: '/routes',
  uploads: '/uploads',
  auth: {
    register: 'POST /auth/register',
    login: 'POST /auth/login',
  },
};

app.use(cors());
app.use('/upload', uploadRoutes);

app.use(express.json());
app.use('/uploads', express.static('uploads'));

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
app.use('/posts', postRoutes);
app.use('/locations', locationRoutes);
app.use('/elevators', elevatorRoutes);
app.use('/campus-alerts', campusAlertRoutes);
app.use('/accessibility-features', accessibilityFeatureRoutes);
app.use('/academic-events', academicEventRoutes);
app.use('/routes', routeRoutes);
app.use('/external-locations', externalLocationRoutes);
app.use('/upload', uploadRoutes);
app.use('/countries', countryRoutes);
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
