//
//  EnergyTradeIsland.swift
//  gridtokexios
//
//  Energy-trade model + island palette. `EnergyTrade` doubles as the Live
//  Activity `ContentState`. Shared between the app target (drives it via
//  LiveActivityManager) and the EnergyIslandWidget extension. The SwiftUI
//  presentations (compact / split / expanded) live in EnergyTradeViews.swift.
//

import SwiftUI

// MARK: - Model

/// One live energy trade. `side` drives the green (sell/earn) vs red (buy/spend) accent.
/// Codable + Hashable so it doubles as the Live Activity `ContentState`.
struct EnergyTrade: Codable, Hashable {
    enum Side: String, Codable { case sell, buy }

    var side: Side = .sell
    var ratePerKwh: Double = 4.31      // ฿ per kWh, signed by side at display time
    var kwh: Double = 5.4
    var progress: Double = 0.68        // 0…1 fill
    var zone: String = "Zone 2"
    var liveFor: String = "6 min"
    /// Empty → side-aware default ("4 buyers" selling / "4 sellers" buying).
    var counterparty: String = ""
    /// Bumped on each live update to drive the flow-bars pulse in the island
    /// (the OS only animates between ContentState updates, not free-running).
    var phase: Int = 0

    var selling: Bool { side == .sell }
    var accent: Color { selling ? .islandUp : .islandDown }
    var title: String { selling ? "Selling energy" : "Buying energy" }
    /// Signed rate string, e.g. "+฿4.31" / "−฿4.28".
    var rateText: String { (selling ? "+฿" : "−฿") + String(format: "%.2f", ratePerKwh) }
    var earnedLabel: String { selling ? "Earned" : "Spent" }
    /// Side-aware counterparty when not explicitly set.
    var counterpartyText: String {
        counterparty.isEmpty ? (selling ? "4 buyers" : "4 sellers") : counterparty
    }
    var earnedText: String { (selling ? "+฿" : "−฿") + String(format: "%.2f", kwh * 4.3) }
}

// MARK: - Palette (island chrome is pure black; accents from the prototype)

extension Color {
    static let islandUp     = Color(hex: "2FD08A")   // sell / earning
    static let islandDown   = Color(hex: "FF5C6C")   // buy / spending
    static let islandViolet = Color(hex: "9B6BFF")
    static let islandVioletSoft = Color(hex: "C9B4FF")
    static let islandText    = Color(hex: "F4F1FA")
    static let islandMuted   = Color(hex: "F4F1FA", alpha: 0.6)   // rgba(244,241,250,.6)
    static let islandFaint   = Color(hex: "F4F1FA", alpha: 0.4)   // rgba(244,241,250,.4)
}
