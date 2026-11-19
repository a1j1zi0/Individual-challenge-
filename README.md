# Individual Challenge — Learning Tracker

An iOS app (SwiftUI, iOS 26) that helps a learner build a daily learning habit: set a learning goal and duration, log each day as **Learned** or **Freezed**, and track the streak.

## Architecture (MVVM)

```
Individual challenge/
├── Individual_challengeApp.swift      App entry, injects ActivityViewModel, refreshes on day/clock change
└── IndividualChallenge/
    ├── Models/        Plain data: LearningGoal, LearningProgress, DayStatus, GoalDuration, view types
    ├── ViewModels/    All logic lives here
    │   ├── ActivityViewModel.swift      Streak, freezes, goal state, clock-tampering check, persistence
    │   ├── LearningGoalViewModel.swift  Edit/confirm rules for the Learning Goal screen
    │   └── OnboardingViewModel.swift    First goal creation
    ├── Views/
    │   ├── Screens/     RootView, OnboardingView, ActivityView, LearningGoalView, CalendarView
    │   └── Components/  Reusable UI (LogButton, FreezeButton, StatCard, DurationPicker, UpdateGoalAlert, …)
    └── Theme/       Colors, "Day/Days" text helper
```

Views only display state and forward actions; they contain no business logic.
Data is stored locally in `UserDefaults` (key `learningProgress`).

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
- **Buttons are disabled** when all freezes are used or the day is already logged; they re-enable at 12 AM.
- **Wording**: `1 Day` (singular) vs `N Days` (plural).
- **Clock tampering**: if the device clock is changed manually (compared against the monotonic system clock), logging is blocked and a warning is shown.

## Design

- Dark theme; accent orange `#F5943D`, freeze blue.
- Liquid Glass (`.glassEffect`) on buttons, pills, stat cards and the custom *Update goal* alert.

## Running

1. Open `Individual challenge.xcodeproj` in Xcode 26 or later.
2. Pick an iOS 26 simulator or device.
3. Press **Run** (⌘R).

Tip: to start from a fresh Onboarding, add the launch argument `-learningProgress reset` in the scheme.

## Known open items

- Not yet verified on device: the *Dismiss → Update* path of the custom alert, the logged (gray) state of *Log as Learned*, and the manual clock-change detection.
- Open question: should *Log as Learned* be disabled when the day is already freezed? (Currently it stays enabled, matching the design.)
