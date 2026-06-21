//
//  DashboardLiveView.swift
//  gridtokexios
//
//  06 · Dashboard (live) — the full P2P energy trading dashboard.
//  Header price ticker + sparkline, range chips, Trade / Market tabs, and a
//  sticky side-aware CTA. Native port of mock-ui/dashboard.jsx.
//  Reached from the easy Dashboard's "Sell my energy"; the CTA fires the
//  energy Live Activity via `onTrade`.
//

import SwiftUI

struct DashboardLiveView: View {
    var onBack: () -> Void = {}
    /// Preselected order side (e.g. `.sell` when arriving from "Sell my energy").
    var initialSide: Side = .buy
    /// Opens the in-app notifications inbox (header bell).
    var onNotifications: () -> Void = {}
    /// Fired by the sticky CTA for a Buy/Sell order — starts the Live Activity.
    var onTrade: (EnergyTrade) -> Void = { _ in }
    /// Fired by the sticky CTA when the DCA side is active — opens DCA setup.
    var onSetupDCA: () -> Void = {}

    @ObserveInjection var inject

    // ── constants (mock-ui parity) ──
    private static let series: [String: [Double]] = [
        "1H": [4.28,4.30,4.27,4.31,4.29,4.33,4.30,4.34,4.32,4.35,4.33,4.36,4.34,4.38,4.36,4.39,4.37,4.40,4.38,4.32],
        "1D": [4.10,4.14,4.09,4.18,4.22,4.16,4.24,4.20,4.28,4.25,4.30,4.27,4.33,4.29,4.36,4.31,4.34,4.38,4.35,4.32],
        "1W": [3.92,4.02,3.96,4.10,4.06,4.18,4.12,4.22,4.16,4.28,4.24,4.20,4.30,4.26,4.34,4.29,4.36,4.31,4.38,4.32],
        "1M": [3.70,3.85,3.78,3.95,4.05,3.98,4.12,4.08,4.20,4.14,4.26,4.18,4.30,4.22,4.34,4.28,4.36,4.30,4.40,4.32],
    ]

    // Live-dashboard palette (mock-ui `D`). Darker surfaces than the easy view.
    enum D {
        static let bg       = Color(hex: "#0B0712")
        static let panel    = Color(hex: "#0E0A18")
        static let surface  = Color.white.opacity(0.045)
        static let border   = Color.white.opacity(0.09)
        static let text     = Color(hex: "#F4F1FA")
        static let muted    = Color(hex: "#F4F1FA", alpha: 0.54)
        static let faint    = Color(hex: "#F4F1FA", alpha: 0.32)
        static let violet   = Color(hex: "#9B6BFF")
        static let violetSoft = Color(hex: "#C9B4FF")
        static let buy      = Color(hex: "#2FD08A")
        static let sell     = Color(hex: "#FF5C6C")
    }

    enum Side: String { case buy, sell, dca }

    @State private var tab = "trade"
    @State private var side: Side = .buy
    @State private var preset: Int? = 50
    @State private var orderType = "market"
    @State private var range = "1D"

    /// Pure trade math (testable). Single source for amount / total / CTA label.
    private var quote: LiveTradeQuote { LiveTradeQuote(side: side, preset: preset) }
    private var data: [Double] { Self.series[range] ?? [] }
    private var amount: Double { quote.amount }
    private var total: Double { quote.total }
    private var up: Bool { (data.last ?? 0) >= (data.first ?? 0) }
    private var chgPct: Double {
        guard let f = data.first, let l = data.last, f != 0 else { return 0 }
        return (l - f) / f * 100
    }
    private var trendC: Color { up ? D.buy : D.sell }
    private var ctaColor: Color { side == .buy ? D.buy : side == .sell ? D.sell : D.violet }
    private var ctaLabel: String { quote.ctaLabel }

