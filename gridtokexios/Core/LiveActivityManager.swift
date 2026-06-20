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

    static var isRunning: Bool { current != nil }

    /// Begin a live activity for the given trade, replacing any running one.
    /// No-op if the user disabled Live Activities.
    @discardableResult
    static func start(_ trade: EnergyTrade) -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
        if let existing = current {
            current = nil
            Task { await existing.end(nil, dismissalPolicy: .immediate) }
        }
        let content = ActivityContent(state: trade, staleDate: nil)
        do {
            current = try Activity.request(
                attributes: EnergyTradeAttributes(),
                content: content,
                pushType: nil
            )
            return true
        } catch {
            return false
        }
    }

    static func update(_ trade: EnergyTrade) {
        guard let activity = current else { return }
        Task { await activity.update(ActivityContent(state: trade, staleDate: nil)) }
    }

    static func end() {
        guard let activity = current else { return }
        current = nil
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }
}
