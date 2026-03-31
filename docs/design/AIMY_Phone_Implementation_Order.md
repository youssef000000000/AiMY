# AiMY Phone — Implementation Order (Step by Step)

**Rule:** Implement only when you ask. No step is built until you say "implement step X".

---

## Suggested order (follows user journey)

| Step | Screen | Why this order |
|------|--------|----------------|
| **1** | **Profile (tap-to-call)** | First screen in outbound journey. Rep needs a place to tap "Call" from a candidate/lead profile. Can be UI-only first (button, no real call). |
| **2** | **Incoming call** | First screen in incoming journey. Full-screen takeover, caller ID, Answer/Decline/Remind me. |
| **3** | **Active call** | Shared by both flows. Live transcript area, nudges, mute/hold/end. |
| **4** | **Mini-player** | Used when rep leaves Active call. Floating bar; "Return to call". |
| **5** | **Post-call** | After call ends. Summary, insights, action cards, save to profile. |

---

## Recommended first step: **Step 1 — Profile (tap-to-call)**

- Entry point for outbound flow.
- Can be built as static UI (profile layout + Call button).
- No Twilio needed for the first version of this screen.
- When you say "implement step 1", we build this screen only.

---

## Next steps (only when you ask)

- **Revert code:** When you want to start from zero, say "revert the code" and we can do a git revert/reset.
- **Implement step 1:** Say "implement step 1" or "implement Profile screen".
- **Implement step 2, 3, 4, 5:** Same — ask for each step when ready.

No implementation will be done before you ask.