    var body: some View {
        ZStack(alignment: .bottom) {
            D.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                tabBar
                ScrollView {
                    Group {
                        if tab == "trade" { tradeTab } else { marketTab }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, tab == "trade" ? 116 : 48)
                }
            }

            if tab == "trade" { stickyCTA }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { side = initialSide }
        // No back chrome in the header — a left-edge swipe pops back instead.
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

    // MARK: - Header ticker + chart

    private var header: some View {
        VStack(spacing: 0) {
            HStack(spacing: 11) {
                logoTile

                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 7) {
                        Text("GRX/THB").font(.system(size: 17, weight: .bold)).tracking(-0.3)
                        Text("PERP")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(D.violetSoft)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(D.violet.opacity(0.16), in: RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(D.violet.opacity(0.3), lineWidth: 1))
                    }
                    Text("P2P energy · oracle price")
                        .font(.system(size: 11.5)).foregroundStyle(D.faint)
                }
                Spacer(minLength: 4)
                VStack(alignment: .trailing, spacing: 1) {
                    Text("฿\(String(format: "%.2f", LiveTradeQuote.price))")
                        .font(.system(size: 20, weight: .heavy, design: .monospaced))
                    Text("\(up ? "↑" : "↓") \(String(format: "%.2f", abs(chgPct)))%")
                        .font(.system(size: 12.5, weight: .bold)).foregroundStyle(trendC)
                }
                Button(action: onNotifications) {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(D.muted)
                        .frame(width: 30, height: 38)
                }
                .accessibilityLabel("Notifications")
            }
            .foregroundStyle(D.text)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)

            PriceChart(data: data, color: trendC)
                .frame(height: 132)
                .padding(.horizontal, 8)

