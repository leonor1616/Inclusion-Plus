const pool = require('../db');

exports.addFavoriteLocation = async (req, res) => {
  const { incampus_university_location_id, external_location_id } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO favorite_location (
        user_id,
        incampus_university_location_id,
        external_location_id
      )
      VALUES ($1, $2, $3)
      RETURNING *`,
      [
        req.user.id,
        incampus_university_location_id || null,
        external_location_id || null
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to add favorite location' });
  }
};

exports.getFavoriteLocations = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM favorite_location
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [req.user.id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch favorite locations' });
  }
};

exports.deleteFavoriteLocation = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `DELETE FROM favorite_location
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Favorite location not found' });
    }

    res.json({ message: 'Favorite location deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete favorite location' });
  }
};

exports.addFavoriteRoute = async (req, res) => {
  const {
    accessibility_profile_id,
    origin_incampus_location_id,
    destination_incampus_location_id,
    origin_external_location_id,
    destination_external_location_id,
    route_modes,
    filters,
    planned_departure_time,
    planned_arrival_time
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO favorite_route (
        user_id,
        accessibility_profile_id,
        origin_incampus_location_id,
        destination_incampus_location_id,
        origin_external_location_id,
        destination_external_location_id,
        route_modes,
        filters,
        planned_departure_time,
        planned_arrival_time
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
      RETURNING *`,
      [
        req.user.id,
        accessibility_profile_id || null,
        origin_incampus_location_id || null,
        destination_incampus_location_id || null,
        origin_external_location_id || null,
        destination_external_location_id || null,
        route_modes,
        JSON.stringify(filters || {}),
        planned_departure_time || null,
        planned_arrival_time || null
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to add favorite route' });
  }
};

exports.getFavoriteRoutes = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM favorite_route
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [req.user.id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch favorite routes' });
  }
};

exports.deleteFavoriteRoute = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `DELETE FROM favorite_route
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Favorite route not found' });
    }

    res.json({ message: 'Favorite route deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete favorite route' });
  }
};