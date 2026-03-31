# AiMY Phone — Screens in User Journey Order

Use this order when reviewing designs, presenting to stakeholders, or implementing flows.

---

## 1. Outbound call journey (rep initiates)

| Step | Screen | PNG asset | Description |
|------|--------|-----------|-------------|
| **1** | **Profile (tap-to-call)** | `assets/aimy_phone_profile.png` | Rep views candidate/lead profile; taps **Call** when number exists. |
| **2** | **Active call** | `assets/aimy_phone_active_call.png` | Call connects; live transcript, nudges, mute/hold/end. |
| **3** | **Mini-player** *(optional)* | `assets/aimy_phone_mini_player.png` | Rep navigates away; floating bar shows caller + duration + “Return to call”. |
| **4** | **Post-call** | `assets/aimy_phone_post_call.png` | Call ends; AI summary, insights, action cards, save to profile. |

---

## 2. Incoming call journey (rep receives)

| Step | Screen | PNG asset | Description |
|------|--------|-----------|-------------|
| **1** | **Incoming call** | `assets/aimy_phone_incoming_call.png` | Full-screen takeover; caller ID, context card; Answer / Decline / Remind me. |
| **2** | **Active call** | `assets/aimy_phone_active_call.png` | Rep answered; same as outbound step 2. |
| **3** | **Mini-player** *(optional)* | `assets/aimy_phone_mini_player.png` | Same as outbound step 3. |
| **4** | **Post-call** | `assets/aimy_phone_post_call.png` | Same as outbound step 4. |

---

## 3. Quick reference — open PNGs in this order

**Outbound:**  
`aimy_phone_profile.png` → `aimy_phone_active_call.png` → `aimy_phone_mini_player.png` → `aimy_phone_post_call.png`

**Incoming:**  
`aimy_phone_incoming_call.png` → `aimy_phone_active_call.png` → `aimy_phone_mini_player.png` → `aimy_phone_post_call.png`

---

## 4. Journey diagram (logic)

```
OUTBOUND:
  [Profile] --tap Call--> [Active Call] --navigate away--> [Mini-player]
       |                         |                                |
       |                         |<------ Return to call ----------|
       |                         |
       |                         -- End call -->
       |                                |
       +--------------------------------+--> [Post-Call]

INCOMING:
  [Incoming Call] --Answer--> [Active Call] --> (same as above)
       |
       --Decline / Remind me--> (no Active Call; missed-call / reminder flow)
```

---

*All paths under `c:\Users\youssef.emad\Desktop\AiMY\assets\`*
