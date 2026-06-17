const express = require('express');
const router = express.Router();

const mapController = require('../controllers/mapController');

router.get('/places', mapController.getMapPlaces);

router.get('/test-google-places', mapController.testGooglePlaces);

router.get('/search', mapController.searchMapPlaces);

module.exports = router;