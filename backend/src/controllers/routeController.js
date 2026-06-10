const axios = require('axios');

exports.calculateRoute = async (req, res) => {
  const { origin, destination, travel_mode } = req.body;

  try {
    const response = await axios.post(
      'https://routes.googleapis.com/directions/v2:computeRoutes',
      {
        origin: {
          location: {
            latLng: {
              latitude: origin.latitude,
              longitude: origin.longitude
            }
          }
        },
        destination: {
          location: {
            latLng: {
              latitude: destination.latitude,
              longitude: destination.longitude
            }
          }
        },
        travelMode: travel_mode || 'WALK'
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': process.env.GOOGLE_MAPS_API_KEY,
          'X-Goog-FieldMask':
            'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
        }
      }
    );

    const route = response.data.routes?.[0];

    if (!route) {
      return res.status(404).json({
        error: 'No route found'
      });
    }

    const durationSeconds = Number(
      route.duration.replace('s', '')
    );

    res.json({
      distance_meters: route.distanceMeters,
      duration_seconds: durationSeconds,
      duration_minutes: Math.round(durationSeconds / 60),
      polyline: route.polyline?.encodedPolyline || null,
      travel_mode: travel_mode || 'WALK'
    });

  } catch (err) {
    console.error(err.response?.data || err.message);

    res.status(500).json({
      error: 'Failed to calculate route'
    });
  }
};