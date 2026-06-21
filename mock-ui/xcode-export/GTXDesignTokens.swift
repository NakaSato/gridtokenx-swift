//  GTXDesignTokens.swift
//  GridTokenX — design tokens exported from the HTML prototype.
//  Drop into your Xcode project. SwiftUI.
//
//  Colors, gradient, spacing, radii and type ramp used across all screens.

import SwiftUI

// MARK: - Color hex helper
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

// MARK: - Palette
enum GTXColor {
    // Surfaces (dark theme)
    static let bg          = Color(hex: "#0B0712")   // app background
    static let bg2         = Color(hex: "#0E0A18")   // raised panel
    static let surface     = Color.white.opacity(0.05)
    static let surface2    = Color.white.opacity(0.07)
    static let border      = Color.white.opacity(0.09)
    static let hairline    = Color.white.opacity(0.08)

    // Text
    static let text        = Color(hex: "#F4F1FA")
    static let muted       = Color(hex: "#F4F1FA", alpha: 0.54)
    static let faint       = Color(hex: "#F4F1FA", alpha: 0.32)

    // Brand (primary)
    static let violet      = Color(hex: "#9B6BFF")
    static let violetSoft  = Color(hex: "#C9B4FF")
    static let violetDeep  = Color(hex: "#7C3AED")
    static let violetLight = Color(hex: "#A974FF")

    // Semantic — reserved for buy/sell & gains/losses only
    static let buy         = Color(hex: "#2FD08A")   // up / positive
    static let sell        = Color(hex: "#FF5C6C")   // down / destructive
    static let warning     = Color(hex: "#FFD166")

    // Light theme (Settings → Appearance: Light)
    static let lightBg     = Color(hex: "#EEE9F6")
    static let lightSurface = Color.white
    static let lightText   = Color(hex: "#1B1430")
    static let lightMuted  = Color(hex: "#1B1430", alpha: 0.55)
}

// MARK: - Brand gradient (135°, top-left → bottom-right)
extension LinearGradient {
    static let gtxBrand = LinearGradient(
        colors: [GTXColor.violetLight, GTXColor.violetDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Spacing & radii
enum GTXSpacing {
    static let screenPadding: CGFloat = 24
    static let gap: CGFloat = 16
    static let gapSmall: CGFloat = 8
}

enum GTXRadius {
    static let field: CGFloat = 14
    static let card: CGFloat = 16
    static let cardLarge: CGFloat = 20
    static let button: CGFloat = 16
    static let pill: CGFloat = 999
}

// MARK: - Type ramp (system SF Pro; monospace = SF Mono)
enum GTXFont {
    static let display = Font.system(size: 40, weight: .heavy)   // hero headlines
    static let title   = Font.system(size: 28, weight: .bold)    // screen titles
    static let heading = Font.system(size: 22, weight: .bold)
    static let body    = Font.system(size: 16, weight: .regular)
    static let label   = Font.system(size: 13, weight: .semibold)
    static let caption = Font.system(size: 12, weight: .regular)
    static let mono    = Font.system(size: 16, weight: .bold, design: .monospaced) // figures
}

// MARK: - Primary button style
struct GTXPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(LinearGradient.gtxBrand)
            .clipShape(RoundedRectangle(cornerRadius: GTXRadius.button, style: .continuous))
            .shadow(color: GTXColor.violetDeep.opacity(0.42), radius: 18, y: 10)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
