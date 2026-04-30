const express = require('express');
const router = express.Router();
const { getAllServices, getServiceBySlug } = require('../controllers/serviceController');
const { optionalAuth } = require('../middleware/auth');

router.get('/', getAllServices);
router.get('/:slug', optionalAuth, getServiceBySlug);

module.exports = router;
