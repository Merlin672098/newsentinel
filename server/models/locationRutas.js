const mongoose = require("mongoose");

const locationRutasSchema = mongoose.Schema({
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
  idruta: {
    required: true,
    type: String,
  },
  id_padre: {
    required: true,
    type: String,
  },
  visible: {
    required: true,
    type: Boolean,
    default: true,
  },
});

const LocationRutas = mongoose.model("locationrutas", locationRutasSchema);

module.exports = { LocationRutas, locationRutasSchema };
