# AiMY Phone — Figma Design Specification

**Version:** 1.0  
**Platform:** Mobile (iOS / Android) — Primary  
**Design tool:** Figma-ready dimensions (1x density)

---

## 1. Device Frames & Canvas

| Device | Width (px) | Height (px) | Safe Area Top | Safe Area Bottom | Status Bar |
|--------|------------|-------------|---------------|------------------|------------|
| **iPhone 14** | 390 | 844 | 59 | 34 | 54 |
| **iPhone 14 Pro Max** | 430 | 932 | 59 | 34 | 59 |
| **Android (default)** | 360 | 800 | 24 | 48 | 24 |
| **Android (large)** | 412 | 915 | 24 | 48 | 24 |

**Figma canvas:** Use **390 × 844** as base frame (iPhone 14). Export @2x and @3x for assets.

---

## 2. Design Tokens

### 2.1 Spacing Scale (px)

| Token | Value | Usage |
|-------|-------|-------|
| `space-4` | 4 | Icon padding, tight gaps |
| `space-8` | 8 | Inline spacing, list item padding |
| `space-12` | 12 | Card internal padding |
| `space-16` | 16 | Section padding, button padding |
| `space-20` | 20 | Screen horizontal padding |
| `space-24` | 24 | Section gaps, large padding |
| `space-32` | 32 | Major section separation |
| `space-48` | 48 | Hero spacing |
| `space-64` | 64 | Screen vertical rhythm |

### 2.2 Border Radius (px)

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 8 | Buttons, chips |
| `radius-md` | 12 | Cards, inputs |
| `radius-lg` | 16 | Large cards, modals |
| `radius-xl` | 24 | Full-screen overlays |
| `radius-full` | 9999 | Avatars, pills |

### 2.3 Typography

| Token | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `text-display` | 28 | 700 | 34 | Incoming caller name |
| `text-h1` | 24 | 600 | 30 | Screen titles |
| `text-h2` | 20 | 600 | 26 | Section headers |
| `text-h3` | 18 | 600 | 24 | Card titles |
| `text-body` | 16 | 400 | 24 | Body copy |
| `text-body-sm` | 14 | 400 | 20 | Secondary text |
| `text-caption` | 12 | 400 | 16 | Labels, timestamps |
| `text-label` | 14 | 500 | 20 | Button labels |

**Font:** Roboto (Android), SF Pro (iOS) — or Roboto for cross-platform consistency.

### 2.4 Colors (Hex)

| Token | Hex | Usage |
|-------|-----|-------|
| `bg-primary` | #0D1117 | Screen background |
| `bg-surface` | #161B22 | Cards, surfaces |
| `bg-card` | #21262D (20% opacity) | Context cards |
| `accent-primary` | #58A6FF | Primary actions, links |
| `accent-secondary` | #A371F7 | Secondary accent |
| `accent-success` | #3FB950 | Answer button |
| `accent-error` | #F85149 | Decline, end call |
| `accent-warning` | #D29922 | Remind me |
| `text-primary` | #E6EDF3 | Primary text |
| `text-secondary` | #B1BAC4 | Secondary text |
| `text-muted` | #8B949E | Captions, hints |
| `border` | #30363D | Borders, dividers |

---

## 3. Screen Specifications

### 3.1 Incoming Call Screen (Full-Screen Takeover)

**Frame:** 390 × 844

