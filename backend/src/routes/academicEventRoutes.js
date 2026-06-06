const express = require('express');
const router = express.Router();

const academicEventController = require('../controllers/academicEventController');
const authMiddleware = require('../middleware/authMiddleware');

router.get(
  '/',
  authMiddleware,
  academicEventController.getAcademicEvents
);

router.get(
  '/:id',
  authMiddleware,
  academicEventController.getAcademicEventById
);

router.post(
  '/',
  authMiddleware,
  academicEventController.createAcademicEvent
);

router.patch(
  '/:id',
  authMiddleware,
  academicEventController.updateAcademicEvent
);

router.delete(
  '/:id',
  authMiddleware,
  academicEventController.deleteAcademicEvent
);

module.exports = router;