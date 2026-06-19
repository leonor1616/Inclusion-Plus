const express = require('express');
const { generatePlaceSummary } = require('../services/geminiService');

const router = express.Router();

router.post('/place-summary', async (req, res) => {
  try {
    const { placeName, category, accessibilityTags } = req.body;

    if (!placeName) {
      return res.status(400).json({
        error: 'placeName is required',
      });
    }

    const summary = await generatePlaceSummary({
      placeName,
      category,
      accessibilityTags,
    });

    return res.json({ summary });
  } catch (error) {
    console.error('AI place summary error:', error);
    return res.status(500).json({
      error: 'Failed to generate place summary',
    });
  }
});

module.exports = router;