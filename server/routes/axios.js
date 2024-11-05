const axios = require('axios');
const User = require('../models/user');

async function sendNotificationToUser(userId, title, message) {
  try {
    const user = await User.findById(userId);
    if (!user || !user.playerId) {
      throw new Error('User not found or playerId missing');
    }

    await sendNotification(user.playerId, title, message);
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

async function sendNotification(playerId, title, message) {
  const ONE_SIGNAL_APP_ID = '3902ded8-a7f8-44be-a505-c63c62240a12';
  const ONE_SIGNAL_API_KEY = 'MmIwNmI3OGMtZmFkZi00ODNiLWFhZDMtMDI1ZmMxNDg1MzRk';

  const headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Authorization': `Basic ${ONE_SIGNAL_API_KEY}`,
  };

  const body = {
    app_id: ONE_SIGNAL_APP_ID,
    include_player_ids: [playerId],
    headings: { "en": title },
    contents: { "en": message },
  };

  try {
    const response = await axios.post('https://onesignal.com/api/v1/notifications', body, { headers });
    console.log('Notification sent successfully:', response.data);
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

module.exports = {
  sendNotificationToUser,
};
