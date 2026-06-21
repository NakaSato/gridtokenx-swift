//
//  DashboardEasyView.swift
//  gridtokexios
//
//  06c · Dashboard "Easy view" — age-friendly / accessible landing.
//  Larger type, bigger tap targets, plain language, high contrast, fewer
//  choices on screen. Native port of mock-ui/dashboard-easy.jsx
//  (DashboardEasy + BigButton). The one big number is "earned today"; the
//  two primary actions are huge, labelled buttons. The easy-view palette
//  brightens `sub` for contrast.
//

import SwiftUI

struct DashboardEasyView: View {
    var name: String = "Maya"
    var onBack: () -> Void = {}
    var onSell: () -> Void = {}
    var onBuy: () -> Void = {}
    var onAccessibility: () -> Void = {}

    @ObserveInjection var inject

    // Easy-view palette (mock-ui `E`) — brighter than the default for contrast.
    private enum E {
        static let bg      = Color(hex: "#0B0712")
        static let surface = Color.white.opacity(0.06)
        static let border  = Color.white.opacity(0.11)
        static let text    = Color(hex: "#FBFAFF")
        static let sub     = Color(hex: "#FBFAFF", alpha: 0.74)   // brighter for contrast
        static let faint   = Color(hex: "#FBFAFF", alpha: 0.5)
        static let violet  = Color(hex: "#B594FF")
        static let up      = Color(hex: "#43E6A0")
        static let upBg    = Color(hex: "#43E6A0", alpha: 0.16)
        static let sellInk = Color(hex: "#053123")
    }

    var body: some View {
        ZStack {
            E.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 14) {
                        earningsCard
                        solarStatus
                        priceRow
                        VStack(spacing: 12) {
                            bigSellButton
                            bigBuyButton
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 26)
                    .gtxUniversalWidth()
                }
            }
            .gtxUniversalWidth()
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .simultaneousGesture(
            DragGesture(minimumDistance: 18).onEnded { v in
                if v.startLocation.x < 24, v.translation.width > 70, abs(v.translation.height) < 60 {
                    onBack()
                }
            })
        .enableInjection()
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1) {
                Text("Good morning")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(E.sub)
                Text(name)
                    .font(.system(size: 27, weight: .heavy))
                    .tracking(-0.5)
                    .foregroundStyle(E.text)
            }
            Spacer()
            Button(action: onAccessibility) {
                Image(systemName: "figure.roll")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(E.violet)
                    .frame(width: 48, height: 48)
                    .background(E.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(E.border, lineWidth: 1))
            }
            .accessibilityLabel("Accessibility view")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Earnings (the one big number)

    private var earningsCard: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.12))
                .frame(width: 150, height: 150)
                .offset(x: 30, y: -40)

            VStack(alignment: .leading, spacing: 2) {
                Text("You earned today")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                Text("฿362")
                    .font(.system(size: 44, weight: .black, design: .monospaced))
                    .tracking(-1.5)
                    .foregroundStyle(.white)
                Text("from selling 84 kWh of your solar")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(LinearGradient.gtxBrand, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: GTXColor.violetDeep.opacity(0.4), radius: 20, y: 16)
    }

    // MARK: - Solar status (plain language)

    private var solarStatus: some View {
        HStack(spacing: 16) {
            iconTile("sun.max.fill", color: E.up, bg: E.upBg)
            VStack(alignment: .leading, spacing: 2) {
                Text("Your solar is on")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(E.text)
                (Text("Producing ")
                    + Text("5.2 kW").fontWeight(.bold).foregroundColor(E.text)
                    + Text(" right now"))
                    .font(.system(size: 15.5))
                    .foregroundStyle(E.sub)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .cardBackground()
    }

    // MARK: - Price (large, clear)

    private var priceRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Best sell price now")
                    .font(.system(size: 15.5, weight: .medium))
                    .foregroundStyle(E.sub)
                (Text("฿4.50").font(.system(size: 30, weight: .bold, design: .monospaced))
                    + Text(" /kWh").font(.system(size: 17, weight: .semibold)).foregroundColor(E.sub))
                    .foregroundStyle(E.text)
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 13, weight: .heavy))
                Text("Good").font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(E.up)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(E.upBg, in: Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .cardBackground()
    }

    // MARK: - Big actions (huge, labelled)

    private var bigSellButton: some View {
        EasyBigButton(
            icon: "arrow.up", label: "Sell my energy",
            hint: "Send your extra power to neighbours",
            fill: AnyShapeStyle(E.up), ink: E.sellInk,
            glow: E.up.opacity(0.32), action: onSell
        )
    }

    private var bigBuyButton: some View {
        EasyBigButton(
            icon: "arrow.down", label: "Buy energy",
            hint: "Get clean power from your area",
            fill: AnyShapeStyle(LinearGradient.gtxBrand), ink: .white,
            glow: GTXColor.violetDeep.opacity(0.4), action: onBuy
        )
    }

    private func iconTile(_ symbol: String, color: Color, bg: Color) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 28, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: 50, height: 50)
            .background(bg, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

// MARK: - Big tappable action row (mock-ui BigButton)

private struct EasyBigButton: View {
    let icon: String
    let label: String
    let hint: String
    let fill: AnyShapeStyle
    let ink: Color
    let glow: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(ink)
                    .frame(width: 48, height: 48)
                    .background(.white.opacity(0.22), in: RoundedRectangle(cornerRadius: 15, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 21, weight: .bold))
                        .tracking(-0.2)
                    Text(hint)
                        .font(.system(size: 14.5, weight: .medium))
                        .opacity(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(ink)

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ink)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .background(fill, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: glow, radius: 15, y: 12)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(label)
    }
}

private extension View {
    /// Surface card with hairline border used across the easy view.
    func cardBackground() -> some View {
        background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.11), lineWidth: 1))
    }
}

#Preview {
    DashboardEasyView()
}
