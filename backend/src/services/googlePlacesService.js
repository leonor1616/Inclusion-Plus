const axios = require('axios');

function normalizeGooglePlace(place) {
  const location = place.location || {};

  return {
    source: 'google_places',
    external_source_id: place.id,
    name: place.displayName?.text || 'Unnamed location',
    category: place.primaryType || place.types?.[0] || null,
    latitude: location.latitude || null,
    longitude: location.longitude || null,
    source_url: place.googleMapsUri || null,
    raw_accessibility_data: null,
  };
}

async function fetchPlaces(latitude, longitude, radius = 1000) {
  const response = await axios.post(
    'https://places.googleapis.com/v1/places:searchNearby',
    {
      locationRestriction: {
        circle: {
          center: {
            latitude: Number(latitude),
            longitude: Number(longitude),
          },
          radius: Number(radius),
        },
      },
      maxResultCount: 20,
    },
    {
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': process.env.GOOGLE_MAPS_API_KEY,
        'X-Goog-FieldMask':
          'places.id,places.displayName,places.primaryType,places.types,places.location,places.googleMapsUri',
      },
    }
  );

  return (response.data.places || [])
    .map(normalizeGooglePlace)
    .filter((place) => place.external_source_id && place.latitude && place.longitude);
}

async function searchPlacesByText(query) {
  const response = await axios.post(
    'https://places.googleapis.com/v1/places:searchText',
    {
      textQuery: query,
      maxResultCount: 20,
    },
    {
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': process.env.GOOGLE_MAPS_API_KEY,
        'X-Goog-FieldMask':
          'places.id,places.displayName,places.primaryType,places.types,places.location,places.googleMapsUri',
      },
    }
  );

  return (response.data.places || [])
    .map(normalizeGooglePlace)
    .filter((place) => place.external_source_id && place.latitude && place.longitude);
}

module.exports = {
  fetchPlaces,
  searchPlacesByText,
};