const pool = require('../db');

// Reads all cached third-party locations, independent of source provider.
async function getAllCachedLocations() {
    const result = await pool.query(`
        SELECT *
        FROM external_location
        ORDER BY updated_at DESC
    `);

    return result.rows;
}

async function getNearbyCachedLocations(
    latitude,
    longitude,
    radius = 1000
) {
    // PostGIS filters and orders by distance from the requested coordinate.
    const result = await pool.query(
        `
        SELECT
            id,
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
            ST_Distance(
                geom,
                ST_SetSRID(
                    ST_MakePoint($2, $1),
                    4326
                )::GEOGRAPHY
            ) AS distance_meters
        FROM external_location
        WHERE geom IS NOT NULL
          AND ST_DWithin(
                geom,
                ST_SetSRID(
                    ST_MakePoint($2, $1),
                    4326
                )::GEOGRAPHY,
                $3
          )
        ORDER BY distance_meters ASC
        `,
        [
            Number(latitude),
            Number(longitude),
            Number(radius)
        ]
    );

    return result.rows;
}

async function saveLocations(locations) {
    for (const location of locations) {
        // Upsert keeps the cache fresh when the same provider/source id is
        // fetched again from Google Places or Accessibility Cloud.
        await pool.query(
            `
            INSERT INTO external_location (
                source,
                external_source_id,
                name,
                category,
                latitude,
                longitude,
                geom,
                source_url,
                raw_accessibility_data
            )
            VALUES (
                $1,
                $2,
                $3,
                $4,
                $5,
                $6,
                ST_SetSRID(
                    ST_MakePoint(
                        $8,
                        $9
                    ),
                    4326
                )::GEOGRAPHY,
                $7,
                $10
            )

            ON CONFLICT (
                source,
                external_source_id
            )

            DO UPDATE SET
                name = EXCLUDED.name,
                category = EXCLUDED.category,
                latitude = EXCLUDED.latitude,
                longitude = EXCLUDED.longitude,
                geom = EXCLUDED.geom,
                source_url = EXCLUDED.source_url,
                raw_accessibility_data = EXCLUDED.raw_accessibility_data,
                updated_at = NOW()
            `,
            [
                location.source,
                location.external_source_id,
                location.name,
                location.category,

                Number(location.latitude),
                Number(location.longitude),

                location.source_url,

                Number(location.longitude), // $8
                Number(location.latitude),  // $9

                location.raw_accessibility_data
                    ? JSON.stringify(location.raw_accessibility_data)
                    : null // $10
            ]
        );
    }
}

module.exports = {
    getAllCachedLocations,
    getNearbyCachedLocations,
    saveLocations
};
