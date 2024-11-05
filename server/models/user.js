const mongoose = require("mongoose");

const userSchema = mongoose.Schema({
  uid: {
    type: String,
    default: null,
  },
  displayName: {
    required: true,
    type: String,
    trim: true,
  },
  email: {
    required: true,
    type: String,
    trim: true,
    validate: {
      validator: (value) => {
        const re =
          /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
        return value.match(re);
      },
      message: "Please enter a valid email address",
    },
  },
  password: {
    //required: true,
    type: String,
    default: "",  // Puedes asignar un valor predeterminado si es Google Sign-In
  },
  token: {
    type: String,
  },
  modoOscuro: {
    type: Boolean,
    default: false,
  },
  verificacion: {
    type: Boolean,
    default: false,
  },
  oneSignalPlayerId: {
    type: String,
    default: null,
  },
  photoURL: {
    type: String, // Campo adicional para la URL de la foto
    default: null,
  },
  role: {
    type: String, // Rol adicional (como 'estudiante')
    default: 'usuario',
  },
  createdAt: {
    type: Date, // Fecha de creación
    default: Date.now,
  },
});

const User = mongoose.model("users", userSchema);
module.exports = { User, userSchema };
