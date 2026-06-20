//
//  ProfileWalletView.swift
//  gridtokexios
//
//  07 · Profile & Wallet — portfolio balance, token holdings, activity, and
//  account settings. Native port of mock-ui/wallet.jsx.
//

import SwiftUI

struct ProfileWalletView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject
    @State private var tab: Tab = .tokens

    private enum Tab { case tokens, activity }

    // Wallet palette — shared dark + purple system; green/red = gains/losses.
    private enum W {
        static let bg = Color(hex: "#0B0712")
        static let surface = Color.white.opacity(0.045)
        static let surface2 = Color.white.opacity(0.07)
        static let border = Color.white.opacity(0.09)
        static let text = Color(hex: "#F4F1FA")
        static let muted = Color(hex: "#F4F1FA", alpha: 0.54)
        static let faint = Color(hex: "#F4F1FA", alpha: 0.32)
        static let violet = Color(hex: "#9B6BFF")
        static let violetSoft = Color(hex: "#C9B4FF")
        static let up = Color(hex: "#2FD08A")
        static let down = Color(hex: "#FF5C6C")
        static let gold = Color(hex: "#E0A23C")
        static let grad = LinearGradient(
            colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            W.bg.ignoresSafeArea()

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
                    .foregroundStyle(W.text)
                    .frame(width: 38, height: 38)
                    .background(W.surface, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(W.border, lineWidth: 1))
            }
            .accessibilityLabel("Back")

            Text("Wallet")
                .font(.system(size: 22, weight: .bold))
                .tracking(-0.4)
                .padding(.leading, 4)

            Spacer()

            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(W.surface)
                .frame(width: 38, height: 38)
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(W.border, lineWidth: 1))
                .overlay(Image(systemName: "gearshape").font(.system(size: 17)).foregroundStyle(W.muted))
        }
        .foregroundStyle(W.text)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Profile

    private var profileRow: some View {
        HStack(spacing: 13) {
            Circle()
                .fill(W.grad)
                .frame(width: 54, height: 54)
                .overlay(Text("MC").font(.system(size: 20, weight: .bold)).foregroundStyle(.white))
                .shadow(color: Color(hex: "#7C3AED", alpha: 0.45), radius: 12, y: 6)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Maya Chen").font(.system(size: 18, weight: .bold))
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 15)).foregroundStyle(W.violet)
                }
                Text("Prosumer · Zone 2 · Bangkok")
                    .font(.system(size: 13)).foregroundStyle(W.muted)
            }
            Spacer()
        }
        .foregroundStyle(W.text)
    }

    // MARK: - Balance hero

    private let alloc: [(String, Double, Double)] = [
        ("GTX", 4182, 0.92), ("kWh", 53.5, 0.55), ("THB", 320, 0.28)
    ]

    private var balanceHero: some View {
        let total = alloc.reduce(0) { $0 + $1.1 }
        return ZStack(alignment: .topTrailing) {
            Circle().fill(Color.white.opacity(0.12))
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
        .background(W.grad)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(hex: "#7C3AED", alpha: 0.4), radius: 20, y: 14)
    }

    // MARK: - Actions

    private var actions: some View {
        HStack(spacing: 8) {
            actionBtn("arrow.down", "Deposit", primary: true)
            actionBtn("arrow.up", "Send")
            actionBtn("building.columns", "Withdraw")
            actionBtn("arrow.left.arrow.right", "Swap")
        }
    }

    private func actionBtn(_ icon: String, _ label: String, primary: Bool = false) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(primary ? AnyShapeStyle(W.grad) : AnyShapeStyle(W.surface))
                if !primary {
                    RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(W.border, lineWidth: 1)
                }
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(primary ? Color.white : W.violetSoft)
            }
            .frame(height: 56)
            .shadow(color: primary ? Color(hex: "#7C3AED", alpha: 0.4) : .clear, radius: 10, y: 8)
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(primary ? W.text : W.muted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Month stats

    private var monthStats: some View {
        HStack(spacing: 10) {
            ForEach(Array([("Sold", "84 kWh", false), ("Earned", "฿362", false), ("CO₂ saved", "18.4 kg", true)].enumerated()), id: \.offset) { _, s in
                VStack(alignment: .leading, spacing: 4) {
                    Text(s.0.uppercased())
                        .font(.system(size: 10.5)).tracking(0.3).foregroundStyle(W.muted)
                    Text(s.1)
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(s.2 ? W.up : W.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 13).padding(.vertical, 12)
                .background(W.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(W.border, lineWidth: 1))
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
        .background(W.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(W.border, lineWidth: 1))
    }

    private func segBtn(_ t: Tab, _ label: String) -> some View {
        let on = tab == t
        return Button { withAnimation(.easeInOut(duration: 0.15)) { tab = t } } label: {
            Text(label)
                .font(.system(size: 14.5, weight: .semibold))
                .foregroundStyle(on ? Color.white : W.muted)
                .frame(maxWidth: .infinity).frame(height: 38)
                .background {
                    if on {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(W.grad)
                            .shadow(color: Color(hex: "#7C3AED", alpha: 0.4), radius: 7, y: 4)
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
        .background(W.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(W.border, lineWidth: 1))
    }

    private func divider(_ leading: CGFloat) -> some View {
        Rectangle().fill(W.border).frame(height: 1).padding(.leading, leading)
    }

    // Holdings
    private struct Holding { let mark: AnyView; let name, sub, value, amount: String; let change: Int }
    private var holdings: [Holding] {
        [
            Holding(mark: AnyView(gtxGlyph), name: "GridTokenX", sub: "968.40 GTX", value: "฿4,182", amount: "+2.45%", change: 1),
            Holding(mark: AnyView(markIcon("bolt.fill", W.gold, bg: W.gold.opacity(0.18), border: W.gold.opacity(0.4))),
                    name: "kWh credits", sub: "Tradeable energy", value: "12.4 kWh", amount: "≈ ฿53.50", change: 0),
            Holding(mark: AnyView(markText("฿")), name: "THB cash", sub: "Settlement balance", value: "฿320.00", amount: "Available", change: 0),
        ]
    }

    private func holdingRow(_ h: Holding) -> some View {
        HStack(spacing: 13) {
            h.mark
            VStack(alignment: .leading, spacing: 2) {
                Text(h.name).font(.system(size: 15.5, weight: .semibold))
                Text(h.sub).font(.system(size: 12.5)).foregroundStyle(W.faint)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(h.value).font(.system(size: 15, weight: .bold, design: .monospaced))
                Text(h.amount)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(h.change > 0 ? W.up : h.change < 0 ? W.down : W.faint)
            }
        }
        .foregroundStyle(W.text)
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
        .background(W.grad, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func markIcon(_ icon: String, _ color: Color, bg: Color, border: Color) -> some View {
        Image(systemName: icon).font(.system(size: 18)).foregroundStyle(color)
            .frame(width: 40, height: 40)
            .background(bg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(border, lineWidth: 1))
    }

    private func markText(_ s: String) -> some View {
        Text(s).font(.system(size: 18, weight: .heavy, design: .monospaced)).foregroundStyle(W.violetSoft)
            .frame(width: 40, height: 40)
            .background(W.surface2, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(W.border, lineWidth: 1))
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
        let c = t.pos ? W.up : W.down
        return HStack(spacing: 13) {
            Image(systemName: t.into ? "arrow.down" : "arrow.up")
                .font(.system(size: 15, weight: .semibold)).foregroundStyle(c)
                .frame(width: 36, height: 36)
                .background(c.opacity(0.14), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(t.title).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(W.text)
                Text(t.sub).font(.system(size: 12)).foregroundStyle(W.faint)
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
                        .font(.system(size: 16)).foregroundStyle(W.violetSoft)
                        .frame(width: 32, height: 32)
                        .background(W.violet.opacity(0.12), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    Text(row.1).font(.system(size: 14.5, weight: .medium)).foregroundStyle(W.text)
                    Spacer()
                    if !row.2.isEmpty {
                        Text(row.2).font(.system(size: 13)).foregroundStyle(W.muted).padding(.trailing, 4)
                    }
                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(W.faint)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
            }
        }
        .background(W.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(W.border, lineWidth: 1))
    }
}

#Preview {
    ProfileWalletView()
}
