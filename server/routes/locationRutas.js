  const express = require("express");
  const { locationRutas, LocationSchema } = require("../models/locationRutas");
  const { Codigo } = require("../models/codigo");

  const locationRutasRouter = express.Router();
  

  locationRutasRouter.get("/api/ubiping", async (req, res) => {
    try {
      const locations = await locationRutas.find({});
      res.json(locations);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });
  module.exports = locationRutasRouter;
