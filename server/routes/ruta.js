const express = require("express");
const rutaRouter = express.Router();
const { Ruta } = require("../models/ruta");
const auth = require("../middlewares/auth");


rutaRouter.get("/get-ruta", async (req, res) => {
  try {
    const rutas = await Ruta.find({});
    res.json(rutas);
    
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = rutaRouter;

