//
//  RootView.swift
//  gridtokexios
//
//  App entry router: Welcome → Create account → Verify → Profile → Success → app.
//  Route changes animate with a direction-aware push/pop slide.
//

import SwiftUI

struct RootView: View {
    private enum Route { case welcome, createAccount, verify, profile, success, app }

    @State private var route: Route = .welcome
    @State private var forward = true   // drives slide direction (push vs pop)
    @State private var displayName = "Maya"
    @State private var welcomeStart = Date()   // fixed at launch so back-nav skips the intro

    var body: some View {
        ZStack {
            current
                .id(route)
                .transition(pushPop)
        }
        .animation(.smooth(duration: 0.38), value: route)
        #if DEBUG
        .onAppear {
            // Dev hook: auto-start a sample Live Activity for island verification.
            if ProcessInfo.processInfo.arguments.contains("START_ISLAND") {
                LiveActivityManager.start(EnergyTrade(side: .sell))
            }
        }
        #endif
    }

    @ViewBuilder
    private var current: some View {
        switch route {
        case .welcome:
            WelcomeView(
                onCreateAccount: { push(.createAccount) },
                onSignIn: { push(.app) },
                start: welcomeStart
            )
        case .createAccount:
            CreateAccountView(
                onBack: { pop(.welcome) },
                onContinue: { push(.verify) }
            )
        case .verify:
            VerifyEmailView(
                onBack: { pop(.createAccount) },
                onVerify: { push(.profile) }
            )
        case .profile:
            ProfileView(
                onBack: { pop(.verify) },
                onContinue: { name, _ in
                    displayName = name.split(separator: " ").first.map(String.init) ?? name
                    push(.success)
                }
            )
        case .success:
            SuccessView(name: displayName, onEnter: { push(.app) })
        case .app:
            DashboardView(
                name: displayName,
                onSell: { LiveActivityManager.start(EnergyTrade(side: .sell)) },
                onBuy: { LiveActivityManager.start(
                    EnergyTrade(side: .buy, ratePerKwh: 4.28, kwh: 3.2, progress: 0.42)) }
            )
        }
    }

    // MARK: - Navigation

    private func push(_ next: Route) {
        forward = true
        route = next
    }

    private func pop(_ prev: Route) {
        forward = false
        route = prev
    }

    /// Incoming view slides in from the leading/trailing edge; outgoing exits the
    /// opposite way, so forward feels like a push and back like a pop.
    private var pushPop: AnyTransition {
        .asymmetric(
            insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
            removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity)
        )
    }
}

#Preview {
    RootView()
}
