//
//  SettingsView.swift
//  gridtokexios
//
//  08 · Settings (Dark) — account, energy/grid, wallet, security, notification,
//  and preference controls. Native port of mock-ui/settings.jsx (dark theme
//  only). Reached from the Wallet gear button. Toggles + zone picker drive local
//  @State; rows are presentational stubs (no backing store yet).
//

import SwiftUI

struct SettingsView: View {
    var onBack: () -> Void = {}
    var onVerifyNDID: () -> Void = {}
    var onOpenRegister: () -> Void = {}
    var onOpenBilling: () -> Void = {}
    var onOpenOrders: () -> Void = {}
    var onOpenGridMap: () -> Void = {}

    @ObserveInjection var inject

    // Toggle state (mock-ui `t`).
    @State private var autoSell = true
    @State private var faceID   = true
    @State private var fills    = true
    @State private var alerts   = false
    @State private var grid     = true

    @State private var zone = "intra"
    @State private var zonePicker = false
    @State private var appearance = "dark"   // dark-only port; seg is presentational
    @State private var editing = false       // profile card → Edit profile subscreen

    private let zones: [(String, String, String)] = [
        ("intra", "Intra Zone", "Trade only within your local zone"),
        ("inter", "Inter Zone", "Trade across neighbouring zones"),
        ("open",  "Open Market", "Match with anyone on the grid"),
    ]
    private var zoneLabel: String { zones.first { $0.0 == zone }?.1 ?? "" }

    // Palette (mock-ui `SET_DARK` + `SET`).
    private enum S {
        static let bg      = Color(hex: "#0B0712")
        static let surface = Color.white.opacity(0.05)
        static let border  = Color.white.opacity(0.08)
        static let rowSep  = Color.white.opacity(0.07)
        static let text    = Color(hex: "#F4F1FA")
        static let muted   = Color(hex: "#F4F1FA", alpha: 0.5)
        static let faint   = Color(hex: "#F4F1FA", alpha: 0.3)
        static let link    = Color(hex: "#C9B4FF")
        static let seg     = Color.white.opacity(0.06)
        static let violet  = Color(hex: "#9B6BFF")
        static let down    = Color(hex: "#FF5C6C")
        static let grad    = LinearGradient(
            colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            if editing {
                ProfileEditView(onBack: { withAnimation(.smooth(duration: 0.3)) { editing = false } })
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                settings
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }

    private var settings: some View {
        ZStack {
            S.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(spacing: 22) {
                        profileCard

                        section("Energy & grid") {
                            row("gauge.medium", "Linked meter", detail: "Solar 5.2 kW") { onOpenRegister() }
                            divider(56)
                            row("map", "Grid map") { onOpenGridMap() }
                            divider(56)
                            row("mappin.and.ellipse", "Trading zone", detail: zoneLabel) { zonePicker = true }
                            divider(56)
                            toggleRow("bolt.fill", "Auto-sell surplus", $autoSell)
                            divider(56)
                            row("chart.line.uptrend.xyaxis", "Default sell price", detail: "฿4.50/kWh")
                        }

                        section("Wallet & payments") {
                            row("creditcard", "Payout method", detail: "SCB ••4192")
                            divider(56)
                            row("doc.text", "Bills & statements") { onOpenBilling() }
                            divider(56)
                            row("list.bullet.rectangle", "Order history") { onOpenOrders() }
                            divider(56)
                            row("dollarsign.circle", "Currency", detail: "THB ฿")
                            divider(56)
                            row("bolt.fill", "Auto-withdraw", detail: "Off")
                        }

                        section("Security") {
                            toggleRow("faceid", "Face ID unlock", $faceID)
                            divider(56)
                            row("lock.fill", "Two-factor auth", detail: "On")
                            divider(56)
                            row("checkmark.shield.fill", "Identity (NDID)", detail: "Verify") { onVerifyNDID() }
                            divider(56)
                            row("key.fill", "Recovery phrase")
                        }

                        section("Notifications") {
                            toggleRow("bell.fill", "Trade fills", $fills)
                            divider(56)
                            toggleRow("exclamationmark.triangle.fill", "Price alerts", $alerts)
                            divider(56)
                            toggleRow("square.grid.2x2.fill", "Grid events", $grid)
                        }

                        section("Preferences") {
                            rowCustom("moon.fill", "Appearance") {
                                miniSeg($appearance, [("dark", "Dark"), ("light", "Light")])
                            }
                            divider(56)
                            row("globe", "Language", detail: "English")
                        }

                        section("About") {
                            row("questionmark.circle", "Help & support")
                            divider(56)
                            row("doc.text", "Terms & privacy")
                        }

                        section(nil) {
                            row("rectangle.portrait.and.arrow.right", "Sign out", danger: true)
                        }

                        Text("GridTokenX · v2.2.0")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(S.faint)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
        }
        .overlay { if zonePicker { zoneSheet } }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        #if DEBUG
        .onAppear { if ProcessInfo.processInfo.arguments.contains("EDIT_PROFILE") { editing = true } }
        #endif
        // Edge-swipe-back: drag from left edge slides the whole page back to Wallet.
        .simultaneousGesture(
            DragGesture(minimumDistance: 18)
                .onEnded { v in
                    if v.startLocation.x < 24, v.translation.width > 70,
                       abs(v.translation.height) < 60 {
                        onBack()
                    }
                }
        )
        .enableInjection()
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(S.link)
                    .frame(width: 38, height: 38)
                    .background(S.surface, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(S.border, lineWidth: 1))
            }
            .accessibilityLabel("Back")

            Text("Settings")
                .font(.system(size: 22, weight: .bold)).tracking(-0.4)
                .foregroundStyle(S.text)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8).padding(.bottom, 8)
    }

