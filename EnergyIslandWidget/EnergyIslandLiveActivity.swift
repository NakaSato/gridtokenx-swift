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
                // Expanded (long-press) — laid out across the island regions.
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(trade.title).font(.caption).fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "bolt.fill").foregroundStyle(trade.accent)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(trade.rateText)
                        .font(.system(.body, design: .monospaced).weight(.bold))
                        .foregroundStyle(trade.accent)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 10) {
                        FlowBars(color: trade.accent, count: 5)
                        ProgressView(value: trade.progress)
                            .tint(trade.accent)
                        Text("\(trade.kwh, specifier: "%.1f") kWh")
                            .font(.system(.caption, design: .monospaced).weight(.bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 2)
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
