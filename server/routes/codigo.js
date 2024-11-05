const express = require("express");
const { Codigo } = require("../models/codigo");
const bcryptjs = require("bcryptjs");
const authRouter = express.Router();
const jwt = require("jsonwebtoken");
const auth = require("../middlewares/auth");

// SIGN UP
authRouter.post("/codigo/codigo-generado", async (req, res) => {
    try {
      const { codigo, idhijo } = req.body;
  
      const existingCodigo = await Codigo.findOne({ codigo });
      if (existingCodigo) {
        return res.status(400).json({ msg: "ese codigo ya existe ?" });
      }
  
      let codigoNuevo = new Codigo({
        codigo,
        idhijo
      });
  
      codigoNuevo = await codigoNuevo.save();
      res.json(codigoNuevo);
    } catch (e) {
      console.error(e); // Log the error
      res.status(500).json({ error: e.message });
    }
  });
  

  authRouter.post("/codigo/agregar", async (req, res) => {
    try {
      const { codigo, idpadre } = req.body;
  
      const existingCodigo = await Codigo.findOne({ codigo });
      if (!existingCodigo) {
        return res.status(404).json({ msg: "Codigo not found!" });
      }
  
      if (existingCodigo.idpadre && existingCodigo.idpadre === idpadre) {
        return res.status(400).json({ msg: "idpadre already associated with this idhijo!" });
      }
  
      existingCodigo.idpadre = idpadre;
      await existingCodigo.save();
  
      await Codigo.updateOne({ codigo }, { $unset: { codigo: "" } });
  
      res.json({ msg: "Codigo asociado correctamente", existingCodigo });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
  
  
  

module.exports = authRouter;
