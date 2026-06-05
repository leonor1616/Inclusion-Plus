const pool = require('../db');

exports.createReport = async (req, res) => {
  const {
    incampus_university_location_id,
    elevator_id,
    external_location_id,
    feature_type_id,
    report_type,
    description,
    image_url
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO report (
        user_id,
        incampus_university_location_id,
        elevator_id,
        external_location_id,
        feature_type_id,
        report_type,
        description,
        image_url
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
      RETURNING *`,
      [
        req.user.id,
        incampus_university_location_id || null,
        elevator_id || null,
        external_location_id || null,
        feature_type_id || null,
        report_type,
        description,
        image_url || null
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create report' });
  }
};

exports.getReports = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM report
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [req.user.id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch reports' });
  }
};

exports.updateReportStatus = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  try {
    const result = await pool.query(
      `UPDATE report
       SET status = $1,
           updated_at = NOW()
       WHERE id = $2
         AND user_id = $3
       RETURNING *`,
      [status, id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Report not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update report status' });
  }
};

exports.deleteReport = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `DELETE FROM report
       WHERE id = $1
         AND user_id = $2
       RETURNING *`,
      [id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Report not found' });
    }

    res.json({ message: 'Report deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete report' });
  }
};