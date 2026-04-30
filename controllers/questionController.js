const pool = require('../config/db');

// Get all questions for a service
const getQuestions = async (req, res) => {
  const { serviceSlug } = req.params;

  try {
    const serviceResult = await pool.query('SELECT id FROM services WHERE slug = $1', [serviceSlug]);
    if (serviceResult.rows.length === 0) {
      return res.status(404).json({ error: 'Service not found' });
    }

    const serviceId = serviceResult.rows[0].id;

    const result = await pool.query(
      `SELECT q.*, u.name as user_name, u.avatar as user_avatar,
              au.name as answered_by_name
       FROM questions q
       JOIN users u ON u.id = q.user_id
       LEFT JOIN users au ON au.id = q.answered_by
       WHERE q.service_id = $1
       ORDER BY q.created_at DESC`,
      [serviceId]
    );

    // Check if current user liked any questions
    let userLikes = [];
    if (req.user) {
      const likesResult = await pool.query(
        'SELECT question_id FROM question_likes WHERE user_id = $1',
        [req.user.userId]
      );
      userLikes = likesResult.rows.map(r => r.question_id);
    }

    res.json({
      questions: result.rows.map(q => ({
        ...q,
        userLiked: userLikes.includes(q.id)
      }))
    });
  } catch (err) {
    console.error('Get questions error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

// Post a new question
const postQuestion = async (req, res) => {
  const { serviceSlug } = req.params;
  const { question } = req.body;
  const userId = req.user.userId;

  if (!question || question.trim().length === 0) {
    return res.status(400).json({ error: 'Question cannot be empty' });
  }

  try {
    const serviceResult = await pool.query('SELECT id FROM services WHERE slug = $1', [serviceSlug]);
    if (serviceResult.rows.length === 0) {
      return res.status(404).json({ error: 'Service not found' });
    }

    const serviceId = serviceResult.rows[0].id;

    const result = await pool.query(
      `INSERT INTO questions (user_id, service_id, question)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [userId, serviceId, question.trim()]
    );

    // Get user info
    const userResult = await pool.query('SELECT name, avatar FROM users WHERE id = $1', [userId]);
    const user = userResult.rows[0];

    res.status(201).json({
      message: 'Question posted successfully',
      question: {
        ...result.rows[0],
        user_name: user.name,
        user_avatar: user.avatar,
        userLiked: false
      }
    });
  } catch (err) {
    console.error('Post question error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

// Like/unlike a question
const toggleLike = async (req, res) => {
  const { questionId } = req.params;
  const userId = req.user.userId;

  try {
    // Check if already liked
    const existing = await pool.query(
      'SELECT id FROM question_likes WHERE user_id = $1 AND question_id = $2',
      [userId, questionId]
    );

    let liked;
    if (existing.rows.length > 0) {
      // Unlike
      await pool.query('DELETE FROM question_likes WHERE user_id = $1 AND question_id = $2', [userId, questionId]);
      await pool.query('UPDATE questions SET likes = likes - 1 WHERE id = $1', [questionId]);
      liked = false;
    } else {
      // Like
      await pool.query('INSERT INTO question_likes (user_id, question_id) VALUES ($1, $2)', [userId, questionId]);
      await pool.query('UPDATE questions SET likes = likes + 1 WHERE id = $1', [questionId]);
      liked = true;
    }

    const result = await pool.query('SELECT likes FROM questions WHERE id = $1', [questionId]);
    res.json({ liked, likes: result.rows[0].likes });
  } catch (err) {
    console.error('Toggle like error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

module.exports = { getQuestions, postQuestion, toggleLike };
