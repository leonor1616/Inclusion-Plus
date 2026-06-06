const express = require('express');
const router = express.Router();

const controller = require('../controllers/accessibilityFeatureController');
const authMiddleware = require('../middleware/authMiddleware');

router.get(
  '/',
  authMiddleware,
  controller.getFeatureTypes
);

router.get(
  '/locations/:id',
  authMiddleware,
  controller.getLocationFeatures
);

router.post(
  '/locations/:id',
  authMiddleware,
  controller.addLocationFeature
);

router.patch(
  '/:id',
  authMiddleware,
  controller.updateLocationFeature
);

router.delete(
  '/:id',
  authMiddleware,
  controller.deleteLocationFeature
);

module.exports = router;