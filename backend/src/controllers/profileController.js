const pool = require('../db');

// Accessibility profile stores user-specific needs/preferences as JSONB so the
// schema can evolve without new columns for every preference type.
exports.getProfile = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM accessibility_profile
       WHERE user_id = $1`,
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.json(null);
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: 'Failed to fetch profile'
    });
  }
};

exports.updateProfile = async (req, res) => {
  const {
    disability_types,
    custom_ui_preferences,
    navigation_preferences
  } = req.body;

  try {
    const existing = await pool.query(
      `SELECT id FROM accessibility_profile WHERE user_id = $1`,
      [req.user.id]
    );

    let result;

    // Upsert-like behavior: create the profile on first save, update it later.
    if (existing.rows.length === 0) {
      result = await pool.query(
        `INSERT INTO accessibility_profile (
          user_id,
          disability_types,
          custom_ui_preferences,
          navigation_preferences
        )
        VALUES ($1, $2, $3, $4)
        RETURNING *`,
        [
          req.user.id,
          JSON.stringify(disability_types || []),
          JSON.stringify(custom_ui_preferences || {}),
          JSON.stringify(navigation_preferences || {})
        ]
      );
    } else {
      result = await pool.query(
        `UPDATE accessibility_profile
         SET disability_types = $1,
             custom_ui_preferences = $2,
             navigation_preferences = $3,
             updated_at = NOW()
         WHERE user_id = $4
         RETURNING *`,
        [
          JSON.stringify(disability_types || []),
          JSON.stringify(custom_ui_preferences || {}),
          JSON.stringify(navigation_preferences || {}),
          req.user.id
        ]
      );
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update profile' });
  }
};
