# AiMY — 60-second demo rehearsal (Priority A)

Use this in the room with your **manager** or **squad**. Total time: about **one minute** once the app is built with `config/dart_defines.json`.

## Before you enter the room (2 minutes)

1. Android emulator running **or** one test phone connected.
2. Run: `.\scripts\run_android_demo.ps1 -Device emulator-5554` (or your device id).
3. Confirm the screen shows **green “Voice ready”** (not “Demo blocked”). If red, fix `dart_defines.json` or see `docs/DEMO_RUNBOOK.md`.

## Script (what to say + do)

| Sec | Say | Do |
|-----|-----|-----|
| 0–10 | “This is the incoming-call experience for a recruiter or talent lead.” | Point at name + context card. |
| 10–25 | “We integrate real Programmable Voice—when I answer, it places an outbound call through Twilio.” | Tap **Answer**. |
| 25–45 | “Audio should connect per your TwiML app; we use this for the demo dial.” | Let the call run; speak briefly or mute. |
| 45–55 | “Hang up from the device or end on the other end.” | End call as you prefer. |
| 55–60 | “Next step is token server + real profile API for production.” | Stop sharing if screen-share. |

## If something breaks

- **Red banner before Answer:** config issue—fix defines, rebuild.
- **Error after Answer:** **Twilio → Monitor → Debugger**; confirm TwiML Voice URL and trial/verified numbers.

## One-liner status for leadership

**“Demo path: voice registers on device, outbound call on Answer; production next is server-issued tokens and live data.”**
