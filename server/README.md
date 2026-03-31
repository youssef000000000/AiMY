# AiMY Twilio Demo Server (Robot Answer)

This server provides two endpoints for the AiMY demo:

1. **Outbound demo call** (triggered by the Flutter first screen)
   - `POST /twilio/outbound-call`
   - Body: `{ "to": "+1XXXXXXXXXX" }`
   - Uses Twilio REST `calls.create(...)` with inline TwiML, so **no Voice SDK access tokens** are required.

2. **Incoming demo call** (robot auto-answer)
   - Twilio Voice webhook should point to `POST /twilio/incoming`
   - It returns TwiML that plays a robot message and hangs up.

## Setup

1. Copy env file:
   - `server/.env.example` -> `server/.env`

2. Fill in:
   - `TWILIO_ACCOUNT_SID`
   - `TWILIO_AUTH_TOKEN`
   - `TWILIO_FROM_NUMBER` (must be a verified Twilio Voice number)
   - `SERVER_PUBLIC_BASE_URL` (only needed if you later add links)

3. Install + run:
   - `cd server`
   - `npm install`
   - `node index.js` (runs on `http://localhost:3000`)

## Incoming calls (robot)

Twilio needs a **public** URL to reach your webhook:

- Start a tunnel (example): `ngrok http 3000`
- In the Twilio Console:
  - Phone Numbers -> (your number) -> Voice & Fax
  - Set **A call comes in** to:
    - `https://<your-ngrok-domain>/twilio/incoming`
  - Set method to **POST**.

Now if you call your Twilio number, Twilio will answer automatically with the robot message.

## Outbound calls (from the app)

On Android emulator, the Flutter app calls:
- `http://10.0.2.2:3000/twilio/outbound-call`

Update `MockProfileRepository` to return a real E.164 phone number in `phoneNumber` for the Call button to work.

