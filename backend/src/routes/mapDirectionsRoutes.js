const express = require('express');

const mapDirectionsController = require('../controllers/mapDirectionsController');

const router = express.Router();

router.get('/directions', mapDirectionsController.getDirections);

module.exports = router;