const axios = require('axios');

exports.searchExternalLocations = async (req, res) => {
  const { latitude, longitude, radius = 1000 } = req.query;

  try {
    const response = await axios.get(
      'https://accessibility-cloud-v2.freetls.fastly.net/place-infos.json',
      {
        params: {
          appToken: process.env.ACCESSIBILITY_CLOUD_API_TOKEN,
          latitude,
          longitude,
          accuracy: radius
        },
        timeout: 10000,
        headers: {
          Accept: 'application/json'
        }
      }
    );

    const normalizedLocations = response.data.features.map((feature) => {
      const properties = feature.properties || {};
      const coordinates = feature.geometry?.coordinates || [];

      return {
        external_source_id: String(properties.originalId || properties._id),
        name:
          properties.name?.en ||
          properties.name?.pt ||
          properties.name ||
          'Unnamed location',
        category: properties.category || null,
        latitude: coordinates[1] || null,
        longitude: coordinates[0] || null,
        wheelchair_accessible:
          properties.accessibility?.accessibleWith?.wheelchair ?? null,
        source_url: properties.infoPageUrl || null,
        source: 'accessibility_cloud'
      };
    });

    res.json(normalizedLocations);
  } catch (err) {
    console.error(err.response?.data || err.message);

    res.status(500).json({
      error: 'Failed to fetch external accessibility locations'
    });
  }
};