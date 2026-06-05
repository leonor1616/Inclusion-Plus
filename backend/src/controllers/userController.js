const pool = require('../db');

exports.getMe = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, email, full_name, account_type, university_id, country_code, city, profile_picture_url
       FROM "user"
       WHERE id = $1`,
      [req.user.id]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
};

exports.updateMe = async (req, res) => {
  const { full_name, city, country_code, profile_picture_url } = req.body;

  try {
    const result = await pool.query(
      `UPDATE "user"
       SET full_name = COALESCE($1, full_name),
           city = COALESCE($2, city),
           country_code = COALESCE($3, country_code),
           profile_picture_url = COALESCE($4, profile_picture_url),
           updated_at = NOW()
       WHERE id = $5
       RETURNING id, email, full_name, account_type, university_id, country_code, city, profile_picture_url`,
      [full_name, city, country_code, profile_picture_url, req.user.id]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update user profile' });
  }
};