# Individual Challenge — Learning Tracker

An iOS app (SwiftUI, iOS 26) that helps a learner build a daily learning habit: set a learning goal and duration, log each day as **Learned** or **Freezed**, and track the streak.

## Architecture (MVVM)

```
Individual challenge/
├── Individual_challengeApp.swift      App entry, injects ActivityViewModel, refreshes on day/clock change
├── Localizable.xcstrings              String Catalog (all UI text)
└── IndividualChallenge/
    ├── Models/
    │   ├── LearningRules.swift          Pure business rules (streak, freezes, goal state, clock check)
    │   ├── ProgressStore.swift          Persistence (UserDefaults)
    │   └── LearningGoal, LearningProgress, DayStatus, GoalDuration, view types
    ├── ViewModels/    @Observable view models that connect rules + storage to the UI
    │   ├── ActivityViewModel.swift      Injectable clock/storage; exposes display state and actions
    │   ├── LearningGoalViewModel.swift  Edit/confirm rules for the Learning Goal screen
    │   └── OnboardingViewModel.swift    First goal creation
    ├── Views/
    │   ├── Screens/     RootView, OnboardingView, ActivityView, LearningGoalView, CalendarView
    │   └── Components/  Reusable UI (LogButton, FreezeButton, StatCard, DurationPicker, UpdateGoalAlert, …)
    └── Theme/       Colors, cached date formatting (DateText), "Day/Days" helper
```

- Views only display state and forward actions; they contain no business logic.
- Business rules are pure functions in `LearningRules`, taking `now` / `uptime` as parameters, so they are deterministic and testable.
- `ActivityViewModel` takes its clock, uptime source and `ProgressStore` as init parameters (defaults for the app, fakes for tests).
- Uses the Observation framework (`@Observable`) and async/await — no Combine.

### Design decisions

- **Persistence: `UserDefaults`, not SwiftData.** The app stores a single small record (one goal + a dictionary of days), so a database would add complexity without benefit. `ProgressStore` isolates this, so switching later only touches one file.
- **Log after freeze:** the written requirement says buttons are disabled once a day is logged, so a freezed day can't also be logged as Learned.

## User flow

1. **Start learning** — Onboarding → set learning topic (free text, any language) and duration (Week / Month / Year) → Activity.
2. **Log a day** — Activity → *Log as Learned* or *Freeze for a day*.
3. **Goal finished** — when the goal is completed or not met, *Set a goal* opens Learning Goal; the same goal can be chosen again.
4. **Change learning goal** — target icon → Learning Goal → ✓ → *Update goal* alert → Activity.
5. **Calendar** — calendar icon → Activities (view only) with learned / freezed days per month.

## Business rules

- **Streak resets** when:
  - more than **32 hours** pass without logging a day as Learned and without using a Freeze, or
  - the learning goal is updated.
- **Freezes** keep the streak alive. Limit per goal duration: **2** per week, **8** per month, **96** per year, counted from the goal's start date.
- **Buttons are disabled** when all freezes are used or the day is already logged (Learned or Freezed); they re-enable at 12 AM.
- **Wording**: `1 Day` (singular) vs `N Days` (plural).
- **Clock tampering**: if the device clock is changed manually (compared against the monotonic system clock), logging is blocked and a warning is shown.

## Design

- Dark theme; accent orange `#F5943D`, freeze blue.
- Liquid Glass (`.glassEffect`) on buttons, pills, stat cards and the custom *Update goal* alert.

## Accessibility & localization

- VoiceOver: calendar days read the full date and status (e.g. "Thursday, 19 November 2026, Learned, Today"), so status isn't conveyed by color alone; stat cards read as one phrase; toolbar icons are labeled.
- Dynamic Type: the log circle, freeze button and day cells scale with the user's text size (`@ScaledMetric`).
- Contrast: freeze button text is dark navy on light blue instead of white.
- All UI text lives in `Localizable.xcstrings`, ready for translation.

## Running

1. Open `Individual challenge.xcodeproj` in Xcode 26 or later.
2. Pick an iOS simulator or device.
3. Press **Run** (⌘R).

Tip: to start from a fresh Onboarding, add the launch argument `-learningProgress reset` in the scheme.

## Known open items

- Not yet verified on device: the *Dismiss → Update* path of the custom alert, the logged (gray) state of *Log as Learned*, and the manual clock-change detection.
- Unit tests: the rules are structured for testing (`LearningRules`, injectable clock/storage), but a test target has not been added yet.
