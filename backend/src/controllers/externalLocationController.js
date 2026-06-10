const axios = require('axios');
const db = require('../config/db');
const pool = require('../db');

exports.getCachedExternalLocations = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM external_location
       ORDER BY updated_at DESC`
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: 'Failed to fetch cached external locations'
    });
  }
};

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
        wheelchair_accessible:
          properties.accessibility?.accessibleWith?.wheelchair ?? null,
        source_url: properties.infoPageUrl || null,
        source: 'accessibility_cloud'
      };
    });

    // Guardar na BD
    for (const location of normalizedLocations) {
      await db.query(
        `
        INSERT INTO external_location (
          source,
          external_source_id,
          name,
          category,
          latitude,
          longitude,
          source_url
        )
        VALUES ($1,$2,$3,$4,$5,$6,$7)
        ON CONFLICT (source, external_source_id) 
        DO UPDATE SET
          name = EXCLUDED.name,
          category = EXCLUDED.category,
          latitude = EXCLUDED.latitude,
          longitude = EXCLUDED.longitude,
          source_url = EXCLUDED.source_url,
          updated_at = NOW()
        `,
        [
          location.source,
          location.external_source_id,
          location.name,
          location.category,
          location.latitude,
          location.longitude,
          location.source_url
        ]
      );
    }

    res.json(normalizedLocations);

  } catch (err) {
    console.error(err.response?.data || err.message);

    res.status(500).json({
      error: 'Failed to fetch external accessibility locations'
    });
  }
};

exports.getNearbyExternalLocations = async (req, res) => {
  const { latitude, longitude, radius = 1000 } = req.query;

  if (!latitude || !longitude) {
    return res.status(400).json({
      error: 'latitude and longitude are required'
    });
  }

  try {
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
        user_review_count,
        average_user_rating,
        ST_Distance(
          geom,
          ST_SetSRID(ST_MakePoint($2, $1), 4326)::GEOGRAPHY
        ) AS distance_meters
      FROM external_location
      WHERE geom IS NOT NULL
        AND ST_DWithin(
          geom,
          ST_SetSRID(ST_MakePoint($2, $1), 4326)::GEOGRAPHY,
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

    res.json(result.rows);
  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to fetch nearby external locations'
    });
  }
};