//
//  EnergyIslandLiveActivity.swift
//  EnergyIslandWidget
//
//  The Live Activity: lock-screen / notification banner (ActivityConfiguration)
//  plus the three Dynamic Island presentations — compact (leading/trailing),
//  minimal, and expanded. All reuse the shared island subviews.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct EnergyIslandLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EnergyTradeAttributes.self) { context in
            // Lock screen + notification banner.
            EnergyIslandExpanded(trade: context.state)
                .padding(.vertical, 6)
                .activityBackgroundTint(.black)
                .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            let trade = context.state
            return DynamicIsland {
                // Expanded (long-press) — the live-trade card laid across regions.
                DynamicIslandExpandedRegion(.leading) {
                    EnergyExpandedLeading(trade: trade)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EnergyExpandedTrailing(trade: trade)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 12) {
                        EnergyExpandedProgress(trade: trade)
                        EnergyExpandedFooter(trade: trade)
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                EnergyIslandCompactLeading(trade: trade)
            } compactTrailing: {
                EnergyIslandCompactTrailing(trade: trade)
            } minimal: {
                Image(systemName: "bolt.fill").foregroundStyle(trade.accent)
            }
            .keylineTint(trade.accent)
        }
    }
}