    // MARK: - Profile card

    private var profileCard: some View {
        HStack(spacing: 14) {
            Circle().fill(S.grad)
                .frame(width: 52, height: 52)
                .overlay(Text("MC").font(.system(size: 19, weight: .bold)).foregroundStyle(.white))
                .shadow(color: Color(hex: "#7C3AED", alpha: 0.4), radius: 8, y: 6)
            VStack(alignment: .leading, spacing: 2) {
                Text("Maya Chen").font(.system(size: 17, weight: .bold)).foregroundStyle(S.text)
                Text("Prosumer · Zone 2 · Verified").font(.system(size: 13)).foregroundStyle(S.muted)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 15, weight: .semibold)).foregroundStyle(S.faint)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(S.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(S.border, lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.smooth(duration: 0.3)) { editing = true } }
    }

    // MARK: - Section

    private func section<Content: View>(_ header: String?, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header {
                Text(header.uppercased())
                    .font(.system(size: 12.5, weight: .semibold)).tracking(0.5)
                    .foregroundStyle(S.muted)
                    .padding(.horizontal, 6).padding(.bottom, 8)
            }
            VStack(spacing: 0) { content() }
                .background(S.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(S.border, lineWidth: 1))
        }
    }

    private func divider(_ leading: CGFloat) -> some View {
        Rectangle().fill(S.rowSep).frame(height: 1).padding(.leading, leading)
    }

    // MARK: - Rows

