const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');

admin.initializeApp();
const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Protect with a simple header secret to avoid casual abuse. Replace with proper auth in production.
// Prefer functions config: `firebase functions:config:set invite.secret="VALUE"`
const INVITE_SECRET = (functions.config && functions.config().invite && functions.config().invite.secret) || process.env.INVITE_SECRET || 'change-me';

app.post('/invite', async (req, res) => {
  try {
    const header = req.get('x-invite-secret') || '';
    if (header !== INVITE_SECRET) {
      return res.status(403).json({ error: 'forbidden' });
    }
    const { name, email, daysActive } = req.body;
    if (!email) return res.status(400).json({ error: 'missing email' });

    // create auth user with a random temporary password
    const tempPassword = Math.random().toString(36).slice(-10) + 'A1!';
    const userRecord = await admin.auth().createUser({ email: email, password: tempPassword, displayName: name });

    // set a custom claim or metadata if needed
    // await admin.auth().setCustomUserClaims(userRecord.uid, { role: 'user' });

    // create a password reset link
    const resetLink = await admin.auth().generatePasswordResetLink(email);

    // respond with link (in production you should email it from the server using SMTP or SendGrid)
    return res.json({ uid: userRecord.uid, resetLink });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message || String(err) });
  }
});

exports.api = functions.https.onRequest(app);
