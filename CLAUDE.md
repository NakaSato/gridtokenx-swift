# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

GridTokenX iOS app (`gridtokexios`). Native SwiftUI. A multi-screen signup flow ported from the `mock-ui/` HTML/JSX prototypes: Welcome → Create account → Verify email → Profile + role → Success → Dashboard. No persistence layer yet — views drive themselves with local `@State`; the SwiftData template (`Item`/`ContentView`) has been removed.

- Bundle ID: `gridtokenx.gridtokexios`
- Deployment target: iOS 26.5, universal (iPhone + iPad, `TARGETED_DEVICE_FAMILY = "1,2"`)
- Swift 5.0, tests use the **Swift Testing** framework (`import Testing`, `@Test`/`#expect`) — not XCTest. UI tests still use XCTest.

## Commands

No xcodebuild wrappers/Makefile — drive the project directly. Scheme is `gridtokexios`.

```bash
# Build
xcodebuild build -project gridtokexios.xcodeproj -scheme gridtokexios \
  -destination 'platform=iOS Simulator,name=iPhone 17'

# Run all tests (unit + UI)
xcodebuild test -project gridtokexios.xcodeproj -scheme gridtokexios \
  -destination 'platform=iOS Simulator,name=iPhone 17'

# Run a single test (Swift Testing) — TestType/methodName
xcodebuild test -project gridtokexios.xcodeproj -scheme gridtokexios \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:gridtokexiosTests/gridtokexiosTests/example
```

Day-to-day, building/running via Xcode (⌘B / ⌘R / ⌘U) is normal. Adjust the simulator `name` to one installed locally (`xcrun simctl list devices`).

## Architecture

Source is organized by responsibility under `gridtokexios/`. The target uses an Xcode **synchronized folder group** (`PBXFileSystemSynchronizedRootGroup`) — folders on disk auto-map to the build; add/move files freely without editing `project.pbxproj`.

```
gridtokexios/
├── App/            # composition root — gridtokexiosApp.swift, RootView.swift
├── DesignSystem/   # GTXDesignTokens.swift, GTXComponents.swift
├── Features/       # one folder per screen group
│   ├── Welcome/        WelcomeView.swift
│   ├── Onboarding/     CreateAccountView, VerifyEmailView, ProfileView, SuccessView
│   └── Dashboard/      DashboardView.swift
├── Core/           # cross-cutting infra — Inject.swift (future: Networking/, Persistence/)
└── Resources/      # Assets.xcassets
```

- `App/gridtokexiosApp.swift` — `@main` entry. Hosts `RootView` in a `WindowGroup`. DEBUG `init()` loads the InjectionIII bundle for hot reload. No SwiftData container (re-add `.modelContainer` here when a real `@Model` lands).
- `App/RootView.swift` — the router. `enum Route` (welcome → createAccount → verify → profile → success → app); `push`/`pop` drive a direction-aware slide via an asymmetric `pushPop` transition. Owns `welcomeStart` (fixed at launch) so back-nav to Welcome skips the intro, and `displayName` threaded into Success/Dashboard.
- `Features/**` screen views — `WelcomeView`, `CreateAccountView`, `VerifyEmailView`, `ProfileView`, `SuccessView`, `DashboardView`. Each takes plain closures (`onContinue`, `onBack`, …); no shared store. New feature → new `Features/<Name>/` folder; add `ViewModel`/`Model` subfiles when logic lands.
- `DesignSystem/GTXDesignTokens.swift` — `Color(hex:)`, `GTXColor` palette, `LinearGradient.gtxBrand`, `GTXPrimaryButtonStyle`. `DesignSystem/GTXComponents.swift` — shared `GTXBackButton` / `GTXTopGlow` / `GTXField`.
- `Core/Inject.swift` — DEBUG hot-reload shim (`@ObserveInjection` + `.enableInjection()`); RELEASE compiles to no-ops.

Data flow: each screen is self-contained with local `@State`; navigation state lives in `RootView`. Bypass creds for the signup flow are static placeholders — `CreateAccountView.bypassEmail`/`bypassPassword`, `VerifyEmailView.bypassCode` (419720).

## Testing notes

- `WelcomeView` runs a continuous `TimelineView(.animation)` launch sequence. A perpetual animation keeps the app non-idle and defeats XCUITest synchronization, so UI tests pass the `UITEST` launch arg → `WelcomeView` renders a static settled frame.
- UI flow lives in `gridtokexiosUITests` (XCUITest): `testWelcomeToAppFlow` walks all six screens; `testBackFromCreateAccountReturnsToWelcome` checks the back path.

## Notes

- Source files date headers use Buddhist-era years (BE, e.g. 2569) — Thai locale. Cosmetic.
