const mongoose = require("mongoose");

const asociacionSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: true,
    trim: true,
  },

  fechaCreacion: {
    type: Date,
  },
});

const Asociacion = mongoose.model("Asociacion", asociacionSchema);
module.exports = { Asociacion, asociacionSchema };
