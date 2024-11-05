const express = require("express");
const { User } = require("../models/user");
const bcryptjs = require("bcryptjs");
const authRouter = express.Router();
const jwt = require("jsonwebtoken");
const auth = require("../middlewares/auth");
const axios = require('axios');
//const sendNotificationToUser = require('../routes/axios');
const OneSignal = require('@onesignal/node-onesignal');
const { OAuth2Client } = require('google-auth-library');

const client = new OAuth2Client('578322082537-lpsbtdesf64jv3pga0rofkb59mail2p9.apps.googleusercontent.com'); 

//const sendNotificationToUser = require('../routes/notificacion');
const configuration = OneSignal.createConfiguration({
  userKey: 'N2Y1MTA3MTktNGUzOC00MzU4LTg5Y2UtNzZiNzk1YjMxYzBk',
  appKey: 'MmIwNmI3OGMtZmFkZi00ODNiLWFhZDMtMDI1ZmMxNDg1MzRk',
});

const APP_ID = '3902ded8-a7f8-44be-a505-c63c62240a12';
const API_KEY = 'MmIwNmI3OGMtZmFkZi00ODNiLWFhZDMtMDI1ZmMxNDg1MzRk';


const clientOneSignal = new OneSignal.DefaultApi(configuration);
/*const client = new OneSignal.Client({
  userAuthKey: 'N2Y1MTA3MTktNGUzOC00MzU4LTg5Y2UtNzZiNzk1YjMxYzBk',
  app: { appAuthKey: 'MmIwNmI3OGMtZmFkZi00ODNiLWFhZDMtMDI1ZmMxNDg1MzRk', appId: '3902ded8-a7f8-44be-a505-c63c62240a12' }
});*/
// SIGN UP

// Verifica el token de Google
/*async function verifyGoogleToken(idToken) {
  const ticket = await client.verifyIdToken({
    idToken: idToken,
    audience: '511325894043-pss7srjef6j4tmu9s76gar2po0viuusc.apps.googleusercontent.com',
  });
  const payload = ticket.getPayload();
  return payload;
}
*/

authRouter.post('/api/signin', async (req, res) => {
  try {
    const { email, password, playerId } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ msg: 'User with this email does not exist!' });
    }

    const isMatch = await bcryptjs.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Incorrect password.' });
    }

    const token = jwt.sign({ id: user._id }, 'passwordKey');

    user.oneSignalPlayerId = playerId; 
    user.token = token;
    await user.save(); 

    await sendNotificationToUser(user);

    res.json({ token, ...user._doc });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});



// SIGN IN (Inicia sesión con Google)
authRouter.post('/api/signinGoogle', async (req, res) => {
  try {
    const { uid, displayName, email, playerId, photoURL, role, createdAt } = req.body;
    
    console.log('Datos recibidos:');
    console.log('UID:', uid);
    console.log('Display Name:', displayName);
    console.log('Email:', email);
    console.log('Player ID:', playerId);
    console.log('Photo URL:', photoURL);
    console.log('Role:', role);
    console.log('Created At:', createdAt);

    let user = await User.findOne({ email });
    
    if (!user) {
      user = new User({
        uid, 
        displayName: displayName,
        email,
        password: '',
        modoOscuro: false,
        verificacion: false,
        oneSignalPlayerId: playerId, 
        photoURL,
        role,
        createdAt,
      });

      await user.save();
    } else {
      user.oneSignalPlayerId = playerId;
      await user.save();
    }
    
    const token = jwt.sign({ id: user._id }, 'passwordKey', { expiresIn: '1h' }); // Token con expiración de 1 hora

    res.json({ token, ...user._doc });

  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});



authRouter.post("/api/signup", async (req, res) => {
  try {
    const { name, email, password,type } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res
        .status(400)
        .json({ msg: "User with same email already exists!" });
    }

    const hashedPassword = await bcryptjs.hash(password, 8);

    let user = new User({
      email,
      password: hashedPassword,
      name,
      type,
      modoOscuro: false,
      verificacion: false,
    });

    user = await user.save();
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/*
authRouter.post("/api/signin", async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(400)
        .json({ msg: "User with this email does not exist!" });
    }

    const isMatch = await bcryptjs.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Incorrect password." });
    }

    const token = jwt.sign({ id: user._id }, "passwordKey");

    user.token = token;
    await user.save();

    res.json({ token, ...user._doc });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

authRouter.post("/api/signin", async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(400)
        .json({ msg: "User with this email does not exist!" });
    }

    const isMatch = await bcryptjs.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Incorrect password." });
    }

    const token = jwt.sign({ id: user._id }, "passwordKey");
    res.json({ token, ...user._doc });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});*/





const checkSubscriptionStatus = async (playerId) => {
  try {
    const response = await axios.get(`https://onesignal.com/api/v1/players/${playerId}?app_id=${APP_ID}`, {
      headers: {
        'Authorization': `Basic ${API_KEY}`
      }
    });

    console.log('Subscription status:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error checking subscription status:', error.response ? error.response.data : error.message);
    throw error;
  }
};

const sendNotificationToUser = async (user) => {
  const playerId = user.oneSignalPlayerId;
  console.log('Player ID:', playerId);
  if (!playerId) {
    console.error('Player ID is missing');
    return;
  }


  try {
    const notification = {
      app_id: APP_ID,
      contents: { en: 'Bienvenido aaaa' },
      include_player_ids: [playerId],
    };

    console.log('Notification data:', notification); 

    const response = await axios.post('https://onesignal.com/api/v1/notifications', notification, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${API_KEY}`
      }
    });

    console.log(`Notification sent successfully. Response:`, response.data);
  } catch (error) {
    console.error('Error sending notification:', error.response ? error.response.data : error.message);
    throw error; 
  }
};



const listPlayers = async () => {
  try {
    const response = await axios.get(`https://onesignal.com/api/v1/players?app_id=${APP_ID}&limit=50`, {
      headers: {
        'Authorization': `Basic ${API_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    return response.data.players;
  } catch (error) {
    console.error('Error listing players:', error.response ? error.response.data : error.message);
    throw error;
  }
};

listPlayers().then(players => {
  console.log('List of players:', players);
}).catch(error => {
  console.error('Error:', error);
});

authRouter.post("/tokenIsValid", async (req, res) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) return res.json(false);
    const verified = jwt.verify(token, "passwordKey");
    if (!verified) return res.json(false);

    const user = await User.findById(verified.id);
    if (!user) return res.json(false);
    res.json(true);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get user data
authRouter.get("/", auth, async (req, res) => {
  const user = await User.findById(req.user);
  res.json({ ...user._doc, token: req.token });
});

module.exports = authRouter;

