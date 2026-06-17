const googleRoutesService = require('../services/googleRoutesService');

exports.getDirections = async (req, res) => {
  const {
    originLat,
    originLng,
    destinationLat,
    destinationLng,
  } = req.query;

  if (!originLat || !originLng || !destinationLat || !destinationLng) {
    return res.status(400).json({
      error:
        'originLat, originLng, destinationLat and destinationLng are required',
    });
  }

  try {
    const routes = await googleRoutesService.fetchRoutes({
      originLat,
      originLng,
      destinationLat,
      destinationLng,
    });

    return res.json({
      count: routes.length,
      routes,
    });
  } catch (err) {
    console.error('GOOGLE ROUTES ERROR:', err.data || err);

    return res.status(err.status || 500).json({
      error: 'Failed to calculate directions',
      details: err.data || null,
    });
  }
};