const pool = require('../db');

exports.getLocations = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
        l.*,
        t.name AS location_type
       FROM incampus_university_location l
       JOIN incampus_location_type t
         ON t.id = l.location_type_id
       ORDER BY l.name ASC`
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch locations' });
  }
};

exports.getLocationById = async (req, res) => {
  const { id } = req.params;

  try {
    const locationResult = await pool.query(
      `SELECT
        l.*,
        t.name AS location_type
       FROM incampus_university_location l
       JOIN incampus_location_type t
         ON t.id = l.location_type_id
       WHERE l.id = $1`,
      [id]
    );

    if (locationResult.rows.length === 0) {
      return res.status(404).json({ error: 'Location not found' });
    }

    const featuresResult = await pool.query(
      `SELECT
        lf.id,
        lf.description,
        lf.status,
        aft.name,
        aft.icon
       FROM location_specific_accessibility_feature lf
       JOIN accessibility_feature_type aft
         ON aft.id = lf.feature_type_id
       WHERE lf.incampus_location_id = $1`,
      [id]
    );

    const elevatorsResult = await pool.query(
      `SELECT *
       FROM elevator
       WHERE incampus_university_location_id = $1`,
      [id]
    );

    res.json({
      ...locationResult.rows[0],
      accessibility_features: featuresResult.rows,
      elevators: elevatorsResult.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch location' });
  }
};