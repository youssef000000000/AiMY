const express = require('express');
const dotenv = require('dotenv');
const twilio = require('twilio');

dotenv.config();

const app = express();
const port = process.env.PORT ? Number(process.env.PORT) : 3000;

app.use(express.json());
// Twilio webhooks are typically application/x-www-form-urlencoded
app.use(express.urlencoded({ extended: false }));

function normalizeE164(input) {
  if (input == null) return null;
  const raw = String(input).trim();
  // Keep leading +, remove spaces, dashes, parentheses, etc.
  const normalized = raw.replace(/[^\d+]/g, '');
  if (!normalized) return null;
  // If user passed digits without '+', add it.
  if (!normalized.startsWith('+')) return `+${normalized}`;
  return normalized;
}

function demoTwiML(message) {
  // Simple robot demo: speak a message then hang up.
  // Note: TwiML is strict XML; avoid unescaped characters.
  const safe = String(message).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  return `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say voice="alice">${safe}</Say>
  <Hangup/>
</Response>`;
}

function getTwilioClient() {
  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const authToken = process.env.TWILIO_AUTH_TOKEN;
  if (!accountSid || !authToken) {
    throw new Error('Missing TWILIO_ACCOUNT_SID or TWILIO_AUTH_TOKEN in server env.');
  }
  return twilio(accountSid, authToken);
}

app.get('/health', (req, res) => {
  res.json({ ok: true });
});

// 1) Outbound call demo: Flutter -> this endpoint -> Twilio REST Calls API.
app.post('/twilio/outbound-call', async (req, res) => {
  try {
    const toRaw = req.body?.to;
    const to = normalizeE164(toRaw);

    if (!to) {
      return res.status(400).json({ error: 'Missing/invalid "to" phone number.' });
    }

    const from = normalizeE164(process.env.TWILIO_FROM_NUMBER);
    if (!from) {
      return res.status(500).json({ error: 'Missing/invalid TWILIO_FROM_NUMBER in server env.' });
    }

    const client = getTwilioClient();

    // Outbound call will be answered by the recipient phone number,
    // then Twilio will play this robot message (no need for Twilio Voice SDK authentication).
    const message = `Hello, this is an AiMY demo robot call. Thanks for trying!`;
    const call = await client.calls.create({
      from,
      to,
      twiml: demoTwiML(message),
    });

    return res.json({ sid: call.sid, to, from });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message ?? String(err) });
  }
});

// 2) Incoming call demo (robot auto-answer):
// Configure your Twilio number's Voice webhook "Request URL" to:
//   POST https://<your-domain>/twilio/incoming
app.post('/twilio/incoming', (req, res) => {
  // Twilio sends form fields like: From, To, CallSid, etc.
  const from = normalizeE164(req.body?.From) || req.body?.From || '';
  const to = normalizeE164(req.body?.To) || req.body?.To || '';

  console.log('Incoming demo call', { from, to, callSid: req.body?.CallSid });

  const message = `Hi! This is an AiMY demo. Your call has been answered automatically by a robot.`;
  res.type('text/xml').send(demoTwiML(message));
});

app.listen(port, () => {
  console.log(`AiMY Twilio demo server listening on http://localhost:${port}`);
});

