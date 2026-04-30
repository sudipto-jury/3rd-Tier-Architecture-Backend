const pool = require('../config/db');

// Mark a topic as complete/incomplete
const updateProgress = async (req, res) => {
  const { topicId } = req.params;
  const { completed } = req.body;
  const userId = req.user.userId;

  try {
    // Get topic to find service_id
    const topicResult = await pool.query('SELECT service_id FROM topics WHERE id = $1', [topicId]);
    if (topicResult.rows.length === 0) {
      return res.status(404).json({ error: 'Topic not found' });
    }

    const serviceId = topicResult.rows[0].service_id;

    // Upsert progress
    await pool.query(
      `INSERT INTO user_progress (user_id, service_id, topic_id, completed, completed_at)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (user_id, topic_id)
       DO UPDATE SET completed = $4, completed_at = $5`,
      [userId, serviceId, topicId, completed, completed ? new Date() : null]
    );

    res.json({ message: 'Progress updated', topicId, completed });
  } catch (err) {
    console.error('Progress error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get user's overall progress across all services
const getUserProgress = async (req, res) => {
  const userId = req.user.userId;

  try {
    const result = await pool.query(
      `SELECT 
        s.id as service_id,
        s.slug,
        s.name,
        s.icon,
        COUNT(t.id) as total_topics,
        COUNT(up.id) FILTER (WHERE up.completed = true) as completed_topics
       FROM services s
       LEFT JOIN topics t ON t.service_id = s.id
       LEFT JOIN user_progress up ON up.topic_id = t.id AND up.user_id = $1
       GROUP BY s.id, s.slug, s.name, s.icon
       ORDER BY s.name`,
      [userId]
    );

    const progressData = result.rows.map(row => ({
      ...row,
      percentage: row.total_topics > 0
        ? Math.round((row.completed_topics / row.total_topics) * 100)
        : 0
    }));

    res.json({ progress: progressData });
  } catch (err) {
    console.error('Get progress error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

module.exports = { updateProgress, getUserProgress };