            rangeRow
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 4)
        }
    }

    private var logoTile: some View {
        let grad = LinearGradient(colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        return RoundedRectangle(cornerRadius: 11, style: .continuous)
            .fill(grad)
            .frame(width: 38, height: 38)
            .overlay {
                LazyVGrid(columns: [GridItem(.fixed(5), spacing: 4), GridItem(.fixed(5))], spacing: 4) {
                    ForEach(0..<4, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(i == 0 ? Color.white : Color.white.opacity(0.6))
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(width: 14)
            }
            .shadow(color: Color(hex: "#7C3AED").opacity(0.5), radius: 7, y: 4)
    }

    private var rangeRow: some View {
        HStack {
            HStack(spacing: 16) {
                ForEach(["1H","1D","1W","1M"], id: \.self) { r in
                    Button { range = r } label: {
                        Text(r)
                            .font(.system(size: 12.5, weight: range == r ? .bold : .regular))
                            .foregroundStyle(range == r ? D.text : D.faint)
                    }
                }
            }
            Spacer()
            HStack(spacing: 12) {
                hlv("H", String(format: "%.2f", data.max() ?? 0))
                hlv("L", String(format: "%.2f", data.min() ?? 0))
                hlv("Vol", "218")
            }
        }
    }

    private func hlv(_ k: String, _ v: String) -> some View {
        (Text("\(k) ").font(.system(size: 11)).foregroundColor(D.faint)
            + Text(v).font(.system(size: 11, weight: .semibold, design: .monospaced)).foregroundColor(D.muted))
    }

    // MARK: - Tabs

    private var tabBar: some View {
        HStack(spacing: 24) {
            ForEach([("trade","Trade"),("market","Market")], id: \.0) { k, l in
                Button { tab = k } label: {
                    Text(l)
                        .font(.system(size: 15, weight: tab == k ? .bold : .regular))
                        .foregroundStyle(tab == k ? D.text : D.muted)
                        .padding(.bottom, 11)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(tab == k ? D.violet : .clear)
                                .frame(height: 2)
                        }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .overlay(alignment: .bottom) { Rectangle().fill(D.border).frame(height: 1) }
    }

    // MARK: - Trade tab

    private var tradeTab: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                sideButton(.buy, "Buy", D.buy)
                sideButton(.sell, "Sell", D.sell)
                sideButton(.dca, "DCA", D.violet)
            }

            VStack(spacing: 0) {
                Text("Amount").font(.system(size: 12.5)).foregroundStyle(D.muted)
                    .padding(.bottom, 8)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(String(format: "%.2f", amount))
                        .font(.system(size: 46, weight: .bold, design: .monospaced))
                        .tracking(-1)
                        .foregroundStyle(amount > 0 ? D.text : D.faint)
                    Text("kWh").font(.system(size: 16, weight: .semibold)).foregroundStyle(D.muted)
                }
                Text("≈ ฿\(String(format: "%.2f", total)) · avail \(String(format: "%.1f", LiveTradeQuote.maxKwh)) kWh")
                    .font(.system(size: 12)).foregroundStyle(D.faint)
                    .padding(.top, 6)
            }
            .padding(.top, 30).padding(.bottom, 16)

            HStack(spacing: 8) {
                ForEach([("25%",25),("50%",50),("75%",75),("Max",100)], id: \.1) { l, p in
                    Button { preset = (preset == p) ? nil : p } label: {
                        Text(l)
                            .font(.system(size: 13.5, weight: .semibold))
                            .foregroundStyle(preset == p ? D.violetSoft : D.muted)
                            .frame(maxWidth: .infinity, minHeight: 38)
                            .background(preset == p ? D.violet.opacity(0.16) : D.surface,
                                        in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(.bottom, 4)

            VStack(spacing: 0) {
                detailRow("Order type") {
                    HStack(spacing: 16) {
                        ForEach(["market","limit"], id: \.self) { t in
                            Button { orderType = t } label: {
                                Text(t.capitalized)
                                    .font(.system(size: 14.5, weight: orderType == t ? .bold : .regular))
                                    .foregroundStyle(orderType == t ? D.text : D.faint)
                            }
                        }
                    }
                }
                detailRow("Price") {
                    (Text("฿\(String(format: "%.2f", LiveTradeQuote.price))").font(.system(size: 14.5, weight: .bold, design: .monospaced))
                        + Text(" /kWh").font(.system(size: 12)).foregroundColor(D.faint))
                        .foregroundStyle(D.text)
                }
                detailRow("Route") {
                    (Text("Zone 2 ").font(.system(size: 14.5, weight: .semibold))
                        + Text("→ ").foregroundColor(D.faint)
                        + Text("Auto").foregroundColor(D.violetSoft))
                        .font(.system(size: 14.5, weight: .semibold))
                        .foregroundStyle(D.text)
                }
                HStack {
                    Text("Total").font(.system(size: 15, weight: .semibold)).foregroundStyle(D.text)
                    Spacer()
                    Text("฿\(String(format: "%.2f", total))")
                        .font(.system(size: 22, weight: .heavy, design: .monospaced))
                        .foregroundStyle(D.violetSoft)
                }
                .padding(.top, 16)
                .overlay(alignment: .top) { Rectangle().fill(D.border).frame(height: 1) }
            }
            .padding(.top, 14)
        }
    }

    private func sideButton(_ s: Side, _ label: String, _ c: Color) -> some View {
        let on = side == s
        return Button { side = s } label: {
            Text(label)
                .font(.system(size: 15, weight: on ? .bold : .semibold))
                .foregroundStyle(on ? c : D.faint)
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(on ? c.opacity(0.13) : .clear, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(on ? c : D.border, lineWidth: on ? 1.5 : 1))
        }
    }

    private func detailRow<C: View>(_ label: String, @ViewBuilder _ trailing: () -> C) -> some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundStyle(D.muted)
            Spacer()
            trailing()
        }
        .padding(.vertical, 15)
        .overlay(alignment: .top) { Rectangle().fill(D.border).frame(height: 1) }
    }

    // MARK: - Market tab

    private var marketTab: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Stat(k: "VWAP (24h)", v: "฿4.36", sub: "+2.45%", accent: D.buy)
                Stat(k: "Volume", v: "218 kWh", sub: "142 trades", accent: nil)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("P2P trade feed")
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(D.muted)
                    .padding(.horizontal, 2)
                VStack(spacing: 0) {
                    ForEach(Array(Self.feed.enumerated()), id: \.offset) { i, tr in
                        let c = tr.side == "buy" ? D.buy : D.sell
                        HStack(spacing: 12) {
                            Circle().fill(c).frame(width: 7, height: 7)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tr.route).font(.system(size: 14, weight: .semibold)).foregroundStyle(D.text)
                                Text("\(String(format: "%.2f", tr.kwh)) kWh · \(tr.t) ago")
                                    .font(.system(size: 12)).foregroundStyle(D.faint)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("฿\(String(format: "%.2f", tr.price))")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundStyle(c)
                                Text(tr.side.capitalized).font(.system(size: 11)).foregroundStyle(D.faint)
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 13)
                        .overlay(alignment: .top) { if i > 0 { Rectangle().fill(D.border).frame(height: 1) } }
                    }
                }
                .background(D.surface, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(D.border, lineWidth: 1))
            }
        }
    }

    private struct Trade { let route: String; let kwh: Double; let price: Double; let t: String; let side: String }
    private static let feed: [Trade] = [
        .init(route: "Zone 2 → Zone 4", kwh: 3.20, price: 4.28, t: "12s", side: "buy"),
        .init(route: "Zone 1 → Zone 0", kwh: 1.05, price: 4.55, t: "48s", side: "sell"),
        .init(route: "Zone 3 → Zone 2", kwh: 5.40, price: 4.31, t: "2m", side: "buy"),
        .init(route: "Zone 4 → Zone 1", kwh: 0.80, price: 4.62, t: "4m", side: "sell"),
        .init(route: "Zone 0 → Zone 3", kwh: 2.15, price: 4.40, t: "6m", side: "buy"),
        .init(route: "Zone 2 → Zone 4", kwh: 4.00, price: 4.25, t: "9m", side: "buy"),
    ]

    private struct Stat: View {
        let k: String; let v: String; let sub: String?; let accent: Color?
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(k.uppercased())
                    .font(.system(size: 10.5)).tracking(0.3).foregroundStyle(D.muted)
                Text(v)
                    .font(.system(size: 19, weight: .bold, design: .monospaced))
                    .foregroundStyle(accent ?? D.text)
                    .padding(.top, 4)
                if let sub {
                    Text(sub).font(.system(size: 11)).foregroundStyle(D.faint).padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 13).padding(.vertical, 12)
            .background(D.surface, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(D.border, lineWidth: 1))
        }
    }

    // MARK: - Sticky CTA

    private var stickyCTA: some View {
        Button {
            guard side != .dca else { onSetupDCA(); return }
            onTrade(EnergyTrade(
                side: side == .buy ? .buy : .sell,
                ratePerKwh: LiveTradeQuote.price,
                kwh: amount,
                progress: Double(preset ?? 0) / 100))
        } label: {
            Text(ctaLabel)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(side == .dca ? .white : Color(hex: "#08110C"))
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(
                    side == .dca
                        ? AnyShapeStyle(LinearGradient.gtxBrand)
                        : AnyShapeStyle(ctaColor),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: ctaColor.opacity(0.33), radius: 14, y: 10)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .background(
            LinearGradient(colors: [.clear, D.bg.opacity(0.92)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(edges: .bottom))
    }
}

// MARK: - Trade math (pure, testable)

/// Order pricing for the live dashboard: `preset` (% of available kWh) and
/// `side` derive the amount, fiat total, and sticky-CTA label. Kept free of
/// SwiftUI so it can be unit-tested directly.
struct LiveTradeQuote {
    static let maxKwh = 12.4
    static let price = 4.32

    var side: DashboardLiveView.Side
    var preset: Int?

    var amount: Double { preset.map { Self.maxKwh * Double($0) / 100 } ?? 0 }
    var total: Double { amount * Self.price }
    var ctaLabel: String {
        side == .dca
            ? "Set up DCA"
            : "\(side == .buy ? "Buy" : "Sell") \(String(format: "%.2f", amount)) kWh · ฿\(String(format: "%.2f", total))"
    }
}

// MARK: - Price sparkline (area + line + end dot)

private struct PriceChart: View {
    let data: [Double]
    let color: Color

    /// Mirror the jsx 0–100 viewBox mapping: top pad 6, usable height 88.
    private func points(in size: CGSize) -> [CGPoint] {
        let mn = data.min() ?? 0, mx = data.max() ?? 1
        let span = (mx - mn) == 0 ? 1 : (mx - mn)
        let n = max(data.count - 1, 1)
        return data.indices.map { i in
            let x = CGFloat(i) / CGFloat(n) * size.width
            let yPct = 100 - ((data[i] - mn) / span) * 88 - 6
            return CGPoint(x: x, y: CGFloat(yPct) / 100 * size.height)
        }
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let pts = points(in: geo.size)

            ZStack {
                // area fill
                Path { p in
                    guard let first = pts.first else { return }
                    p.move(to: CGPoint(x: 0, y: h))
                    p.addLine(to: first)
                    pts.dropFirst().forEach { p.addLine(to: $0) }
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [color.opacity(0.3), color.opacity(0)],
                                     startPoint: .top, endPoint: .bottom))
                // line
                Path { p in
                    guard let first = pts.first else { return }
                    p.move(to: first)
                    pts.dropFirst().forEach { p.addLine(to: $0) }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                // end dot
                if let last = pts.last {
                    Circle().fill(color).frame(width: 3.4, height: 3.4).position(last)
                }
            }
        }
    }
}

#Preview {
    DashboardLiveView()
}
