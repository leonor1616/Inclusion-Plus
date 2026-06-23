const { Pool } = require('pg');

// Shared PostgreSQL connection pool used by all controllers/services.
// DATABASE_URL is injected through .env locally or docker-compose at runtime.
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

module.exports = pool;
