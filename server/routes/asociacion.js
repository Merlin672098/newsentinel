const express = require("express");
const asociacionRouter = express.Router();
const { Asociacion } = require("../models/asociacion");
const auth = require("../middlewares/auth");


asociacionRouter.get("/get-asociacion", async (req, res) => {
  try {
    const asociaciones = await Asociacion.find({});
    res.json(asociaciones);
    
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = asociacionRouter;