| Element | Position | Dimensions | Specs |
|---------|----------|------------|-------|
| **Background** | Full frame | 390 × 844 | `bg-primary` (#0D1117) |
| **Status bar** | Top | 390 × 54 | System, transparent overlay |
| **"Incoming Call" label** | Y: 80 | Auto × 20 | `text-caption`, `text-muted`, center |
| **Caller avatar** | Center X, Y: 180 | 120 × 120 | Circle, `radius-full`, border 2px `border` |
| **Caller name** | Center X, Y: 320 | Auto × 34 | `text-display`, `text-primary`, center |
| **Caller subtitle** | Center X, Y: 358 | Auto × 20 | `text-body-sm`, `text-muted`, center |
| **Context card** | X: 20, Y: 400 | 350 × 140 | `bg-card`, `radius-lg`, padding 16 |
| **Context card — match score** | Card top | — | `text-caption` + badge |
| **Context card — last contact** | — | — | `text-body-sm` |
| **Context card — activity** | — | — | `text-body-sm`, max 2 lines |
| **Context card — actions** | — | — | Up to 3 chips, 8px gap |
| **Action buttons container** | Bottom | 390 × 180 | Padding 24, safe area 34 |
| **Answer button** | Left of center | 72 × 72 | Circle, `accent-success`, icon 32×32 |
| **Decline button** | Left | 72 × 72 | Circle, `accent-error`, icon 32×32 |
| **Remind me button** | Right | 72 × 72 | Circle, `accent-warning`, icon 32×32 |
| **Button labels** | Below each | Auto × 16 | `text-caption`, 8px below button |
| **Button spacing** | — | 48px between centers | — |

**Touch targets:** All buttons min 44×44; actual 72×72 for one-thumb reach.

---

### 3.2 Active Call Screen

**Frame:** 390 × 844

| Element | Position | Dimensions | Specs |
|---------|----------|------------|-------|
| **Top bar** | Y: 59 (safe) | 390 × 56 | Transparent, padding 20 |
| **Minimize icon** | X: 20, Y: 67 | 44 × 44 | Touch target |
| **Caller name** | Center | — | `text-h2`, `text-primary` |
| **Call duration** | Right of name | — | `text-body-sm`, `text-muted`, e.g. "04:32" |
| **Transcript area** | X: 20, Y: 140 | 350 × 380 | Scrollable, padding 16 |
| **Transcript line** | — | — | `text-body`, 4px gap between lines |
| **Speaker label** | — | — | `text-caption`, `text-muted`, 4px before text |
| **Nudge cards** | Right of transcript | 140 × 80 each | `bg-card`, `radius-md`, max 2 visible |
| **Nudge card** | — | 140 × 80 | Padding 12, `text-body-sm` |
| **Controls container** | Bottom | 390 × 120 | Padding 24, safe area 34 |
| **Mute button** | Left | 64 × 64 | Circle, `bg-surface`, icon 28×28 |
| **Hold button** | Center | 64 × 64 | Circle, `bg-surface`, icon 28×28 |
| **End call button** | Right | 64 × 64 | Circle, `accent-error`, icon 28×28 |
| **Control spacing** | — | 40px between centers | — |
| **Hand off to Voice AI** | Above controls | 350 × 44 | Full-width, `accent-secondary`, `radius-md` |

---

### 3.3 Post-Call Screen

**Frame:** 390 × 844 (scrollable)

| Element | Position | Dimensions | Specs |
|---------|----------|------------|-------|
| **Header** | Top | 390 × 80 | Padding 20 |
| **"Call ended"** | — | — | `text-h2`, `text-primary` |
| **Duration** | — | — | `text-body-sm`, `text-muted`, e.g. "12 min" |
| **Summary card** | Y: 100 | 350 × 200 | `bg-card`, `radius-lg`, padding 20 |
| **Summary title** | — | — | `text-h3`, margin-bottom 12 |
| **Summary body** | — | — | `text-body`, editable, line-height 24 |
| **Insights section** | Y: 320 | 350 × auto | Gap 12 between cards |
| **Insight card** | — | 350 × 72 | `bg-card`, `radius-md`, padding 16 |
| **Action cards** | — | 350 × 56 each | `bg-card`, `radius-md`, padding 16, row layout |
| **Action icon** | Left | 24 × 24 | — |
| **Action label** | — | — | `text-body` |
| **Action button** | Right | 80 × 36 | `accent-primary`, `radius-sm` |
| **Save to profile** | Bottom | 350 × 52 | Full-width primary button, `radius-md` |
| **Bottom padding** | — | 100 | Safe area + spacing |

---

### 3.4 Profile Screen (Tap-to-Call)

**Frame:** 390 × 844

| Element | Position | Dimensions | Specs |
|---------|----------|------------|-------|
| **Profile header** | Top | 390 × 160 | Padding 20 |
| **Avatar** | X: 20 | 64 × 64 | Circle, `radius-full` |
| **Name** | X: 100 | — | `text-h2`, `text-primary` |
| **Title/subtitle** | X: 100 | — | `text-body-sm`, `text-muted` |
| **Contact section** | Y: 180 | 350 × 88 | `bg-card`, `radius-lg`, padding 20 |
| **Phone number** | — | — | `text-body`, `text-primary` |
| **Call button** | Right | 56 × 56 | Circle, `accent-success`, icon 24×24 |
| **Call button** (alt) | — | 120 × 48 | Pill, `accent-success`, `radius-full`, "Call" |
| **Activity section** | Below | — | Standard list, 16px padding |

**Call button:** Visible only when phone number exists; min touch target 48×48.

---

### 3.5 Mini-Player (Floating Bar)

**Frame:** 390 × 844 (overlay on any screen)

| Element | Position | Dimensions | Specs |
|---------|----------|------------|-------|
| **Bar** | Bottom | 390 × 72 | `bg-surface`, top border 1px `border` |
| **Safe area** | — | +34 bottom | Extends into safe area |
| **Avatar** | X: 20, Y: 12 | 48 × 48 | Circle, left-aligned in bar |
| **Caller name** | X: 76 | Auto × 20 | `text-body-sm`, `text-primary` |
| **Duration** | X: 76, Y: 32 | — | `text-caption`, `text-muted` |
| **Return to call** | Right | 120 × 44 | `text-label`, `accent-primary`, tap target |
| **Bar height** | — | 72 + 34 = 106 | Total with safe area |

**Z-index:** Above content, below modals. Does not cover bottom nav (if nav exists, bar sits above it with 8px gap).

---

## 4. Component Library (Figma Components)

| Component | Variants | Specs |
|-----------|----------|-------|
| **Button — Primary** | Default, Pressed | 350×52, `radius-md`, `accent-primary` |
| **Button — Secondary** | Default, Pressed | 350×52, `radius-md`, `bg-surface`, border |
| **Button — Icon (circle)** | 72, 64, 56, 48 | Circle, icon centered |
| **Card — Context** | Default | 350×140, `radius-lg`, `bg-card` |
| **Card — Insight** | Default | 350×72, `radius-md` |
| **Avatar** | 120, 64, 48 | Circle, `radius-full` |
| **Chip** | Default | Height 32, `radius-full`, padding 12 |
| **Transcript line** | You, Caller | Speaker label + text, 4px gap |

---

## 5. UX Guidelines

- **Touch targets:** Min 44×44 pt (88×88 px @2x) for all tappable elements.
- **One-thumb zone:** Primary actions (Answer, Decline, Remind) within bottom 200px, centered.
- **Contrast:** WCAG AA minimum (4.5:1 for body text).
- **Loading states:** Skeleton for context card (2s load); shimmer animation.
- **Empty states:** "Unknown Caller" when no match; hide context card.
- **Error states:** Non-blocking toast for SDK failure; retry option.

---

## 6. Export Assets

| Asset | Size | Format |
|-------|------|--------|
| Icons (call, mute, hold, etc.) | 24, 28, 32 | SVG or PNG @2x, @3x |
| Avatars | 48, 64, 120 | PNG @2x |
| Illustrations | As needed | SVG preferred |

---

*Use this spec to build Figma frames. All dimensions in px at 1x; scale for @2x/@3x export.*
