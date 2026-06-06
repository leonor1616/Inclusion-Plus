const pool = require('../db');

exports.createPost = async (req, res) => {
  const {
    incampus_university_location_id,
    external_location_id,
    post_type,
    content,
    rating,
    image_url
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO post (
        user_id,
        incampus_university_location_id,
        external_location_id,
        post_type,
        content,
        rating,
        image_url
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7)
      RETURNING *`,
      [
        req.user.id,
        incampus_university_location_id || null,
        external_location_id || null,
        post_type,
        content,
        rating || null,
        image_url || null
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create post' });
  }
};

exports.getPosts = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT p.*, u.full_name
       FROM post p
       JOIN "user" u ON u.id = p.user_id
       ORDER BY p.created_at DESC`
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
};

exports.deletePost = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `DELETE FROM post
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Post not found' });
    }

    res.json({ message: 'Post deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete post' });
  }
};

exports.createComment = async (req, res) => {
  const { id } = req.params;
  const { content } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO comment (
        post_id,
        user_id,
        content
      )
      VALUES ($1,$2,$3)
      RETURNING *`,
      [id, req.user.id, content]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create comment' });
  }
};

exports.getComments = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT c.*, u.full_name
       FROM comment c
       JOIN "user" u ON u.id = c.user_id
       WHERE c.post_id = $1
       ORDER BY c.created_at ASC`,
      [id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch comments' });
  }
};

exports.deleteComment = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `DELETE FROM comment
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Comment not found' });
    }

    res.json({ message: 'Comment deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete comment' });
  }
};