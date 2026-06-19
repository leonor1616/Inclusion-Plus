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

function formatVehicleType(vehicleType) {
  if (!vehicleType) return null;

  return vehicleType
    .toLowerCase()
    .replaceAll('_', ' ')
    .replace(/\b\w/g, (char) => char.toUpperCase());
}

function getRouteModeSummary(route, travelMode) {
  if (travelMode === 'WALK') {
    return 'Walking';
  }

  const steps = route.legs?.flatMap((leg) => leg.steps || []) || [];
  const modes = ['Walking'];

  steps.forEach((step) => {
    if (step.travelMode !== 'TRANSIT') return;

    const vehicleType = step.transitDetails?.transitLine?.vehicle?.type;
    const formattedVehicleType = formatVehicleType(vehicleType);

    if (!formattedVehicleType) {
      if (!modes.includes('Public Transport')) {
        modes.push('Public Transport');
      }
      return;
    }

    let normalizedMode = formattedVehicleType;

    if (
      formattedVehicleType === 'Heavy Rail' ||
      formattedVehicleType === 'Rail' ||
      formattedVehicleType === 'Commuter Train'
    ) {
      normalizedMode = 'Train';
    } else if (formattedVehicleType === 'Subway') {
      normalizedMode = 'Metro';
    }

    if (!modes.includes(normalizedMode)) {
      modes.push(normalizedMode);
    }
  });

  if (modes.length === 1) {
    modes.push('Public Transport');
  }

  return modes.join(' and ');
}

function getTransitSummary(route, travelMode) {
  if (travelMode !== 'TRANSIT') {
    return 'Walking';
  }

  const steps = route.legs?.flatMap((leg) => leg.steps || []) || [];

  const transitSteps = steps.filter(
    (step) => step.travelMode === 'TRANSIT' && step.transitDetails
  );

  if (transitSteps.length === 0) {
    return 'Public Transport';
  }

  const summaries = transitSteps
    .map((step) => {
      const transitDetails = step.transitDetails;
      const transitLine = transitDetails?.transitLine;
      const lineName = transitLine?.name;
      const headsign = transitDetails?.headsign;
      const vehicleType = formatVehicleType(transitLine?.vehicle?.type);

      if (lineName && headsign) {
        return `${lineName} (${headsign})`;
      }

      if (lineName) {
        return lineName;
      }

      if (vehicleType && headsign) {
        return `${vehicleType} (${headsign})`;
      }

      return vehicleType || null;
    })
    .filter(Boolean);

  if (summaries.length === 0) {
    return 'Public Transport';
  }

  const uniqueSummaries = [...new Set(summaries)];

  if (uniqueSummaries.length === 1) {
    return uniqueSummaries[0];
  }

  return `${uniqueSummaries[0]} +${uniqueSummaries.length - 1}`;
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
        'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline,routes.legs.steps.travelMode,routes.legs.steps.transitDetails.transitLine.name,routes.legs.steps.transitDetails.transitLine.vehicle.type,routes.legs.steps.transitDetails.headsign,routes.legs.steps.transitDetails.stopDetails',
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
      modeSummary: getRouteModeSummary(route, travelMode),
      lineSummary: getTransitSummary(route, travelMode),
      encodedPolyline: route.polyline?.encodedPolyline || null,
      googleMapsUrl:
        `https://www.google.com/maps/dir/?api=1` +
        `&origin=${originLat},${originLng}` +
        `&destination=${destinationLat},${destinationLng}` +
        `&travelmode=${googleMapsTravelMode}` +
        `&dir_action=navigate`,
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