    private func iconTile(_ icon: String, danger: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(danger ? AnyShapeStyle(S.down.opacity(0.16)) : AnyShapeStyle(S.grad))
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(danger ? S.down : Color.white)
        }
        .frame(width: 30, height: 30)
    }

    /// Detail/chevron row (tappable when `onTap` given).
    private func row(_ icon: String, _ title: String, detail: String? = nil,
                     danger: Bool = false, onTap: (() -> Void)? = nil) -> some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 12) {
                iconTile(icon, danger: danger)
                Text(title)
                    .font(.system(size: 15.5, weight: danger ? .semibold : .regular))
                    .foregroundStyle(danger ? S.down : S.text)
                Spacer(minLength: 8)
                if let detail {
                    Text(detail)
                        .font(.system(size: 14.5,
                                      design: detail.contains(where: { $0.isNumber || $0 == "฿" }) ? .monospaced : .default))
                        .foregroundStyle(S.muted)
                }
                if !danger {
                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(S.faint)
                }
            }
            .padding(.horizontal, 14).frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil && !danger)
    }

    /// Trailing toggle row.
    private func toggleRow(_ icon: String, _ title: String, _ isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            iconTile(icon, danger: false)
            Text(title).font(.system(size: 15.5)).foregroundStyle(S.text)
            Spacer(minLength: 8)
            gtxToggle(isOn)
        }
        .padding(.horizontal, 14).frame(minHeight: 52)
    }

    /// Row with a custom trailing accessory (e.g. the appearance segment).
    private func rowCustom<Right: View>(_ icon: String, _ title: String,
                                        @ViewBuilder _ right: () -> Right) -> some View {
        HStack(spacing: 12) {
            iconTile(icon, danger: false)
            Text(title).font(.system(size: 15.5)).foregroundStyle(S.text)
            Spacer(minLength: 8)
            right()
        }
        .padding(.horizontal, 14).frame(minHeight: 52)
    }

    // MARK: - Controls

    private func gtxToggle(_ isOn: Binding<Bool>) -> some View {
        Button {
            withAnimation(.smooth(duration: 0.2)) { isOn.wrappedValue.toggle() }
        } label: {
            Capsule()
                .fill(isOn.wrappedValue ? AnyShapeStyle(S.grad) : AnyShapeStyle(Color(hex: "#8C8C96", alpha: 0.32)))
                .frame(width: 50, height: 30)
                .overlay(alignment: .leading) {
                    Circle().fill(.white).frame(width: 26, height: 26)
                        .shadow(color: .black.opacity(0.3), radius: 2.5, y: 1)
                        .offset(x: isOn.wrappedValue ? 22 : 2)   // slide leading→trailing
                }
        }
        .buttonStyle(.plain)
    }

    private func miniSeg(_ value: Binding<String>, _ options: [(String, String)]) -> some View {
        HStack(spacing: 3) {
            ForEach(options, id: \.0) { key, label in
                let on = value.wrappedValue == key
                Button { withAnimation(.easeInOut(duration: 0.15)) { value.wrappedValue = key } } label: {
                    Text(label)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(on ? .white : S.muted)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background { if on { S.grad.clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous)) } }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(S.seg, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - Trading zone sheet

    private var zoneSheet: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture { withAnimation(.smooth(duration: 0.2)) { zonePicker = false } }

            VStack(alignment: .leading, spacing: 0) {
                Capsule().fill(S.rowSep).frame(width: 38, height: 5)
                    .frame(maxWidth: .infinity).padding(.bottom, 14)
                Text("Trading zone").font(.system(size: 17, weight: .bold)).foregroundStyle(S.text)
                    .padding(.horizontal, 2)
                Text("Choose how far your buy & sell orders can reach.")
                    .font(.system(size: 13)).foregroundStyle(S.muted)
                    .padding(.horizontal, 2).padding(.top, 4).padding(.bottom, 14)

                VStack(spacing: 0) {
                    ForEach(Array(zones.enumerated()), id: \.offset) { i, z in
                        if i > 0 { Rectangle().fill(S.rowSep).frame(height: 1) }
                        let on = zone == z.0
                        Button {
                            zone = z.0
                            withAnimation(.smooth(duration: 0.2)) { zonePicker = false }
                        } label: {
                            HStack(spacing: 12) {
                                Text("\(i + 1)")
                                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                                    .foregroundStyle(on ? .white : S.muted)
                                    .frame(width: 24, height: 24)
                                    .background(on ? AnyShapeStyle(S.grad) : AnyShapeStyle(Color(hex: "#7F7F8C", alpha: 0.18)),
                                                in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(z.1).font(.system(size: 15.5, weight: .semibold)).foregroundStyle(S.text)
                                    Text(z.2).font(.system(size: 12.5)).foregroundStyle(S.muted)
                                }
                                Spacer(minLength: 8)
                                if on {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold)).foregroundStyle(S.violet)
                                }
                            }
                            .padding(.horizontal, 16).padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(S.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(S.border, lineWidth: 1))
            }
            .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 32)
            .background(
                UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous)
                    .fill(S.bg)
                    .overlay(UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous)
                        .stroke(S.border, lineWidth: 1))
                    .ignoresSafeArea(edges: .bottom)
            )
            .transition(.move(edge: .bottom))
        }
    }
}

#Preview {
    SettingsView()
}
