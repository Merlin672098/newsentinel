const mongoose = require("mongoose");

const codigoSchema = mongoose.Schema({
  codigo: {
    type: String,
    trim: true,
  },
  idhijo: {
    required: true,
    type: String,
    trim: true,
  },
  idpadre: {
    type: String,
    trim: true,
  },
});

const Codigo = mongoose.model("codigos", codigoSchema);
module.exports = { Codigo, codigoSchema };
    