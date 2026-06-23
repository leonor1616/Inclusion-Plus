const pool = require('../db');
const mapPlaceService = require('../services/mapPlaceService');
const googlePlacesService = require('../services/googlePlacesService');

// Map endpoints expose cached/merged external locations to the Flutter map.
exports.getMapPlaces = async (req, res) => {
    const { latitude, longitude, radius = 1000 } = req.query;

    if (!latitude || !longitude) {
        return res.status(400).json({
            error: 'latitude and longitude are required'
        });
    }

    try {
        const result = await mapPlaceService.getMapPlaces(
            latitude,
            longitude,
            radius
        );

        res.json(result);
    } catch (err) {
        console.error('MAP PLACES ERROR:', err);

        res.status(500).json({
            error: 'Failed to fetch map places'
        });
    }
};

exports.testGooglePlaces = async (req, res) => {
    const { latitude, longitude, radius = 1000 } = req.query;

    if (!latitude || !longitude) {
        return res.status(400).json({
            error: 'latitude and longitude are required'
        });
    }

    try {
        const places = await googlePlacesService.fetchPlaces(
            latitude,
            longitude,
            radius
        );

        res.json({
            count: places.length,
            places
        });
    } catch (err) {
        console.error('TEST GOOGLE PLACES ERROR:', err);

        res.status(500).json({
            error: 'Failed to test Google Places'
        });
    }
};

exports.searchMapPlaces = async (req, res) => {
    const { query, latitude, longitude } = req.query;
    const cleanQuery = String(query || '').trim();

    const hasLocation = latitude !== undefined && longitude !== undefined;

    const latitudeValue = hasLocation ? Number(latitude) : null;

    const longitudeValue = hasLocation ? Number(longitude) : null;

    

    if (

        hasLocation &&

        (!Number.isFinite(latitudeValue) || !Number.isFinite(longitudeValue))

    ) {

        return res.status(400).json({

            error: 'latitude and longitude must be valid numbers',

        });

    }

    if (cleanQuery.length < 2) {
        return res.json({
            count: 0,
            places: [],
        });
    }

    const normalizedQuery = cleanQuery
        .toLowerCase()
        .replace(/[-_]+/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();

    const searchTerms = normalizedQuery
        .split(' ')
        .filter(Boolean);

    const searchPatterns = searchTerms.map((term) => `%${term}%`);
    const fullSearchPattern = `%${normalizedQuery}%`;

    // Search first uses the local external_location cache; Google Places is
    // queried only when the cache cannot satisfy the search well enough.
    const searchSql = `
    SELECT
      id AS external_location_id,
      source,
      external_source_id,
      name,
      category,
      latitude,
      longitude,
      source_url,
      raw_accessibility_data,
      user_review_count,
      average_user_rating,
      CASE
  WHEN $3::double precision IS NOT NULL
    AND $4::double precision IS NOT NULL
    AND geom IS NOT NULL
  THEN ST_Distance(
    geom,
    ST_SetSRID(
      ST_MakePoint($4::double precision, $3::double precision),
      4326
    )::geography
  )
  ELSE NULL
END AS distance_meters
    FROM external_location
    WHERE
      NOT EXISTS (
        SELECT 1
        FROM unnest($1::text[]) AS term
        WHERE NOT (
          LOWER(
            REPLACE(
              REPLACE(
                COALESCE(name, ''),
                '-',
                ' '
              ),
              '_',
              ' '
            )
          ) ILIKE term
          OR LOWER(
            REPLACE(
              REPLACE(
                COALESCE(category, ''),
                '-',
                ' '
              ),
              '_',
              ' '
            )
          ) ILIKE term
        )
      )
    ORDER BY
      CASE
        WHEN LOWER(
          REPLACE(
            REPLACE(
              COALESCE(name, ''),
              '-',
              ' '
            ),
            '_',
            ' '
          )
        ) ILIKE $2 THEN 0
        ELSE 1
      END,
distance_meters ASC NULLS LAST,
CASE
  WHEN source = 'google_places' THEN 0
        ELSE 1
      END,
      name ASC
    LIMIT 30
  `;

    try {
        let result = await pool.query(
            searchSql,
            [searchPatterns, fullSearchPattern, latitudeValue, longitudeValue]
        );

        if (result.rows.length < 5) {
            const googlePlaces = await googlePlacesService.searchPlacesByText(cleanQuery);

            if (googlePlaces.length > 0) {
                await require('../services/externalLocationService').saveLocations(googlePlaces);
            }

            result = await pool.query(
                searchSql,
                [searchPatterns, fullSearchPattern, latitudeValue, longitudeValue]
            );
        }

        res.json({
            count: result.rows.length,
            places: result.rows.map((place) => ({
                id: `external_${place.external_location_id}`,
                ...place,
            })),
        });
    } catch (err) {
        console.error('MAP SEARCH ERROR:', err.response?.data || err);
        res.status(500).json({
            error: 'Failed to search map places',
        });
    }
};
