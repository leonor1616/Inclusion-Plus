const pool = require('../db');

exports.searchCountries = async (req, res) => {
  const search = req.query.search || '';

  try {
    const result = await pool.query(
      `
      SELECT code, name, phone_code
      FROM country
      WHERE LOWER(name) LIKE LOWER($1)
      ORDER BY name ASC
      LIMIT 20
      `,
      [`%${search}%`]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to search countries' });
  }
};