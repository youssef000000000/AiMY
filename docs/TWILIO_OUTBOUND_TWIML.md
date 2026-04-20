# Fix: “Could not start the call” (Voice SDK outbound)

Registration works, but **`call.place` fails** when your **TwiML App → Voice Request URL** does not return valid TwiML for an outbound client call, or the **callee** is not allowed (trial).

## 1. TwiML App Voice URL (required)

1. Twilio Console → **TwiML** → **TwiML Apps** → open the app whose SID is in `TWILIO_TWIML_APP_SID`.
2. **Voice Request URL** must be **HTTPS** and return TwiML that connects the call.

### Option A — Twilio Function (quick)

1. **Develop** → **Functions and Assets** → create a service → add a **Function** (e.g. path `/voice`).
2. Paste:

```javascript
exports.handler = function (context, event, callback) {
  const twiml = new Twilio.twiml.VoiceResponse();
  const to = event.To || event.Called;
  if (!to) {
    twiml.say('Missing destination number.');
    twiml.hangup();
    return callback(null, twiml);
  }
  twiml.dial(to);
  callback(null, twiml);
};
```

3. **Deploy**, copy the **public URL** of this function.
4. TwiML App → set **Voice Request URL** to that URL, method **HTTP POST**.

### Option B — TwiML Bin

Create a TwiML Bin that dials `{{To}}` (or use Studio) per Twilio docs for **Voice SDK outbound**.

## 2. Trial account: verify the callee

- **Phone Numbers** → **Verified Caller IDs** → add the number you dial (e.g. `+2010…`).
- Or upgrade the account for fewer restrictions.

## 3. Caller ID (sometimes required)

If Twilio Debugger shows errors about **caller ID**, your TwiML may need `<Dial callerId="+1YOUR_TWILIO_NUMBER">` instead of a bare `<Dial>`.

## 4. Debugger

**Monitor** → **Debugger** (or **Error logs**) while tapping **Answer** — the exact Twilio error explains URL vs permission vs number.

## 5. App side

- Callee must be **E.164** (e.g. `+201065332025`) — see `MockProfileRepository`.
- `TWILIO_CLIENT_IDENTITY` in `dart_defines.json` must match the **client** your TwiML/backend expects (default `aimy_client`).
