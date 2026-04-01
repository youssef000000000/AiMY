# AiMY — Demo line (squad & manager)

Use this branch and checklist when you demo to **MySquad** and your **manager**. Production hardening comes later on a separate line (see below).

## Branch strategy

| Line | Purpose |
|------|--------|
| **`demo`** | Stakeholder demos: UI polish, Twilio test calls, mock data. Iterate here first. |
| **`main`** | Default integration branch; can match `demo` until you split. |
| **`production`** (later) | Release builds: token server, no secrets in app, real APIs, monitoring. Create when you are ready to fork from `demo`/`main`. |

**Daily work for demos:** `git checkout demo` → implement → push `origin demo`. Merge into `main` when the team agrees the demo is stable.

## Before the room (5-minute checklist)

1. **Device:** Android emulator or physical phone (Twilio Voice does not run on Windows desktop in this project).
2. **Secrets:** Run with `--dart-define` for Twilio (`TWILIO_ACCOUNT_SID`, `TWILIO_API_KEY_SID`, `TWILIO_API_KEY_SECRET`, `TWILIO_TWIML_APP_SID`) and Firebase (see `lib/core/config/firebase_options_dev.dart`).
3. **TwiML:** Twilio Console → your TwiML App → Voice URL returns valid TwiML for outbound (check **Monitor → Debugger** if the call fails).
4. **Test number:** `MockProfileRepository` sets the callee E.164; change it if your demo calls a different phone.
5. **Story:** Open app → incoming-call style screen → **Answer** places the outbound test call → confirm audio → hang up.

## After the demo (production copy later)

- Move JWT minting to a **backend**; stop shipping API secrets in client builds.
- Replace **mock profile** with your API and auth.
- Add **inbound + push** only if the product requires it.

This file is scoped to the **demo** track; keep production requirements in your release checklist when you create the `production` branch or flavor.
