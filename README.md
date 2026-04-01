# AiMY — AI Dashboard UI

UI-only Flutter prototype for the AiMY AI assistant dashboard (dark futuristic theme, Material 3).

## Demo vs production

- **Stakeholder demos (squad, manager):** work on the **`demo`** branch and follow [`docs/DEMO_RUNBOOK.md`](docs/DEMO_RUNBOOK.md) (devices, Twilio, checklist).
- **Production later:** fork or branch `production` when you are ready for token servers, real APIs, and no client-side secrets—not required for the first demos.

## Run the app

1. **Ensure Flutter is installed** and on your PATH.

2. **Generate platform folders** (if you don't have `android/`, `ios/`, etc.):
   ```bash
   flutter create .
   ```
   Use the existing project name when prompted so `lib/` is kept.

3. **Install dependencies and run:**
   ```bash
   flutter pub get
   flutter run
   ```

Choose a device (Chrome, Windows, Android, etc.) when prompted.

## Structure

```
lib/
  core/theme/     # AppTheme, AppColors, AppTypography
  models/         # ChatItem, NavItem
  widgets/        # Sidebar, TopNav, PromptCard, AIInputField, ChatListItem
  screens/        # DashboardScreen
  main.dart
```

## Features (UI only)

- **Sidebar:** App title "AiMY", New Chat, Search chats, scrollable chat list, selected highlight
- **Top nav:** Pill buttons (AiMY Sales, AiMY Widgets, AiMY Intelligence) with active state
- **Main area:** Title, subtitle, grid of suggestion prompt cards (rounded, glow border, hover/tap animation)
- **Bottom input:** Rounded AI-style field, placeholder "Start to find the best talent...", mic + send (Gemini-style)
- **Responsive:** Desktop (sidebar + content), Tablet (narrower sidebar), Mobile (drawer + single column)
- **Theme:** Dark gradient background, glassmorphism-style cards, neon blue/purple accents

No backend or AI integration in this phase.

## Link with Android Studio

1. **Open the project**
   - In Android Studio: **File → Open**
   - Select the project root folder: `c:\Users\youssef.emad\Desktop\AiMY` (the folder that contains `pubspec.yaml` and `android/`).
   - Click **OK**. Android Studio will index the project.

2. **Flutter SDK**
   - If prompted, set the **Flutter SDK path** (e.g. `C:\src\flutter` or where you installed Flutter).
   - Ensure the **Flutter** and **Dart** plugins are installed: **File → Settings → Plugins** → search for "Flutter" and "Dart".

3. **Generate `local.properties` (if needed)**
   - From the project root, run in a terminal (or Android Studio’s Terminal):
     ```bash
     flutter pub get
     ```
   - This creates `android/local.properties` with your Flutter SDK path so the Android build can find it.

4. **Run the app**
   - Select the run configuration **main.dart** (or create one: **Run → Edit Configurations → + → Flutter** and set Dart entrypoint to `lib/main.dart`).
   - Choose a device (Android emulator, Chrome, Windows, etc.) and click **Run**.

You can edit Dart/Flutter code in `lib/` and Android-specific code under `android/` as needed.
