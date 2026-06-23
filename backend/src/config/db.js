const { Pool } = require('pg');

// Legacy/shared DB export kept for modules that still import from config/db.
// It points to the same DATABASE_URL-based PostgreSQL connection pattern.
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

module.exports = pool;
