const express = require("express");
const lineaRouter = express.Router();
const { Linea } = require("../models/linea");
const auth = require("../middlewares/auth");


lineaRouter.get("/get-linea", async (req, res) => {
  try {
    const lineas = await Linea.find({});
    res.json(lineas);
    
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = lineaRouter;
