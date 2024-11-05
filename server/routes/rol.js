const express = require("express");
const rolRouter = express.Router();
const { Rol } = require("../models/rol");
const auth = require("../middlewares/auth");


rolRouter.get("/get-rol", async (req, res) => {
  try {
    const roles = await Rol.find({});
    res.json(roles);
    
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = rolRouter;
