//
//  TxLiveActivityManager.swift
//  gridtokexios
//
//  Starts / ends the transaction-success Live Activity (token send & receive
//  receipt, lock-screen banner + Dynamic Island). Local-driven (`pushType: nil`).
//  Receipts are terminal, so `start` auto-dismisses after a short delay.
//

import ActivityKit
import Foundation

enum TxLiveActivityManager {
    private static var current: Activity<TxReceiptAttributes>?

    static var isRunning: Bool { current != nil }

    /// Show a transaction receipt, replacing any running one. Auto-ends after
    /// `autoEnd` seconds (a receipt isn't an ongoing process). No-op if the user
    /// disabled Live Activities.
    @discardableResult
    static func show(_ receipt: TxReceipt, autoEnd: TimeInterval = 8) -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
        if let existing = current {
            current = nil
            Task { await existing.end(nil, dismissalPolicy: .immediate) }
        }
        let content = ActivityContent(state: receipt, staleDate: nil)
        do {
            let activity = try Activity.request(
                attributes: TxReceiptAttributes(),
                content: content,
                pushType: nil
            )
            current = activity
            Task {
                try? await Task.sleep(nanoseconds: UInt64(autoEnd * 1_000_000_000))
                if current === activity {
                    current = nil
                    await activity.end(nil, dismissalPolicy: .default)
                }
            }
            return true
        } catch {
            return false
        }
    }

    static func end() {
        guard let activity = current else { return }
        current = nil
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }
}
