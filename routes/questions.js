const express = require('express');
const router = express.Router();
const { getQuestions, postQuestion, toggleLike } = require('../controllers/questionController');
const { authenticateToken, optionalAuth } = require('../middleware/auth');

router.get('/:serviceSlug', optionalAuth, getQuestions);
router.post('/:serviceSlug', authenticateToken, postQuestion);
router.post('/like/:questionId', authenticateToken, toggleLike);

module.exports = router;
