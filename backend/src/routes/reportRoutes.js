const express = require('express');
const router = express.Router();

const reportController = require('../controllers/reportController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/', authMiddleware, reportController.createReport);
router.get('/', authMiddleware, reportController.getReports);
router.patch('/:id/status', authMiddleware, reportController.updateReportStatus);
router.delete('/:id', authMiddleware, reportController.deleteReport);

module.exports = router;