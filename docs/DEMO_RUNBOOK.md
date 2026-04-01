# AiMY — Demo line runbook

**Audience:** engineers preparing demos for **squad** and **management**.  
**Goal:** repeatable stakeholder demos without mixing demo shortcuts into a future **production** release line.

---

## 1. Branch strategy (keep demo and production separate)

| Branch / line | When to use | Typical contents |
|----------------|-------------|------------------|
| **`demo`** | Day-to-day work for stakeholder demos | Mock data, client-side Twilio JWT for local/dev, UI polish, feature spikes |
| **`main`** | Integration: what the team agrees is “current” | Merge `demo` here when the demo is stable or you need a shared baseline |
| **`production`** (create later) | Store / regulated releases | Token server, no API secrets in the app, real APIs, monitoring, signing & CI |

**Rule of thumb:** ship risky or “quick demo only” changes on **`demo`** first. When behavior is approved, merge **`demo` → `main`**. Open **`production`** (or release flavors) only when you are ready to remove client-side secrets and wire a backend.

```mermaid
flowchart LR
  demo[demo branch]
  main[main branch]
  prod[production branch later]
  demo -->|merge when stable| main
  main -->|fork when ready| prod
```

### Git commands (copy-paste)

```bash
# Start demo work
git checkout demo
git pull origin demo

# After changes
git add -A
git commit -m "feat(demo): short description"
git push origin demo

# Promote a stable demo to integration
git checkout main
git pull origin main
git merge demo
git push origin main
```

---

## 2. Before the demo (checklist)

Use this **in order** so the room does not lose time to environment issues.

| Step | Check |
|------|--------|
| 1 | **Platform:** Use **Android** or **iOS** device/emulator. Twilio Programmable Voice in this project is **not** supported on Windows/Linux desktop (UI-only there). |
| 2 | **Twilio:** API Key + TwiML App configured; Voice Request URL returns valid TwiML for outbound. Use **Monitor → Debugger** if calls fail. |
| 3 | **Firebase (Android):** FCM is used for Twilio registration; define Firebase keys below for Android runs. |
| 4 | **Callee number:** E.164 in `lib/data/repositories/mock_profile_repository.dart` matches the number you intend to dial for the demo. |
| 5 | **Permissions:** Microphone (and phone on Android) granted when prompted. |

**Demo flow in the app:** launch → incoming-call style screen → **Answer** starts the outbound test call → verify audio → end call.

---

## 3. Secrets and `--dart-define`

Secrets are passed at **build/run time**, not committed to git.

### Twilio (required for real Voice SDK registration)

| Define | Notes |
|--------|--------|
| `TWILIO_ACCOUNT_SID` | `AC…` |
| `TWILIO_API_KEY_SID` | `SK…` |
| `TWILIO_API_KEY_SECRET` | API Key secret |
| `TWILIO_TWIML_APP_SID` | TwiML Application `AP…` |
| `TWILIO_CLIENT_IDENTITY` | Optional; default in app is `aimy_client` |

### Firebase (required on **Android** for this integration)

| Define | Notes |
|--------|--------|
| `FIREBASE_API_KEY` | From Firebase project settings |
| `FIREBASE_PROJECT_ID` | |
| `FIREBASE_MESSAGING_SENDER_ID` | |
| `FIREBASE_ANDROID_APP_ID` | Android app in Firebase |
| `FIREBASE_IOS_APP_ID` | iOS app (when running on iPhone) |
| `FIREBASE_STORAGE_BUCKET` | Optional; defaults if omitted |

Implementation reference: `lib/core/config/twilio_config.dart`, `lib/core/config/firebase_options_dev.dart`.

### Example: PowerShell (Windows)

Replace placeholder values. Line continuation uses backtick `` ` ``.

```powershell
cd C:\path\to\AiMY

& "C:\src\flutter\flutter\bin\flutter.bat" run `
  --dart-define=TWILIO_ACCOUNT_SID=ACxxxxxxxx `
  --dart-define=TWILIO_API_KEY_SID=SKxxxxxxxx `
  --dart-define=TWILIO_API_KEY_SECRET=xxxxxxxx `
  --dart-define=TWILIO_TWIML_APP_SID=APxxxxxxxx `
  --dart-define=FIREBASE_API_KEY=xxxxxxxx `
  --dart-define=FIREBASE_PROJECT_ID=your-project `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=xxxxxxxx `
  --dart-define=FIREBASE_ANDROID_APP_ID=1:xxxxxxxx:android:xxxxxxxx
```

### Example: bash (macOS / Linux)

```bash
flutter run \
  --dart-define=TWILIO_ACCOUNT_SID=ACxxxxxxxx \
  --dart-define=TWILIO_API_KEY_SID=SKxxxxxxxx \
  --dart-define=TWILIO_API_KEY_SECRET=xxxxxxxx \
  --dart-define=TWILIO_TWIML_APP_SID=APxxxxxxxx \
  --dart-define=FIREBASE_API_KEY=xxxxxxxx \
  --dart-define=FIREBASE_PROJECT_ID=your-project \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=xxxxxxxx \
  --dart-define=FIREBASE_ANDROID_APP_ID=1:xxxxxxxx:android:xxxxxxxx
```

---

## 4. Troubleshooting (short)

| Symptom | What to check |
|---------|----------------|
| Red error about Twilio / `setTokens` | Defines incomplete; TwiML App SID; Twilio Debugger; on **iOS**, VoIP / PushKit setup |
| Firebase / FCM | `FIREBASE_*` defines for the platform; network; correct Android app id in Firebase |
| “Not supported on Windows” | Run on Android or iOS, not Windows desktop |
| Call does not connect | TwiML App **Voice URL** must return TwiML that dials or routes the outbound leg correctly |

---

## 5. After the demo (when you open the “production copy”)

Do **not** block demos on these; track them for the production line:

- Issue **Voice JWTs from a backend**; remove API Key Secret from client builds.
- Replace **mock profile** with real API + authentication.
- Add **inbound + push** only if the product requires ringing the app for real incoming calls.
- Harden CI, secrets management, and app signing for store builds.

---

## 6. Document owner

Update this runbook when the demo flow or required defines change (e.g. new env vars or a new entry screen).
