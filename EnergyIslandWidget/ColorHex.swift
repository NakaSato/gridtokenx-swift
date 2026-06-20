//
//  ColorHex.swift
//  EnergyIslandWidget
//
//  Widget-target copy of the Color(hex:) helper. The app target gets the same
//  initializer from GTXDesignTokens.swift (which is app-only), so the shared
//  island views resolve Color(hex:) in either target without a duplicate symbol.
//

import SwiftUI

extension Color {
    init(hex: String, alpha: Double = 1.0) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        s = s.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
