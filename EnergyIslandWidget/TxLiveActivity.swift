//
//  TxLiveActivity.swift
//  EnergyIslandWidget
//
//  The transaction-success Live Activity: lock-screen / notification banner
//  plus the Dynamic Island presentations — compact (check disc + signed
//  amount), minimal (check mark), and expanded (receipt + settle line).
//  All reuse the shared TxReceiptIsland subviews.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TxLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TxReceiptAttributes.self) { context in
            // Lock screen + notification banner.
            TxIslandExpanded(tx: context.state)
                .padding(16)
                .activityBackgroundTint(.black)
                .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            let tx = context.state
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    TxBadgeDisc(tx: tx, size: 38)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(tx.amountText)
                            .font(.system(.body, design: .monospaced).weight(.heavy))
                            .foregroundStyle(tx.accent)
                        Text(tx.fiatText)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(Color.islandFaint)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tx.title).font(.caption).fontWeight(.semibold).foregroundStyle(.white)
                        Text(tx.who).font(.caption2).foregroundStyle(Color.islandMuted).lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 8) {
                        Circle().fill(Color.islandUp).frame(width: 6, height: 6)
                        Text("Settled on-chain").font(.caption2).foregroundStyle(Color.islandMuted)
                        Spacer()
                        Text(tx.txHash)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(Color.islandFaint)
                    }
                }
            } compactLeading: {
                TxIslandCompactLeading(tx: tx)
            } compactTrailing: {
                TxIslandCompactTrailing(tx: tx)
            } minimal: {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color.islandUp)
            }
            .keylineTint(.islandUp)
        }
    }
}
