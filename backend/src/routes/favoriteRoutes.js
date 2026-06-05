const express = require('express');
const router = express.Router();

const favoriteController = require('../controllers/favoriteController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/locations', authMiddleware, favoriteController.addFavoriteLocation);
router.get('/locations', authMiddleware, favoriteController.getFavoriteLocations);
router.delete('/locations/:id', authMiddleware, favoriteController.deleteFavoriteLocation);

router.post('/routes', authMiddleware, favoriteController.addFavoriteRoute);
router.get('/routes', authMiddleware, favoriteController.getFavoriteRoutes);
router.delete('/routes/:id', authMiddleware, favoriteController.deleteFavoriteRoute);

module.exports = router;