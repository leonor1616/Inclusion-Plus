const pool = require('../db');

exports.getFeatureTypes = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM accessibility_feature_type
       ORDER BY name ASC`
    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to fetch accessibility feature types'
    });
  }
};

exports.getLocationFeatures = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT
          lf.id,
          lf.description,
          lf.status,
          aft.id AS feature_type_id,
          aft.name,
          aft.icon
       FROM location_specific_accessibility_feature lf
       JOIN accessibility_feature_type aft
         ON aft.id = lf.feature_type_id
       WHERE lf.incampus_location_id = $1
       ORDER BY aft.name ASC`,
      [id]
    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to fetch location accessibility features'
    });
  }
};

exports.addLocationFeature = async (req, res) => {
  const { id } = req.params;

  const {
    feature_type_id,
    description,
    status
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO location_specific_accessibility_feature (
          incampus_location_id,
          feature_type_id,
          description,
          status
       )
       VALUES ($1,$2,$3,$4)
       RETURNING *`,
      [
        id,
        feature_type_id,
        description || null,
        status || 'available'
      ]
    );

    res.status(201).json(result.rows[0]);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to create accessibility feature'
    });
  }
};

exports.updateLocationFeature = async (req, res) => {
  const { id } = req.params;

  const {
    description,
    status
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE location_specific_accessibility_feature
       SET
          description = $1,
          status = $2,
          updated_at = NOW()
       WHERE id = $3
       RETURNING *`,
      [
        description,
        status,
        id
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Accessibility feature not found'
      });
    }

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to update accessibility feature'
    });
  }
};

exports.deleteLocationFeature = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `DELETE FROM location_specific_accessibility_feature
       WHERE id = $1
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Accessibility feature not found'
      });
    }

    res.json({
      message: 'Accessibility feature deleted successfully'
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to delete accessibility feature'
    });
  }
};