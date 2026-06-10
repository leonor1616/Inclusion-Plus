const express = require('express');
const router = express.Router();

const upload = require('../middleware/uploadMiddleware');
const authMiddleware = require('../middleware/authMiddleware');

router.post(
  '/',
  authMiddleware,
  upload.single('image'),
  (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          error: 'No image file uploaded. Use form-data with key "image".'
        });
      }

      res.status(200).json({
        message: 'Upload successful',
        filename: req.file.filename,
        originalName: req.file.originalname,
        url: `/uploads/${req.file.filename}`
      });
    } catch (err) {
      console.error(err);

      res.status(500).json({
        error: 'Failed to upload file'
      });
    }
  }
);

module.exports = router;