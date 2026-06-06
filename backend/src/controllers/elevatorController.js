const pool = require('../db');

exports.getElevators = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
          e.*,
          l.name AS location_name
       FROM elevator e
       JOIN incampus_university_location l
         ON l.id = e.incampus_university_location_id
       ORDER BY l.name ASC`
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: 'Failed to fetch elevators'
    });
  }
};

exports.getElevatorById = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT
          e.*,
          l.name AS location_name
       FROM elevator e
       JOIN incampus_university_location l
         ON l.id = e.incampus_university_location_id
       WHERE e.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Elevator not found'
      });
    }

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: 'Failed to fetch elevator'
    });
  }
};

exports.updateElevatorStatus = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  try {
    const result = await pool.query(
      `UPDATE elevator
       SET status = $1,
           updated_at = NOW()
       WHERE id = $2
       RETURNING *`,
      [status, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Elevator not found'
      });
    }

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: 'Failed to update elevator'
    });
  }
};