const GOOGLE_ROUTES_URL =
  'https://routes.googleapis.com/directions/v2:computeRoutes';

function formatDuration(duration) {
  const seconds = Number(String(duration || '0s').replace('s', ''));
  const minutes = Math.max(1, Math.round(seconds / 60));

  return {
    seconds,
    text: `${minutes} minutes`,
  };
}

function formatDistance(distanceMeters = 0) {
  if (distanceMeters >= 1000) {
    return `${(distanceMeters / 1000).toFixed(1)} km`;
  }

  return `${distanceMeters} m`;
}

function getArrivalTimeText(durationSeconds) {
  const arrival = new Date(Date.now() + durationSeconds * 1000);

  return `Arrive by ${arrival.toLocaleTimeString('en-GB', {
    hour: '2-digit',
    minute: '2-digit',
    timeZone: 'Europe/Lisbon',
  })}`;
}

function getGoogleMapsTravelMode(travelMode) {
  switch (travelMode) {
    case 'TRANSIT':
      return 'transit';
    case 'WALK':
    default:
      return 'walking';
  }
}

function getModeSummary(travelMode) {
  switch (travelMode) {
    case 'TRANSIT':
      return 'Public Transport';
    case 'WALK':
    default:
      return 'Walking';
  }
}

async function fetchRoutesForMode({
  originLat,
  originLng,
  destinationLat,
  destinationLng,
  travelMode,
}) {
  const response = await fetch(GOOGLE_ROUTES_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': process.env.GOOGLE_MAPS_API_KEY,
      'X-Goog-FieldMask':
        'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
    },
    body: JSON.stringify({
      origin: {
        location: {
          latLng: {
            latitude: Number(originLat),
            longitude: Number(originLng),
          },
        },
      },
      destination: {
        location: {
          latLng: {
            latitude: Number(destinationLat),
            longitude: Number(destinationLng),
          },
        },
      },
      travelMode,
      computeAlternativeRoutes: true,
      polylineEncoding: 'ENCODED_POLYLINE',
      languageCode: 'en',
      units: 'METRIC',
    }),
  });

  const data = await response.json();

  if (!response.ok) {
    console.error(`GOOGLE ROUTES ${travelMode} ERROR:`, data);
    return [];
  }

  return (data.routes || []).map((route, index) => {
    const duration = formatDuration(route.duration);
    const distanceMeters = route.distanceMeters || 0;
    const googleMapsTravelMode = getGoogleMapsTravelMode(travelMode);

    return {
      id: `${travelMode.toLowerCase()}_route_${index + 1}`,
      durationText: duration.text,
      distanceText: formatDistance(distanceMeters),
      arrivalTimeText: getArrivalTimeText(duration.seconds),
      modeSummary: getModeSummary(travelMode),
      encodedPolyline: route.polyline?.encodedPolyline || null,
      googleMapsUrl:
        `https://www.google.com/maps/dir/?api=1` +
        `&destination=${destinationLat},${destinationLng}` +
        `&travelmode=${googleMapsTravelMode}`,
    };
  });
}

async function fetchRoutes({
  originLat,
  originLng,
  destinationLat,
  destinationLng,
}) {
  const [walkingRoutes, transitRoutes] = await Promise.all([
    fetchRoutesForMode({
      originLat,
      originLng,
      destinationLat,
      destinationLng,
      travelMode: 'WALK',
    }),
    fetchRoutesForMode({
      originLat,
      originLng,
      destinationLat,
      destinationLng,
      travelMode: 'TRANSIT',
    }),
  ]);

  return [...walkingRoutes, ...transitRoutes].sort((a, b) => {
    const aMinutes = Number(a.durationText.replace(' minutes', ''));
    const bMinutes = Number(b.durationText.replace(' minutes', ''));

    return aMinutes - bMinutes;
  });
}

module.exports = {
  fetchRoutes,
};