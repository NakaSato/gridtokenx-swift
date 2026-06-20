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
- `Core/Notifications/TxLiveActivityManager.swift` — shows/ends the transaction-success Live Activity (`Activity<TxReceiptAttributes>`); `show` replaces any running receipt and auto-ends after a delay. Wired to wallet Send/Deposit.
- `Core/Notifications/NotificationManager.swift` — user notifications (`UNUserNotificationCenter`): `configure()` (auth + foreground-banner delegate `ForegroundPresenter`), `send(...)`/`sendSample()`. Tapped notifications with a `deeplink` payload re-broadcast via `didTapDeeplink` → RootView navigates. Local notifications need the one-time "Allow" tap (no simctl UI injection — grant manually in the sim).
- `Features/Profile/ProfileWalletView.swift` — `07 · Profile & Wallet`. Portfolio hero, token holdings / activity tabs, account settings rows. Port of `mock-ui/wallet.jsx`. Reached from the Dashboard profile button. Send/Deposit tap → `onSend`/`onReceive` → `TxLiveActivityManager.show(...)`; the receipt appears only as the Live Activity / Dynamic Island notification (no in-app banner).

### EnergyIslandWidget target

Second target (app-extension, bundle `gridtokenx.gridtokexios.EnergyIslandWidget`) hosts the Dynamic Island / lock-screen Live Activities. Added via `scripts/add_widget_target.rb` (Ruby `xcodeproj` gem — re-runnable, no-op if the target exists), NOT by hand-editing `project.pbxproj`. The widget group uses **explicit file references** (not a synced folder), so new files added there must be registered with `scripts/add_tx_island_files.rb` (idempotent — pattern to copy for any further widget files). App embeds the extension and sets `INFOPLIST_KEY_NSSupportsLiveActivities = YES`. The `WidgetBundle` hosts two activities: `EnergyIslandLiveActivity` + `TxLiveActivity`.

- `EnergyIslandWidget/EnergyTradeIsland.swift` — **shared (app + widget)**: `EnergyTrade` model (Codable/Hashable, doubles as `ContentState`; `phase` field drives the flow-bars pulse), island palette (`Color.island*`), `FlowBars`, and the compact/split/expanded SwiftUI subviews. Ported from `mock-ui/energy-island.jsx`. The OS won't run free-running animations in the island, so `LiveActivityManager` bumps `EnergyTrade.phase` on a ~0.7s timer and `FlowBars(phase:)` animates between those ContentState snapshots; in-app (no phase) it uses a `repeatForever` pulse.
- `EnergyIslandWidget/EnergyTradeAttributes.swift` — **shared**: `ActivityAttributes` (`ContentState = EnergyTrade`).
- `EnergyIslandWidget/EnergyIslandLiveActivity.swift` — widget-only: `ActivityConfiguration` (lock-screen/notification banner) + `DynamicIsland { compactLeading/compactTrailing/minimal/expanded }`.
- `EnergyIslandWidget/TxReceiptIsland.swift` — **shared**: `TxReceipt` model (`ContentState`, send/receive), `CheckDisc`/`TxBadgeDisc`, and compact/expanded views. Transaction-success receipt — port of `mock-ui` `TxIslandCompact`/`TxIslandSuccess`.
- `EnergyIslandWidget/TxReceiptAttributes.swift` — **shared**: `ActivityAttributes` (`ContentState = TxReceipt`).
- `EnergyIslandWidget/TxLiveActivity.swift` — widget-only: second `ActivityConfiguration` + `DynamicIsland` for the TX receipt.
- `EnergyIslandWidget/{EnergyIslandWidgetBundle.swift, ColorHex.swift, Info.plist}` — widget-only entry point, a `Color(hex:)` copy (the app gets it from `GTXDesignTokens`), and the `NSExtension` plist.
- App triggers: Dashboard sell/buy → `LiveActivityManager.start(...)`; wallet Send/Deposit → `TxLiveActivityManager.show(...)` (receipt auto-ends after ~8s). Wired in `RootView`.
- Dev hooks (DEBUG launch args): `START_ISLAND` → sample energy Live Activity; `TX_ISLAND` / `TX_ISLAND_RX` → sample TX-receipt island (send / receive); `SEND_NOTIF` → sample local notification (taps deep-link to wallet); `SHOW_WALLET` → jump to Profile & Wallet.

Data flow: each screen is self-contained with local `@State`; navigation state lives in `RootView`. Bypass creds for the signup flow are static placeholders — `CreateAccountView.bypassEmail`/`bypassPassword`, `VerifyEmailView.bypassCode` (419720).

## Testing notes

- `WelcomeView` runs a continuous `TimelineView(.animation)` launch sequence. A perpetual animation keeps the app non-idle and defeats XCUITest synchronization, so UI tests pass the `UITEST` launch arg → `WelcomeView` renders a static settled frame.
- UI flow lives in `gridtokexiosUITests` (XCUITest): `testWelcomeToAppFlow` walks all six screens; `testBackFromCreateAccountReturnsToWelcome` checks the back path.

## Notes

- Source files date headers use Buddhist-era years (BE, e.g. 2569) — Thai locale. Cosmetic.
