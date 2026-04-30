const pool = require('../config/db');

// Get all AWS services
const getAllServices = async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, slug, name, icon, category, short_description FROM services ORDER BY name'
    );
    res.json({ services: result.rows });
  } catch (err) {
    console.error('Get services error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get a single service with its topics
const getServiceBySlug = async (req, res) => {
  const { slug } = req.params;
  try {
    // Get service
    const serviceResult = await pool.query('SELECT * FROM services WHERE slug = $1', [slug]);
    if (serviceResult.rows.length === 0) {
      return res.status(404).json({ error: 'Service not found' });
    }

    const service = serviceResult.rows[0];

    // Get topics for the service
    const topicsResult = await pool.query(
      'SELECT * FROM topics WHERE service_id = $1 ORDER BY order_index',
      [service.id]
    );

    // If user is logged in, get their progress
    let progress = [];
    if (req.user) {
      const progressResult = await pool.query(
        'SELECT topic_id, completed FROM user_progress WHERE user_id = $1 AND service_id = $2',
        [req.user.userId, service.id]
      );
      progress = progressResult.rows;
    }

    res.json({ service, topics: topicsResult.rows, progress });
  } catch (err) {
    console.error('Get service error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

module.exports = { getAllServices, getServiceBySlug };
