const WebSocket = require("ws");
const { Linea } = require("../models/linea");
const { Location } = require("../models/ubicacion");
const { User } = require("../models/user");
const { Codigo } = require("../models/codigo");
const { Ruta } = require("../models/ruta");
const {LocationRutas} = require("../models/locationRutas");

const checkAndSendChanges = async (lineasWss) => {
  try {
    const lineas = await Linea.find({});
    const jsonData = JSON.stringify(lineas);
    lineasWss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(jsonData);
      }
    });
    //console.log("When la mandas");
  } catch (error) {
    console.error("Error:", error);
  }
};


const checkAndSendChanges2 = async (locationWss) => {
  try {
    const locations = await Location.find({});
    const jsonData = JSON.stringify(locations);
    locationWss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(jsonData);
      }
    });
    //console.log("When la mandas2");
  } catch (error) {
    console.error("Error2:", error);
  }
};

const checkAndSendChanges3 = async (userWss) => {
  try {
    const usuarios = await User.find({});
    const jsonData = JSON.stringify(usuarios);
    userWss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(jsonData);
      }
    });
    //console.log("When la mandas3");
  } catch (error) {
    console.error("Error3:", error);
  }
};

const checkAndSendChanges4 = async (codigoWss) => {
  try {
    const codigos = await Codigo.find({});
    const jsonData = JSON.stringify(codigos);
    codigoWss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(jsonData);
      }
    });
    //console.log("Mandando Codigos");
  } catch (error) {
    console.error("Error3:", error);
  }
};

const checkAndSendChanges5 = async (rutaWss) => {
  try {
    const rutas = await Ruta.find({});
    const jsonData = JSON.stringify(rutas);
    rutaWss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(jsonData);
      }
    });
    //console.log("Mandando rutas");
  } catch (error) {
    console.error("Error3:", error);
  }
};

const checkAndSendChangesLocationRutas = async (locationRutasWss) => {
  try {
    const locationRutas = await LocationRutas.find({});
    const jsonData = JSON.stringify(locationRutas);
    locationRutasWss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(jsonData);
      }
    });
    //console.log("Mandando LocationRutas");
  } catch (error) {
    console.error("Error3:", error);
  }
};
const handleWebSocketConnection = (wss) => {
  wss.on("connection", (ws) => {
    console.log("Client connected to WebSocket");

    ws.on("message", (message) => {
      console.log(`Received: ${message}`);
    });

    ws.on("close", () => {
      console.log("Client disconnected from WebSocket");
    });
  });
};

module.exports = { checkAndSendChanges,
  checkAndSendChanges2,
  checkAndSendChanges3,
  checkAndSendChanges4,
  checkAndSendChanges5,
  checkAndSendChangesLocationRutas,
   handleWebSocketConnection };

