# Itinera

Itinera is a Flutter UI prototype for an intelligent travel-planning experience. It focuses on onboarding, itinerary generation, timeline editing, and budget estimation with a consistent Material 3 design system and custom typography.

## Highlights
- Auth + multi-step onboarding flow
- Home dashboard with planned trips and Atlas discovery cards
- Trip management screens (scheduled/current/completed, checklist)
- Timeline planning flow (date selector, generation, preview, edit, final)
- Budget estimation flow with breakdown and tips
- Material 3 theme and reusable widgets
- Design reference images under `assets/images/stitch_itinera/`

## Tech Stack
- Flutter (SDK >= 3.0.0)
- Material 3
- Custom theme and Roboto Mono font
- Pure UI/mock data (no backend services in this repo)

## Project Structure
```
lib/
  main.dart
  theme/
  screens/
    auth/
    onboarding/
    home/
    trip/
    timeline/
    budget/
  widgets/
assets/
  images/
fonts/
```

## Getting Started
1. Install Flutter and ensure your environment is set up.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

Optional: run on a specific device (e.g. Chrome or iOS simulator):
```bash
flutter run -d chrome
```

## Tests
```bash
flutter test
```

## Navigation Flow
```mermaid
graph TD
    Entry(main.dart) --> Auth[LoginSignupScreen]

    %% Authentication Flow
    Auth -- Login --> Home[HomeScreen]
    Auth -- Signup --> Onb1[Onboarding1Screen]

    %% Onboarding Flow
    Onb1 --> Onb2[Onboarding2Screen]
    Onb2 --> Onb3[Onboarding3Screen]
    Onb3 --> OnbComp[OnboardingCompletionScreen]
    OnbComp --> Home

    %% Home Screen Interactions
    Home -- Profile Icon --> Profile[ProfileScreen]
    Profile -- Logout --> Auth
    Home -- FAB --> Search[SearchBottomSheet]

    %% Trip Management
    Home -- Planned Trip Card --> TripSched[TripScheduledScreen]
    TripSched -- Checklist --> TripCheck[TripChecklistScreen]

    %% New Trip Planning (The Atlas)
    Home -- Atlas Card --> DestDetail[DestinationDetailScreen]
    DestDetail -- Plan this trip --> TimeSel[TimelineSelectorScreen]
    TimeSel -- Generate --> TimeLoad[TimelineGenerationLoadingScreen]
    TimeLoad -- (Delay) --> TimeInit[TimelineInitialPreviewScreen]

    %% Timeline Editing
    TimeInit -- Edit --> TimeEdit[TimelineEditorScreen]
    TimeInit -- Complete --> TimeFinal[TimelineFinalPreviewScreen]

    %% Budget Estimation
    TimeFinal -- Confirm --> BudgetLoad[BudgetLoadingScreen]
    BudgetLoad -- (Delay) --> Budget[BudgetEstimationScreen]
    Budget -- Done --> Home
```

## Assets
- Design references: `assets/images/stitch_itinera/`
- App logos: `assets/images/logo_black.png`, `assets/images/logo_white.png`
- Onboarding background: `assets/images/onboarding_bg.jpg`
- Fonts: `fonts/RobotoMono-*.ttf`

## Notes
- Entry point is `lib/main.dart` and the initial screen is `LoginSignupScreen`.
- This repository focuses on UI flows and styling. Data shown in screens is sample data.
