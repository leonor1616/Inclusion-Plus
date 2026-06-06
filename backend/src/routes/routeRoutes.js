const express = require('express');
const router = express.Router();

const routeController = require('../controllers/routeController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/calculate', authMiddleware, routeController.calculateRoute);

module.exports = router;