//
//  ProfileWalletView.swift
//  gridtokexios
//
//  07 · Profile & Wallet — portfolio balance, token holdings, activity, and
//  account settings. Native port of mock-ui/wallet.jsx.
//
//  Standardized on the GTX design system (tokens + GTXKit). No local palette.
//

import SwiftUI

struct ProfileWalletView: View {
    var onBack: () -> Void = {}
    var onSend: () -> Void = {}
    var onDeposit: () -> Void = {}
    var onWithdraw: () -> Void = {}
    var onSettings: () -> Void = {}

    @ObserveInjection var inject
    @State private var tab: Tab = .tokens

    private enum Tab { case tokens, activity }

    var body: some View {
        ZStack {
            GTXColor.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        profileRow
                        balanceHero
                        actions
                        monthStats
                        segmented
                        list
                        settingsRows
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                    .gtxUniversalWidth()
                }
            }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .enableInjection()
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(GTXColor.text)
                    .frame(width: 38, height: 38)
                    .background(GTXColor.surface, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(GTXColor.border, lineWidth: 1))
            }
            .accessibilityLabel("Back")

            Text("Wallet")
                .font(GTXFont.heading)
                .tracking(-0.4)
                .padding(.leading, 4)

            Spacer()

            Button(action: onSettings) {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(GTXColor.surface)
                    .frame(width: 38, height: 38)
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(GTXColor.border, lineWidth: 1))
                    .overlay(Image(systemName: "gearshape").font(.system(size: 17)).foregroundStyle(GTXColor.muted))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
        .foregroundStyle(GTXColor.text)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .gtxUniversalWidth()
    }

    // MARK: - Profile

    private var profileRow: some View {
        HStack(spacing: 13) {
            Circle()
                .fill(LinearGradient.gtxBrand)
                .frame(width: 54, height: 54)
                .overlay(Text("MC").font(.system(size: 20, weight: .bold)).foregroundStyle(.white))
                .gtxBrandGlow(radius: 12, y: 6, strength: 0.45)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Maya Chen").font(.system(size: 18, weight: .bold))
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 15)).foregroundStyle(GTXColor.violet)
                }
                Text("Prosumer · Zone 2 · Bangkok")
                    .font(GTXFont.label).foregroundStyle(GTXColor.muted)
            }
            Spacer()
        }
        .foregroundStyle(GTXColor.text)
    }

    // MARK: - Balance hero

    private let alloc: [(String, Double, Double)] = [
        ("GTX", 4182, 0.92), ("kWh", 53.5, 0.55), ("THB", 320, 0.28)
    ]

    private var balanceHero: some View {
        let total = alloc.reduce(0) { $0 + $1.1 }
        return ZStack(alignment: .topTrailing) {
            Circle().fill(Color.white.opacity(GTXOpacity.raised))
                .frame(width: 150, height: 150)
                .offset(x: 30, y: -40)
            VStack(alignment: .leading, spacing: 0) {
                Text("Portfolio value")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.78))
                Text("฿4,502.40")
                    .font(.system(size: 36, weight: .heavy, design: .monospaced))
                    .tracking(-0.5)
                    .padding(.top, 4)
                Text("↑ ฿108.20 · 2.45% today")
                    .font(.system(size: 12.5, weight: .bold))
                    .padding(.horizontal, 9).padding(.vertical, 3)
                    .background(Color.white.opacity(0.2), in: Capsule())
                    .padding(.top, 6)

                // allocation bar
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        ForEach(alloc, id: \.0) { item in
                            Rectangle()
                                .fill(Color.white.opacity(item.2))
                                .frame(width: geo.size.width * item.1 / total)
                        }
                    }
                }
                .frame(height: 7)
                .background(Color.black.opacity(0.18))
                .clipShape(Capsule())
                .padding(.top, 16)

                HStack(spacing: 14) {
                    ForEach(alloc, id: \.0) { item in
                        HStack(spacing: 5) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(item.2))
                                .frame(width: 7, height: 7)
                            Text("\(item.0) \(Int((item.1 / total * 100).rounded()))%")
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.82))
                        }
                    }
                }
                .padding(.top, 9)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 20).padding(.bottom, 18)
        }
        .background(LinearGradient.gtxBrand)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .gtxBrandGlow(radius: 20, y: 14, strength: 0.4)
    }

    // MARK: - Actions

    private var actions: some View {
        HStack(spacing: 8) {
            actionBtn("arrow.down", "Deposit", primary: true, action: onDeposit)
            actionBtn("arrow.up", "Send", action: onSend)
            actionBtn("building.columns", "Withdraw", action: onWithdraw)
            actionBtn("arrow.left.arrow.right", "Swap")
        }
    }

    private func actionBtn(_ icon: String, _ label: String, primary: Bool = false,
                           action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(primary ? AnyShapeStyle(LinearGradient.gtxBrand) : AnyShapeStyle(GTXColor.surface))
                    if !primary {
                        RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(GTXColor.border, lineWidth: 1)
                    }
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(primary ? Color.white : GTXColor.violetSoft)
                }
                .frame(height: 56)
                .gtxBrandGlow(radius: 10, y: 8, strength: primary ? 0.4 : 0)
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(primary ? GTXColor.text : GTXColor.muted)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Month stats

    private var monthStats: some View {
        HStack(spacing: 10) {
            ForEach(Array([("Sold", "84 kWh", false), ("Earned", "฿362", false), ("CO₂ saved", "18.4 kg", true)].enumerated()), id: \.offset) { _, s in
                VStack(alignment: .leading, spacing: 4) {
                    Text(s.0.uppercased())
                        .font(.system(size: 10.5)).tracking(0.3).foregroundStyle(GTXColor.muted)
                    Text(s.1)
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(s.2 ? GTXColor.buy : GTXColor.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 13).padding(.vertical, 12)
                .gtxCard(radius: 14, padding: nil)
            }
        }
    }

    // MARK: - Segmented

    private var segmented: some View {
        HStack(spacing: 6) {
            segBtn(.tokens, "Tokens")
            segBtn(.activity, "Activity")
        }
        .padding(5)
        .gtxCard(radius: 14, padding: nil)
    }

    private func segBtn(_ t: Tab, _ label: String) -> some View {
        let on = tab == t
        return Button { withAnimation(.easeInOut(duration: 0.15)) { tab = t } } label: {
            Text(label)
                .font(.system(size: 14.5, weight: .semibold))
                .foregroundStyle(on ? Color.white : GTXColor.muted)
                .frame(maxWidth: .infinity).frame(height: 38)
                .background {
                    if on {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient.gtxBrand)
                            .gtxBrandGlow(radius: 7, y: 4, strength: 0.4)
                    }
                }
        }
    }

    // MARK: - List

    private var list: some View {
        VStack(spacing: 0) {
            if tab == .tokens {
                ForEach(Array(holdings.enumerated()), id: \.offset) { i, h in
                    if i > 0 { divider(69) }
                    holdingRow(h)
                }
            } else {
                ForEach(Array(txns.enumerated()), id: \.offset) { i, t in
                    if i > 0 { divider(65) }
                    txnRow(t)
                }
            }
        }
        .gtxCard(radius: 18, padding: nil)
    }

    private func divider(_ leading: CGFloat) -> some View {
        Rectangle().fill(GTXColor.border).frame(height: 1).padding(.leading, leading)
    }

    // Holdings
    private struct Holding { let mark: AnyView; let name, sub, value, amount: String; let change: Int }
    private var holdings: [Holding] {
        [
            Holding(mark: AnyView(gtxGlyph), name: "GridTokenX", sub: "968.40 GTX", value: "฿4,182", amount: "+2.45%", change: 1),
            Holding(mark: AnyView(markIcon("bolt.fill", GTXColor.gold, bg: GTXColor.gold.opacity(0.18), border: GTXColor.gold.opacity(0.4))),
                    name: "kWh credits", sub: "Tradeable energy", value: "12.4 kWh", amount: "≈ ฿53.50", change: 0),
            Holding(mark: AnyView(markText("฿")), name: "THB cash", sub: "Settlement balance", value: "฿320.00", amount: "Available", change: 0),
        ]
    }

    private func holdingRow(_ h: Holding) -> some View {
        HStack(spacing: 13) {
            h.mark
            VStack(alignment: .leading, spacing: 2) {
                Text(h.name).font(.system(size: 15.5, weight: .semibold))
                Text(h.sub).font(.system(size: 12.5)).foregroundStyle(GTXColor.faint)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(h.value).font(.system(size: 15, weight: .bold, design: .monospaced))
                Text(h.amount)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(h.change > 0 ? GTXColor.buy : h.change < 0 ? GTXColor.sell : GTXColor.faint)
            }
        }
        .foregroundStyle(GTXColor.text)
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    private var gtxGlyph: some View {
        LazyVGrid(columns: [GridItem(.fixed(6), spacing: 3), GridItem(.fixed(6), spacing: 3)], spacing: 3) {
            ForEach(0..<4, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i == 0 ? Color.white : Color.white.opacity(0.62))
                    .frame(width: 6, height: 6)
            }
        }
        .frame(width: 40, height: 40)
        .background(LinearGradient.gtxBrand, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func markIcon(_ icon: String, _ color: Color, bg: Color, border: Color) -> some View {
        Image(systemName: icon).font(.system(size: 18)).foregroundStyle(color)
            .frame(width: 40, height: 40)
            .background(bg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(border, lineWidth: 1))
    }

    private func markText(_ s: String) -> some View {
        Text(s).font(.system(size: 18, weight: .heavy, design: .monospaced)).foregroundStyle(GTXColor.violetSoft)
            .frame(width: 40, height: 40)
            .background(GTXColor.surface2, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(GTXColor.border, lineWidth: 1))
    }

    // Transactions
    private struct Txn { let into: Bool; let title, sub, amt: String; let pos: Bool }
    private let txns: [Txn] = [
        Txn(into: true, title: "Sold 5.4 kWh", sub: "Zone 2 → Zone 4 · 2h ago", amt: "+฿23.20", pos: true),
        Txn(into: true, title: "Solar payout", sub: "Daily generation · 6h ago", amt: "+฿88.40", pos: true),
        Txn(into: false, title: "Bought 3.2 kWh", sub: "Zone 1 → Zone 2 · yesterday", amt: "−฿13.70", pos: false),
        Txn(into: false, title: "Withdraw to bank", sub: "SCB ••4192 · yesterday", amt: "−฿200.00", pos: false),
        Txn(into: true, title: "Deposit", sub: "PromptPay · 3d ago", amt: "+฿500.00", pos: true),
    ]

    private func txnRow(_ t: Txn) -> some View {
        let c = t.pos ? GTXColor.buy : GTXColor.sell
        return HStack(spacing: 13) {
            Image(systemName: t.into ? "arrow.down" : "arrow.up")
                .font(.system(size: 15, weight: .semibold)).foregroundStyle(c)
                .frame(width: 36, height: 36)
                .background(c.opacity(GTXOpacity.chip), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(t.title).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(GTXColor.text)
                Text(t.sub).font(.system(size: 12)).foregroundStyle(GTXColor.faint)
            }
            Spacer()
            Text(t.amt).font(.system(size: 14.5, weight: .bold, design: .monospaced)).foregroundStyle(c)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
    }

    // MARK: - Settings rows

    private let settings: [(String, String, String)] = [
        ("gauge.medium", "Linked meter", "Solar 5.2 kW"),
        ("building.columns.fill", "Payout method", "SCB ••4192"),
        ("checkmark.shield.fill", "Security & recovery", ""),
    ]

    private var settingsRows: some View {
        VStack(spacing: 0) {
            ForEach(Array(settings.enumerated()), id: \.offset) { i, row in
                if i > 0 { divider(60) }
                HStack(spacing: 13) {
                    Image(systemName: row.0)
                        .font(.system(size: 16)).foregroundStyle(GTXColor.violetSoft)
                        .frame(width: 32, height: 32)
                        .background(GTXColor.violet.opacity(GTXOpacity.raised), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    Text(row.1).font(.system(size: 14.5, weight: .medium)).foregroundStyle(GTXColor.text)
                    Spacer()
                    if !row.2.isEmpty {
                        Text(row.2).font(.system(size: 13)).foregroundStyle(GTXColor.muted).padding(.trailing, 4)
                    }
                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(GTXColor.faint)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
            }
        }
        .gtxCard(radius: 18, padding: nil)
    }
}

#Preview {
    ProfileWalletView()
}
