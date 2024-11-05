const mongoose = require("mongoose");

const LocationSchema = mongoose.Schema({
  name: {
    required: true,
    type: String,
    trim: true,
  },
  latitude: {
    required: true,
    type: Number,
    trim: true,
  },
  longitude: {
    required: true,
    type: Number,
    trim: true,
  },
  linea: {
    required: true,
    type: String,
  },
  id_usuario: {
    required: true,
    type: String,
  },
});

// Modelo
const Location = mongoose.model("Location", LocationSchema);

// Exportar el modelo y el esquema
module.exports = { Location, LocationSchema };
