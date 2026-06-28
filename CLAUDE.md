# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

GridTokenX iOS app (`gridtokexios`). Native SwiftUI. Screens ported from the `mock-ui/` HTML/JSX prototypes. Two parts: a signup flow (Welcome → Create account → Verify email → Profile + role → Success → Dashboard) and a set of post-login feature screens reached from the dashboard (see the `Features/` tree below for the canonical list). No persistence layer yet — views drive themselves with local `@State`; the SwiftData template (`Item`/`ContentView`) has been removed.

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
├── DesignSystem/   # GTXDesignTokens.swift, GTXComponents.swift, GTXKit.swift
├── Features/       # one folder per screen group
│   ├── Welcome/        WelcomeView
│   ├── Onboarding/     CreateAccountView, VerifyEmailView, ProfileView, SuccessView
│   ├── Dashboard/      DashboardView, DashboardLiveView
│   ├── Profile/        ProfileWalletView
│   ├── Settings/       SettingsView, ProfileEditView
│   ├── Billing/        BillingView, BillingHistoryView
│   ├── DCA/            DCAView          # dollar-cost-average buy plan
│   ├── EnergyFlow/     EnergyFlowView, MyHomeFlowView   # route .myHomeFlow
│   ├── GridMap/        GridMapView
│   ├── NDID/           NDIDView, NDIDProfileView   # Thai NDID identity
│   ├── Orders/         OrderHistoryView
│   ├── Transfer/       TransferView     # deposit / withdraw
│   ├── Register/       RegisterDeviceView
│   ├── Notifications/  NotificationsView
│   └── Receipt/        ReceiptExpandedView
├── Core/           # cross-cutting infra — Inject.swift, Notifications/ (future: Networking/, Persistence/)
└── Resources/      # Assets.xcassets
```

- `App/gridtokexiosApp.swift` — `@main` entry. Hosts `RootView` in a `WindowGroup`. DEBUG `init()` loads the InjectionIII bundle for hot reload. No SwiftData container (re-add `.modelContainer` here when a real `@Model` lands).
- `App/RootView.swift` — the router. A single `private enum Route` flat-lists every screen (see the enum in the source for the canonical case list). Navigation is **not** a stack: one `@State route` holds the current screen, and `push(next)` / `pop(prev)` both just assign `route` (pop takes the destination explicitly) — they only flip a `forward` flag to drive a direction-aware slide via the asymmetric `pushPop` transition. Owns `welcomeStart` (fixed at launch) so back-nav to Welcome skips the intro, and `displayName` threaded into Success/Dashboard. Dashboard buttons `push(...)` the feature routes; observes `NotificationManager.didTapDeeplink` to deep-link tapped notifications. **Every new screen wires here** — add a `Route` case + a `switch` arm.
- `Features/**` screen views — each takes plain closures (`onContinue`, `onBack`, …); no shared store. New feature → new `Features/<Name>/` folder; add `ViewModel`/`Model` subfiles when logic lands.
- `DesignSystem/GTXDesignTokens.swift` — `Color(hex:)`, `GTXColor` palette (dark + `light*` variants, `buy`/`sell`/`gold`), and the scale enums `GTXSpacing` / `GTXRadius` / `GTXFont` / `GTXLayout` / `GTXOpacity`, plus `LinearGradient.gtxBrand` and `GTXPrimaryButtonStyle`. **Use these tokens, not raw values.**
- `DesignSystem/GTXComponents.swift` — shared `GTXBackButton` / `GTXTopGlow` / `GTXField`.
- `DesignSystem/GTXKit.swift` — higher-level component kit built on the tokens: `.gtxCard()` modifier, `GTXIconDisc` / `GTXTextDisc`, `GTXListRow`, `GTXSectionHeader`, `.gtxUniversalWidth()`. Reach for these before re-rolling card/row/disc boilerplate.
- `Core/Inject.swift` — DEBUG hot-reload shim (`@ObserveInjection` + `.enableInjection()`); RELEASE compiles to no-ops.
- `Core/Notifications/LiveActivityManager.swift` — starts/updates/ends the energy-trade Live Activity (`Activity<EnergyTradeAttributes>`). Local-driven (`pushType: nil`); `start` replaces any running activity.
- `Core/Notifications/TxLiveActivityManager.swift` — shows/ends the transaction-success Live Activity (`Activity<TxReceiptAttributes>`); `show` replaces any running receipt and auto-ends after a delay. Wired to wallet Send/Deposit.
- `Core/Notifications/NotificationManager.swift` — user notifications (`UNUserNotificationCenter`): `configure()` (auth + foreground-banner delegate `ForegroundPresenter`), `send(...)`/`sendSample()`. Tapped notifications with a `deeplink` payload re-broadcast via `didTapDeeplink` → RootView navigates. Local notifications need the one-time "Allow" tap (no simctl UI injection — grant manually in the sim).
- `Features/Profile/ProfileWalletView.swift` — `07 · Profile & Wallet`. Portfolio hero, token holdings / activity tabs, account settings rows. Port of `mock-ui/wallet.jsx`. Reached from the Dashboard profile button. Send/Deposit tap → `onSend`/`onReceive` → `TxLiveActivityManager.show(...)`; the receipt appears only as the Live Activity / Dynamic Island notification (no in-app banner).
- `Features/Receipt/ReceiptExpandedView.swift` — in-app render of the `DI · Expanded (sent success / received)` artboard (receipt card on the `#15101F` canvas). Reuses the shared `TxIslandExpanded` notification component. Route `.sentSuccess`; DEBUG `SHOW_SENT`.

### EnergyIslandWidget target

Second target (app-extension, bundle `gridtokenx.gridtokexios.EnergyIslandWidget`) hosts the Dynamic Island / lock-screen Live Activities. Added via `scripts/add_widget_target.rb` (Ruby `xcodeproj` gem — re-runnable, no-op if the target exists), NOT by hand-editing `project.pbxproj`. The widget group uses **explicit file references** (not a synced folder), so new files added there must be registered with an idempotent `xcodeproj` Ruby script — `scripts/add_tx_island_files.rb` and `scripts/add_split_view_files.rb` are the existing examples; copy the pattern for any further widget files. App embeds the extension and sets `INFOPLIST_KEY_NSSupportsLiveActivities = YES`. The `WidgetBundle` hosts two activities: `EnergyIslandLiveActivity` + `TxLiveActivity`.

Notification component files are split **model/palette ↔ views**: a `*Island.swift` holds the model (+ palette), a `*Views.swift` holds the SwiftUI presentations, and a `*LiveActivity.swift` holds the widget config.

- `EnergyIslandWidget/EnergyTradeIsland.swift` — **shared (app + widget)**: `EnergyTrade` model (Codable/Hashable, doubles as `ContentState`; `phase` drives the flow-bars pulse) + island palette (`Color.island*`).
- `EnergyIslandWidget/EnergyTradeViews.swift` — **shared**: `FlowBars` + compact/split/expanded subviews. Ported from `mock-ui/energy-island.jsx`. The OS won't run free-running animations in the island, so `LiveActivityManager` bumps `EnergyTrade.phase` on a ~0.7s timer and `FlowBars(phase:)` animates between those ContentState snapshots; in-app (no phase) it uses a `repeatForever` pulse.
- `EnergyIslandWidget/EnergyTradeAttributes.swift` — **shared**: `ActivityAttributes` (`ContentState = EnergyTrade`).
- `EnergyIslandWidget/EnergyIslandLiveActivity.swift` — widget-only: `ActivityConfiguration` (lock-screen/notification banner) + `DynamicIsland { compactLeading/compactTrailing/minimal/expanded }`.
- `EnergyIslandWidget/TxReceiptIsland.swift` — **shared**: `TxReceipt` model (`ContentState`, send/receive). Transaction-success receipt.
- `EnergyIslandWidget/TxReceiptViews.swift` — **shared**: `CheckDisc`/`TxBadgeDisc` + compact/expanded receipt views. Port of `mock-ui` `TxIslandCompact`/`TxIslandSuccess`.
- `EnergyIslandWidget/TxReceiptAttributes.swift` — **shared**: `ActivityAttributes` (`ContentState = TxReceipt`).
- `EnergyIslandWidget/TxLiveActivity.swift` — widget-only: second `ActivityConfiguration` + `DynamicIsland` for the TX receipt.
- `EnergyIslandWidget/{EnergyIslandWidgetBundle.swift, ColorHex.swift, Info.plist}` — widget-only entry point, a `Color(hex:)` copy (the app gets it from `GTXDesignTokens`), and the `NSExtension` plist.
- App triggers: Dashboard sell/buy → `LiveActivityManager.start(...)`; wallet Send/Deposit → `TxLiveActivityManager.show(...)` (receipt auto-ends after ~8s). Wired in `RootView`.
- Dev hooks (DEBUG launch args): `START_ISLAND` → sample energy Live Activity; `TX_ISLAND` / `TX_ISLAND_RX` → sample TX-receipt island (send / receive); `SEND_NOTIF` → sample local notification (taps deep-link to wallet); `SHOW_WALLET` → jump to Profile & Wallet; `SHOW_SENT` → jump to the in-app sent-success receipt screen.

Data flow: each screen is self-contained with local `@State`; navigation state lives in `RootView`. Bypass creds for the signup flow are static placeholders — `CreateAccountView.bypassEmail`/`bypassPassword`, `VerifyEmailView.bypassCode` (419720).

## Testing notes

- `WelcomeView` runs a continuous `TimelineView(.animation)` launch sequence. A perpetual animation keeps the app non-idle and defeats XCUITest synchronization, so UI tests pass the `UITEST` launch arg → `WelcomeView` renders a static settled frame.
- UI flow lives in `gridtokexiosUITests` (XCUITest): `testWelcomeToAppFlow` walks all six screens; `testBackFromCreateAccountReturnsToWelcome` checks the back path.

## Notes

- Source files date headers use Buddhist-era years (BE, e.g. 2569) — Thai locale. Cosmetic.
