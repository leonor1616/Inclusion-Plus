const axios = require('axios');
const db = require('../config/db');
const pool = require('../db');

const accessibilityCloudService =
  require('../services/accessibilityCloudService');

const externalLocationService =
  require('../services/externalLocationService');

exports.getCachedExternalLocations =
  async (req, res) => {

    try {

      const locations =
        await externalLocationService
          .getAllCachedLocations();

      res.json(locations);

    } catch (err) {

      console.error(err);

      res.status(500).json({
        error:
          'Failed to fetch cached external locations'
      });
    }
  };

exports.searchExternalLocations =
  async (req, res) => {

  const {
    latitude,
    longitude,
    radius = 1000
  } = req.query;

  try {

    const places =
      await accessibilityCloudService
        .fetchPlaces(
          latitude,
          longitude,
          radius
        );

    await externalLocationService
      .saveLocations(places);

    res.json(places);

  } catch (err) {

  console.error(

    err.response?.data ||

    err.stack ||

    err

  );

  res.status(500).json({

    error:

      'Failed to fetch external accessibility locations'

  });

}
};

exports.getNearbyExternalLocations =
  async (req, res) => {

  const {
    latitude,
    longitude,
    radius = 1000
  } = req.query;

  if (!latitude || !longitude) {
    return res.status(400).json({
      error:
        'latitude and longitude are required'
    });
  }

  try {

    const locations =
      await externalLocationService
        .getNearbyCachedLocations(
          latitude,
          longitude,
          radius
        );

    res.json(locations);

  } catch (err) {

    console.error(err);

    res.status(500).json({
      error:
        'Failed to fetch nearby external locations'
    });
  }
};