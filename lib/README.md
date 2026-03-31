# AiMY — Project Structure (Clean Architecture + MVVM)

## Layers

```
lib/
├── main.dart                 # App entry, MaterialApp, initial route
├── core/                     # Shared: theme, design tokens, constants
│   ├── core.dart
│   ├── theme/                # AppTheme, AppColors, AppTypography
│   └── design/               # AimyPhoneDesignTokens (Figma parity)
├── domain/                   # Business logic: entities, repository interfaces
│   ├── domain.dart
│   ├── entities/             # ProfileEntity, etc.
│   └── repositories/         # ProfileRepository (abstract)
├── data/                     # Implementations: repos, data sources (when ready)
│   ├── data.dart
│   └── repositories/         # MockProfileRepository (UI-only for now)
└── presentation/             # UI: MVVM (views + viewmodels)
    ├── presentation.dart
    └── features/
        └── profile/          # Step 1: Profile (tap-to-call)
            ├── profile_feature.dart
            ├── profile_screen.dart   # View
            └── profile_viewmodel.dart # ViewModel
```

## Dependency rule

- **presentation** → domain, core (and data only via DI / repository interface)
- **data** → domain
- **domain** → nothing (no Flutter, no data)
- **core** → Flutter OK (theme, design tokens)

## Current step: Step 1 — Profile (tap-to-call)

- **Twilio demo (no Voice SDK auth):** Call button triggers a server-side Twilio outbound call and the recipient hears a robot message.
- **Mock data:** `MockProfileRepository` returns a single profile; replace with real API when ready.

## Next steps (only when you ask)

- Step 2: Incoming call screen  
- Step 3: Active call screen  
- Step 4: Mini-player  
- Step 5: Post-call screen  
