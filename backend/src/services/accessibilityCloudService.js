//responsabilidades: Chamar Accessibility Cloud
//Normalizar resposta - não guarda na BD

const axios = require('axios');

function normalizeAccessibilityCloudPlace(feature) {
  const properties = feature.properties || {};
  const coordinates = feature.geometry?.coordinates || [];

  return {
    source: 'accessibility_cloud',
    external_source_id: String(
      properties.originalId || properties._id
    ),
    name:
      properties.name?.en ||
      properties.name?.pt ||
      properties.name ||
      'Unnamed location',
    category: properties.category || null,
    latitude: coordinates[1] || null,
    longitude: coordinates[0] || null,
    source_url: properties.infoPageUrl || null,

    raw_accessibility_data:
      properties.accessibility || null
  };
}

async function fetchPlaces(
  latitude,
  longitude,
  radius = 1000
) {
  const response = await axios.get(
    'https://accessibility-cloud-v2.freetls.fastly.net/place-infos.json',
    {
      params: {
        appToken:
          process.env.ACCESSIBILITY_CLOUD_API_TOKEN,
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

  return response.data.features.map(
    normalizeAccessibilityCloudPlace
  );
}

module.exports = {
  fetchPlaces
};