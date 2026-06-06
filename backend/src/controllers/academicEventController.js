const pool = require('../db');

exports.getAcademicEvents = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM academic_event
       WHERE user_id = $1
       ORDER BY starts_at ASC`,
      [req.user.id]
    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to fetch academic events'
    });
  }
};

exports.getAcademicEventById = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT *
       FROM academic_event
       WHERE id = $1
         AND user_id = $2`,
      [id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Academic event not found'
      });
    }

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to fetch academic event'
    });
  }
};

exports.createAcademicEvent = async (req, res) => {
  const {
    title,
    event_type,
    incampus_location_id,
    room_label,
    building,
    starts_at,
    ends_at,
    source
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO academic_event (
          user_id,
          title,
          event_type,
          incampus_location_id,
          room_label,
          building,
          starts_at,
          ends_at,
          source
       )
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
       RETURNING *`,
      [
        req.user.id,
        title,
        event_type,
        incampus_location_id || null,
        room_label || null,
        building || null,
        starts_at,
        ends_at,
        source || 'manual'
      ]
    );

    res.status(201).json(result.rows[0]);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to create academic event'
    });
  }
};

exports.updateAcademicEvent = async (req, res) => {
  const { id } = req.params;

  const {
    title,
    event_type,
    room_label,
    building,
    starts_at,
    ends_at,
    status
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE academic_event
       SET
          title = $1,
          event_type = $2,
          room_label = $3,
          building = $4,
          starts_at = $5,
          ends_at = $6,
          status = $7,
          updated_at = NOW()
       WHERE id = $8
         AND user_id = $9
       RETURNING *`,
      [
        title,
        event_type,
        room_label,
        building,
        starts_at,
        ends_at,
        status,
        id,
        req.user.id
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Academic event not found'
      });
    }

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to update academic event'
    });
  }
};

exports.deleteAcademicEvent = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `DELETE FROM academic_event
       WHERE id = $1
         AND user_id = $2
       RETURNING *`,
      [id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Academic event not found'
      });
    }

    res.json({
      message: 'Academic event deleted successfully'
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to delete academic event'
    });
  }
};