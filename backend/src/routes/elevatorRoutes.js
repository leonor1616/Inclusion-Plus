const express = require('express');
const router = express.Router();

const elevatorController = require('../controllers/elevatorController');
const authMiddleware = require('../middleware/authMiddleware');

router.get(
  '/',
  authMiddleware,
  elevatorController.getElevators
);

router.get(
  '/:id',
  authMiddleware,
  elevatorController.getElevatorById
);

router.patch(
  '/:id/status',
  authMiddleware,
  elevatorController.updateElevatorStatus
);

module.exports = router;