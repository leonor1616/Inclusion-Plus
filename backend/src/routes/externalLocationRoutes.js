const express = require('express');
const router = express.Router();

const externalLocationController =
  require('../controllers/externalLocationController');

const authMiddleware =
  require('../middleware/authMiddleware');

router.get(
  '/',
  authMiddleware,
  externalLocationController.getCachedExternalLocations
);

router.get(
  '/cached',
  authMiddleware,
  externalLocationController.getCachedExternalLocations
);

router.get(
  '/nearby',
  authMiddleware,
  externalLocationController.getNearbyExternalLocations
);

router.get(
  '/search',
  authMiddleware,
  externalLocationController.searchExternalLocations
);

module.exports = router;