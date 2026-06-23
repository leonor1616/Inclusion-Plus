const pool = require('../db');

const ALLOWED_POST_TYPES = ['review', 'advice', 'question'];
const DEFAULT_POST_LIMIT = 20;
const MAX_POST_LIMIT = 50;

// Community content currently supports three post categories reflected in both
// database checks and Flutter UI filters.
function parsePositiveInt(value, fallback) {
  const parsed = Number.parseInt(value, 10);
  return Number.isNaN(parsed) || parsed < 0 ? fallback : parsed;
}

function getPostsQueryParams(query) {
  const requestedLimit = parsePositiveInt(query.limit, DEFAULT_POST_LIMIT);
  const limit = Math.min(requestedLimit, MAX_POST_LIMIT);
  const offset = parsePositiveInt(query.offset, 0);
  const postType = query.type || query.post_type || null;

  return { limit, offset, postType };
}

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
  const { limit, offset, postType } = getPostsQueryParams(req.query);

  if (postType && !ALLOWED_POST_TYPES.includes(postType)) {
    return res.status(400).json({
      error: 'Invalid post type',
      allowedTypes: ALLOWED_POST_TYPES
    });
  }

  try {
    // The feed query enriches posts with author, location and comment count so
    // the client does not need extra requests for each card.
    const result = await pool.query(
      `SELECT
          p.id,
          p.user_id,
          u.full_name AS author_name,
          u.profile_picture_url AS author_profile_picture_url,
          p.incampus_university_location_id,
          il.name AS incampus_location_name,
          il.building AS incampus_location_building,
          il.floor AS incampus_location_floor,
          il.room_code AS incampus_location_room_code,
          p.external_location_id,
          el.name AS external_location_name,
          el.category AS external_location_category,
          p.post_type,
          p.content,
          p.rating,
          p.image_url,
          COALESCE(comment_counts.total, 0)::INT AS comments_count,
          p.created_at,
          p.updated_at
       FROM post p
       JOIN "user" u
         ON u.id = p.user_id
       LEFT JOIN incampus_university_location il
         ON il.id = p.incampus_university_location_id
       LEFT JOIN external_location el
         ON el.id = p.external_location_id
       LEFT JOIN (
          SELECT post_id, COUNT(*) AS total
          FROM comment
          GROUP BY post_id
       ) comment_counts
         ON comment_counts.post_id = p.id
       WHERE ($1::VARCHAR IS NULL OR p.post_type = $1)
       ORDER BY p.created_at DESC, p.id DESC
       LIMIT $2 OFFSET $3`,
      [postType, limit, offset]
    );

    res.json({
      data: result.rows,
      pagination: {
        limit,
        offset,
        count: result.rows.length,
        nextOffset: result.rows.length === limit ? offset + limit : null
      },
      filters: {
        postType
      }
    });
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
