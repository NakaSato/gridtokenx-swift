//
//  LiveActivityManager.swift
//  gridtokexios
//
//  Starts / updates / ends the energy-trade Live Activity (lock-screen banner +
//  Dynamic Island). Locally driven here; swap pushType to .token for remote
//  ActivityKit push updates later.
//

import ActivityKit
import Foundation

enum LiveActivityManager {
    private static var current: Activity<EnergyTradeAttributes>?
    private static var pulseTask: Task<Void, Never>?

    static var isRunning: Bool { current != nil }

    /// Begin a live activity for the given trade, replacing any running one.
    /// No-op if the user disabled Live Activities. Also drives the flow-bars
    /// pulse by bumping `phase` on a timer — the OS animates between the
    /// resulting ContentState snapshots (it won't run free-running animations).
    @discardableResult
    static func start(_ trade: EnergyTrade) -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
        pulseTask?.cancel()
        if let existing = current {
            current = nil
            Task { await existing.end(nil, dismissalPolicy: .immediate) }
        }
        let content = ActivityContent(state: trade, staleDate: nil)
        do {
            let activity = try Activity.request(
                attributes: EnergyTradeAttributes(),
                content: content,
                pushType: nil
            )
            current = activity
            startPulse(from: trade, on: activity)
            return true
        } catch {
            return false
        }
    }

    /// Steps `phase` ~every 0.7s so the island's flow bars read as flowing.
    /// Runs while the activity lives; ActivityKit throttles background updates.
    private static func startPulse(from trade: EnergyTrade, on activity: Activity<EnergyTradeAttributes>) {
        pulseTask = Task {
            var t = trade
            while !Task.isCancelled, activity.activityState == .active {
                try? await Task.sleep(nanoseconds: 700_000_000)
                guard !Task.isCancelled, current === activity else { break }
                t.phase &+= 1
                await activity.update(ActivityContent(state: t, staleDate: nil))
            }
        }
    }

    static func update(_ trade: EnergyTrade) {
        guard let activity = current else { return }
        Task { await activity.update(ActivityContent(state: trade, staleDate: nil)) }
    }

    static func end() {
        pulseTask?.cancel()
        pulseTask = nil
        guard let activity = current else { return }
        current = nil
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }
}
