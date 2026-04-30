const express = require('express');
const router = express.Router();
const { updateProgress, getUserProgress } = require('../controllers/progressController');
const { authenticateToken } = require('../middleware/auth');

router.get('/', authenticateToken, getUserProgress);
router.put('/:topicId', authenticateToken, updateProgress);

module.exports = router;
