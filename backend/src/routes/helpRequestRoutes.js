const express = require('express');
const router = express.Router();

const helpRequestController = require('../controllers/helpRequestController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/', authMiddleware, helpRequestController.createHelpRequest);
router.get('/', authMiddleware, helpRequestController.getHelpRequests);
router.patch('/:id/status', authMiddleware, helpRequestController.updateHelpRequestStatus);
router.delete('/:id', authMiddleware, helpRequestController.deleteHelpRequest);

module.exports = router;