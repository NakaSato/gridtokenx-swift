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
│   ├── Dashboard/      DashboardView.swift
│   └── Profile/        ProfileWalletView.swift
├── Core/           # cross-cutting infra — Inject.swift, Notifications/ (future: Networking/, Persistence/)
└── Resources/      # Assets.xcassets
```

- `App/gridtokexiosApp.swift` — `@main` entry. Hosts `RootView` in a `WindowGroup`. DEBUG `init()` loads the InjectionIII bundle for hot reload. No SwiftData container (re-add `.modelContainer` here when a real `@Model` lands).
- `App/RootView.swift` — the router. `enum Route` (welcome → createAccount → verify → profile → success → app, plus `profileWallet`); `push`/`pop` drive a direction-aware slide via an asymmetric `pushPop` transition. Owns `welcomeStart` (fixed at launch) so back-nav to Welcome skips the intro, and `displayName` threaded into Success/Dashboard. Dashboard profile button → `push(.profileWallet)`; observes `NotificationManager.didTapDeeplink` to deep-link tapped notifications to the wallet.
- `Features/**` screen views — `WelcomeView`, `CreateAccountView`, `VerifyEmailView`, `ProfileView`, `SuccessView`, `DashboardView`. Each takes plain closures (`onContinue`, `onBack`, …); no shared store. New feature → new `Features/<Name>/` folder; add `ViewModel`/`Model` subfiles when logic lands.
- `DesignSystem/GTXDesignTokens.swift` — `Color(hex:)`, `GTXColor` palette, `LinearGradient.gtxBrand`, `GTXPrimaryButtonStyle`. `DesignSystem/GTXComponents.swift` — shared `GTXBackButton` / `GTXTopGlow` / `GTXField`.
- `Core/Inject.swift` — DEBUG hot-reload shim (`@ObserveInjection` + `.enableInjection()`); RELEASE compiles to no-ops.
- `Core/Notifications/LiveActivityManager.swift` — starts/updates/ends the energy-trade Live Activity (`Activity<EnergyTradeAttributes>`). Local-driven (`pushType: nil`); `start` replaces any running activity.
- `Core/Notifications/NotificationManager.swift` — user notifications (`UNUserNotificationCenter`): `configure()` (auth + foreground-banner delegate `ForegroundPresenter`), `send(...)`/`sendSample()`. Tapped notifications with a `deeplink` payload re-broadcast via `didTapDeeplink` → RootView navigates. Local notifications need the one-time "Allow" tap (no simctl UI injection — grant manually in the sim).
- `Features/Profile/ProfileWalletView.swift` — `07 · Profile & Wallet`. Portfolio hero, token holdings / activity tabs, account settings rows. Port of `mock-ui/wallet.jsx`. Reached from the Dashboard profile button.

### EnergyIslandWidget target

Second target (app-extension, bundle `gridtokenx.gridtokexios.EnergyIslandWidget`) hosts the Dynamic Island / lock-screen Live Activity for energy trades. Added via `scripts/add_widget_target.rb` (Ruby `xcodeproj` gem — re-runnable, no-op if the target exists), NOT by hand-editing `project.pbxproj`. App embeds it and sets `INFOPLIST_KEY_NSSupportsLiveActivities = YES`.

- `EnergyIslandWidget/EnergyTradeIsland.swift` — **shared (app + widget)**: `EnergyTrade` model (Codable/Hashable, doubles as `ContentState`), island palette, `FlowBars`, and the compact/split/expanded SwiftUI subviews. Ported from `mock-ui/energy-island.jsx`.
- `EnergyIslandWidget/EnergyTradeAttributes.swift` — **shared**: `ActivityAttributes` (`ContentState = EnergyTrade`).
- `EnergyIslandWidget/EnergyIslandLiveActivity.swift` — widget-only: `ActivityConfiguration` (lock-screen/notification banner) + `DynamicIsland { compactLeading/compactTrailing/minimal/expanded }`.
- `EnergyIslandWidget/{EnergyIslandWidgetBundle.swift, ColorHex.swift, Info.plist}` — widget-only entry point, a `Color(hex:)` copy (the app gets it from `GTXDesignTokens`), and the `NSExtension` plist.
- App triggers: Dashboard sell/buy buttons → `LiveActivityManager.start(...)` wired in `RootView`.
- Dev hooks (DEBUG launch args): `START_ISLAND` → auto-start a sample Live Activity; `SEND_NOTIF` → fire a sample local notification (taps deep-link to wallet); `SHOW_WALLET` → jump straight to Profile & Wallet.

Data flow: each screen is self-contained with local `@State`; navigation state lives in `RootView`. Bypass creds for the signup flow are static placeholders — `CreateAccountView.bypassEmail`/`bypassPassword`, `VerifyEmailView.bypassCode` (419720).

## Testing notes

- `WelcomeView` runs a continuous `TimelineView(.animation)` launch sequence. A perpetual animation keeps the app non-idle and defeats XCUITest synchronization, so UI tests pass the `UITEST` launch arg → `WelcomeView` renders a static settled frame.
- UI flow lives in `gridtokexiosUITests` (XCUITest): `testWelcomeToAppFlow` walks all six screens; `testBackFromCreateAccountReturnsToWelcome` checks the back path.

## Notes

- Source files date headers use Buddhist-era years (BE, e.g. 2569) — Thai locale. Cosmetic.
