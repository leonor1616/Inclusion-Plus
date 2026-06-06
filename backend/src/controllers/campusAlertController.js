const pool = require('../db');

exports.getCampusAlerts = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
          ca.*,
          l.name AS location_name
       FROM campus_alert ca
       LEFT JOIN incampus_university_location l
         ON l.id = ca.incampus_location_id
       ORDER BY ca.created_at DESC`
    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to fetch campus alerts'
    });
  }
};

exports.getCampusAlertById = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT
          ca.*,
          l.name AS location_name
       FROM campus_alert ca
       LEFT JOIN incampus_university_location l
         ON l.id = ca.incampus_location_id
       WHERE ca.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Campus alert not found'
      });
    }

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to fetch campus alert'
    });
  }
};

exports.createCampusAlert = async (req, res) => {
  const {
    title,
    description,
    alert_type,
    incampus_location_id,
    starts_at,
    ends_at
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO campus_alert (
          title,
          description,
          alert_type,
          incampus_location_id,
          starts_at,
          ends_at
       )
       VALUES ($1,$2,$3,$4,$5,$6)
       RETURNING *`,
      [
        title,
        description,
        alert_type,
        incampus_location_id || null,
        starts_at || null,
        ends_at || null
      ]
    );

    res.status(201).json(result.rows[0]);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to create campus alert'
    });
  }
};

exports.updateCampusAlert = async (req, res) => {
  const { id } = req.params;

  const {
    title,
    description,
    alert_type,
    starts_at,
    ends_at
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE campus_alert
       SET
          title = $1,
          description = $2,
          alert_type = $3,
          starts_at = $4,
          ends_at = $5,
          updated_at = NOW()
       WHERE id = $6
       RETURNING *`,
      [
        title,
        description,
        alert_type,
        starts_at,
        ends_at,
        id
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Campus alert not found'
      });
    }

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to update campus alert'
    });
  }
};

exports.deleteCampusAlert = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `DELETE FROM campus_alert
       WHERE id = $1
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Campus alert not found'
      });
    }

    res.json({
      message: 'Campus alert deleted successfully'
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to delete campus alert'
    });
  }
};