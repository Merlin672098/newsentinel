const mongoose = require("mongoose");

const lineaSchema = mongoose.Schema({
  nombre: {
    type: String,
    required: true,
    trim: true,
  },
  idAsociacion: {
    type: String,
    required: true,
    trim: true,
  },
  numeroParadas: {
    type: String,
    required: true,
  },
});

const Linea = mongoose.model("lineas", lineaSchema);
module.exports =  { Linea, lineaSchema };
