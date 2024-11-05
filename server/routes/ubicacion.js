  const express = require("express");
  const { Location, LocationSchema } = require("../models/ubicacion");
  const { Codigo } = require("../models/codigo");

  const ubiRouter = express.Router();

  ubiRouter.post("/api/ubiping", async (req, res) => {
    try {
      const { name, latitude, longitude, linea, id_usuario } = req.body;

      const existingLocation = await Location.findOne({ id_usuario });

      if (existingLocation) {
        await Location.findOneAndUpdate(
          { id_usuario },
          { latitude, longitude },
          { new: true }
        );
        res.status(200).json({ message: 'Ubicación actualizada correctamente' });
      } else {
        let newLocation = new Location({
          name,
          latitude,
          longitude,
          linea,
          id_usuario
        });
        await newLocation.save();
        res.status(201).json({ message: 'Ubicación guardada correctamente' });
      }
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });

  ubiRouter.post("/api/mandarUbiPadre", async (req, res) => {
    try {
      const { name, latitude, longitude, id_usuario } = req.body;
  
      const codigo = await Codigo.findOne({ idpadre: id_usuario });
  
      if (!codigo) {
        return res.status(404).json({ message: 'No se encontró el idpadre en la colección de codigos' });
      }
  
      const linea = codigo.idhijo;
  
      const existingLocation = await Location.findOne({ id_usuario });
  
      if (existingLocation) {
        await Location.findOneAndUpdate(
          { id_usuario },
          { latitude, longitude, linea },
          { new: true }
        );
        res.status(200).json({ message: 'Ubicación actualizada correctamente' });
      } else {
        let newLocation = new Location({
          name,
          latitude,
          longitude,
          linea,
          id_usuario
        });
        await newLocation.save();
        res.status(201).json({ message: 'Ubicación guardada correctamente' });
      }
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });
  

  ubiRouter.get("/api/ubiping", async (req, res) => {
    try {
      const locations = await Location.find({});
      res.json(locations);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });
  module.exports = ubiRouter;
