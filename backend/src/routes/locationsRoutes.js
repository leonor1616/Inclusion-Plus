const express = require('express');
const router = express.Router();

const locationController = require('../controllers/locationsController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, locationController.getLocations);
router.get('/:id', authMiddleware, locationController.getLocationById);

module.exports = router;