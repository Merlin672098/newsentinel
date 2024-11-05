const express = require('express');
const OneSignal = require('onesignal-node');
const {User} = require('../models/user');
const router = express.Router();
const app = new OneSignal.App();
//const app = await client.getApp('<app id>');

// configure your application
app.name = 'ferrari';
app.gcm_key = 'MmIwNmI3OGMtZmFkZi00ODNiLWFhZDMtMDI1ZmMxNDg1MzRk';
app.android_gcm_sender_id = '3902ded8-a7f8-44be-a505-c63c62240a12';

const notification = new OneSignal.Notification();
notification.app_id = app.id;
// Name property may be required in some case, for instance when sending an SMS.
notification.name = "test_notification_name";
notification.contents = {
  en: "Gig'em Ags"
}

// required for Huawei
notification.headings = {
  en: "Gig'em Ags"
}

// This example uses segments, but you can also use filters or target individual users
// https://documentation.onesignal.com/reference/create-notification
notification.included_segments; ["All"]

const notificationResponse = await client.createNotification(notification);

const response = await client.createApp(app);