const externalLocationService = require('./externalLocationService');
const accessibilityCloudService = require('./accessibilityCloudService');
const googlePlacesService = require('./googlePlacesService');
const placeMergeService = require('./placeMergeService');

const MIN_RESULTS = 20;

// Main map aggregation service: read nearby cached places first, then enrich
// the cache from external providers if the local result set is too small.
async function getMapPlaces(latitude, longitude, radius = 1000) {
    let cachedPlaces = await externalLocationService.getNearbyCachedLocations(
        latitude,
        longitude,
        radius
    );

    if (cachedPlaces.length < MIN_RESULTS) {
        // Providers are merged before persisting so duplicates from different
        // sources do not flood the map with repeated markers.
        const accessibilityCloudPlaces =
            await accessibilityCloudService.fetchPlaces(
                latitude,
                longitude,
                radius
            );

        const googlePlaces =
            await googlePlacesService.fetchPlaces(
                latitude,
                longitude,
                radius
            );

        const mergedPlaces =
            placeMergeService.mergeAndDeduplicatePlaces([
                ...accessibilityCloudPlaces,
                ...googlePlaces
            ]);

        await externalLocationService.saveLocations(mergedPlaces);

        cachedPlaces = await externalLocationService.getNearbyCachedLocations(
            latitude,
            longitude,
            radius
        );
    }

    return {
        count: cachedPlaces.length,
        accessibility_count: cachedPlaces.filter(
            (place) => place.source === 'accessibility_cloud'
        ).length,
        google_count: cachedPlaces.filter(
            (place) => place.source === 'google_places'
        ).length,
        places: cachedPlaces.map((place) => ({
            id: `external_${place.id}`,
            external_location_id: place.id,
            external_source_id: place.external_source_id,
            name: place.name,
            category: place.category,
            latitude: Number(place.latitude),
            longitude: Number(place.longitude),
            source: place.source,
            source_url: place.source_url,
            distance_meters: Number(place.distance_meters),
            raw_accessibility_data: place.raw_accessibility_data,
            user_review_count: place.user_review_count,
            average_user_rating: place.average_user_rating,
            accessibility_features: []
        }))
    };
}

module.exports = {
    getMapPlaces
};
