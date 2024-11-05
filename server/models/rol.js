const mongoose = require("mongoose");

const rolSchema = mongoose.Schema({
  nombre: {
    type: String,
    required: true,
    trim: true,
  },

});

const Rol = mongoose.model("rols", rolSchema);
module.exports =  { Rol, rolSchema };
