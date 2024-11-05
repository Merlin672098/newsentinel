const mongoose = require("mongoose");

const rutaSchema = mongoose.Schema({
  nombre: {
    type: String,
    required: true,
    trim: true,
  },
  idConductor: {
    type: String,
    required: true,
    trim: true,
  },
  numeroParadas: {
    type: Number,  
    required: true,
  },
  horaInicio: {
    type: Date,  
    required: true,
  },
  estado: {
    type: String,
    enum: ['activo', 'inactivo', 'pendiente'],  
    required: true,
    default: 'pendiente', 
  },
});

const Ruta = mongoose.model("rutas", rutaSchema);
module.exports = { Ruta, rutaSchema };
