const express = require('express');
const router = express.Router();

const campusAlertController = require('../controllers/campusAlertController');
const authMiddleware = require('../middleware/authMiddleware');

router.get(
  '/',
  authMiddleware,
  campusAlertController.getCampusAlerts
);

router.get(
  '/:id',
  authMiddleware,
  campusAlertController.getCampusAlertById
);

router.post(
  '/',
  authMiddleware,
  campusAlertController.createCampusAlert
);

router.patch(
  '/:id',
  authMiddleware,
  campusAlertController.updateCampusAlert
);

router.delete(
  '/:id',
  authMiddleware,
  campusAlertController.deleteCampusAlert
);

module.exports = router;