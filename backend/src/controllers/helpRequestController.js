const pool = require('../db');

exports.createHelpRequest = async (req, res) => {
  const {
    incampus_university_location_id,
    request_type,
    message,
    urgency_level,
    scheduled_for
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO help_request (
        user_id,
        incampus_university_location_id,
        request_type,
        message,
        urgency_level,
        scheduled_for
      )
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *`,
      [
        req.user.id,
        incampus_university_location_id,
        request_type,
        message || null,
        urgency_level,
        scheduled_for || null
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create help request' });
  }
};

exports.getHelpRequests = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM help_request
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [req.user.id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch help requests' });
  }
};

exports.updateHelpRequestStatus = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  try {
    const result = await pool.query(
      `UPDATE help_request
       SET status = $1,
           updated_at = NOW()
       WHERE id = $2
         AND user_id = $3
       RETURNING *`,
      [status, id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Help request not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update help request status' });
  }
};

exports.deleteHelpRequest = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `DELETE FROM help_request
       WHERE id = $1
         AND user_id = $2
       RETURNING *`,
      [id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Help request not found' });
    }

    res.json({ message: 'Help request deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete help request' });
  }
};