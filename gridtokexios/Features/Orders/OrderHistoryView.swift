//
//  OrderHistoryView.swift
//  gridtokexios
//
//  17 · Order history — a net-this-week summary card over an underline tab bar
//  (All / Buy / Sell / DCA) that filters a list of orders, grouped by day with a
//  per-day net. Filled / cancelled / partial statuses; DCA badge. Native port of
//  mock-ui/extra-screens.jsx (OrderHistory / screen 17). The order model and the
//  filter / summary / grouping logic are kept SwiftUI-free so they're testable.
//

import SwiftUI

// MARK: - Model (pure, testable)

struct Order: Identifiable {
    let id = UUID()
    let side: Side          // buy | sell
    let kwh: Double
    let price: Double
    let total: Double
    let status: Status      // filled | cancelled | partially
    let zone: String
    let date: String        // "Today, 14:22"
    let type: OrderType     // market | limit | dca

    enum Side: String { case buy, sell }
    enum Status: String { case filled, cancelled, partially }
    enum OrderType: String { case market, limit, dca }

    /// Day portion of the date string ("Today, 14:22" -> "Today").
    var day: String { date.split(separator: ",").first.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? date }
    /// Time portion ("Today, 14:22" -> "14:22"); empty when absent.
    var time: String {
        let parts = date.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
        return parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) : ""
    }
}

extension Order {
    /// Seed feed mirroring the mock-ui ORDERS array.
    static let sample: [Order] = [
        .init(side: .buy,  kwh: 3.20, price: 4.28, total: 13.70, status: .filled,    zone: "Zone 1→2", date: "Today, 14:22",     type: .market),
        .init(side: .sell, kwh: 5.40, price: 4.31, total: 23.27, status: .filled,    zone: "Zone 2→4", date: "Today, 12:05",     type: .limit),
        .init(side: .buy,  kwh: 3.00, price: 4.32, total: 12.96, status: .filled,    zone: "Zone 2",   date: "Today, 06:00",     type: .dca),
        .init(side: .buy,  kwh: 1.50, price: 4.50, total: 6.75,  status: .cancelled, zone: "Zone 1→2", date: "Yesterday, 18:11", type: .limit),
        .init(side: .sell, kwh: 4.00, price: 4.25, total: 17.00, status: .filled,    zone: "Zone 4→1", date: "Yesterday, 09:30", type: .market),
        .init(side: .buy,  kwh: 3.00, price: 4.40, total: 13.20, status: .filled,    zone: "Zone 2",   date: "Jun 17, 06:00",    type: .dca),
        .init(side: .sell, kwh: 2.10, price: 4.18, total: 8.78,  status: .filled,    zone: "Zone 2→3", date: "Jun 16, 11:45",    type: .limit),
        .init(side: .buy,  kwh: 5.00, price: 4.60, total: 23.00, status: .partially, zone: "Zone 1→2", date: "Jun 15, 16:20",    type: .limit),
    ]
}

/// Filter/summary/grouping over an order list — no SwiftUI, so it can be
/// unit-tested directly.
enum OrderFilter {
    /// "all" passes everything; "dca" filters by type; otherwise by side.
    static func shown(_ orders: [Order], tab: String) -> [Order] {
        switch tab {
        case "dca": return orders.filter { $0.type == .dca }
        case "buy", "sell": return orders.filter { $0.side.rawValue == tab }
        default: return orders
        }
    }

    /// Settled (non-cancelled) orders feed the week summary.
    static func settled(_ orders: [Order]) -> [Order] { orders.filter { $0.status != .cancelled } }

    static func soldValue(_ orders: [Order]) -> Double { settled(orders).filter { $0.side == .sell }.reduce(0) { $0 + $1.total } }
    static func boughtValue(_ orders: [Order]) -> Double { settled(orders).filter { $0.side == .buy }.reduce(0) { $0 + $1.total } }
    static func net(_ orders: [Order]) -> Double { soldValue(orders) - boughtValue(orders) }
    static func volumeKwh(_ orders: [Order]) -> Double { settled(orders).reduce(0) { $0 + $1.kwh } }

    /// Day-grouped, preserving first-seen day order. Returns [(day, [orders])].
    static func grouped(_ orders: [Order]) -> [(day: String, orders: [Order])] {
        var order: [String] = []
        var byDay: [String: [Order]] = [:]
        for o in orders {
            if byDay[o.day] == nil { order.append(o.day) }
            byDay[o.day, default: []].append(o)
        }
        return order.map { ($0, byDay[$0] ?? []) }
    }

    /// Net for a single day's settled orders (sell adds, buy subtracts).
    static func dayNet(_ orders: [Order]) -> Double {
        settled(orders).reduce(0) { $0 + ($1.side == .sell ? $1.total : -$1.total) }
    }
}

// Palette (mock-ui `EX`).
private enum O {
    static let bg         = Color(hex: "#0B0712")
    static let surface    = Color.white.opacity(0.05)
    static let border     = Color.white.opacity(0.09)
    static let text       = Color(hex: "#F4F1FA")
    static let muted      = Color(hex: "#F4F1FA", alpha: 0.54)
    static let faint      = Color(hex: "#F4F1FA", alpha: 0.32)
    static let violet     = Color(hex: "#9B6BFF")
    static let violetSoft = Color(hex: "#C9B4FF")
    static let up         = Color(hex: "#2FD08A")
    static let down       = Color(hex: "#FF5C6C")
    static let gold       = Color(hex: "#FFD166")

    static func statusColor(_ s: Order.Status) -> Color {
        switch s { case .filled: return up; case .cancelled: return faint; case .partially: return gold }
    }
    static func statusLabel(_ s: Order.Status) -> String {
        switch s { case .filled: return "Filled"; case .cancelled: return "Cancelled"; case .partially: return "Partial" }
    }
}

// MARK: - View

struct OrderHistoryView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    @State private var tab = "all"

    private let orders = Order.sample
    private let tabs = [("all", "All"), ("buy", "Buy"), ("sell", "Sell"), ("dca", "DCA")]

    private var shown: [Order] { OrderFilter.shown(orders, tab: tab) }

    var body: some View {
        ZStack {
            O.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                summaryCard
                tabBar
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        let groups = OrderFilter.grouped(shown)
                        if groups.isEmpty {
                            emptyState
                        } else {
                            ForEach(Array(groups.enumerated()), id: \.offset) { _, g in
                                dayGroup(day: g.day, items: g.orders)
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.top, 4).padding(.bottom, 32)
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

    // MARK: Header

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold)).foregroundStyle(O.muted)
            }
            .accessibilityLabel("Back")

            Text("Order history").font(.system(size: 22, weight: .bold)).tracking(-0.4)
            Spacer()
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 19, weight: .semibold)).foregroundStyle(O.muted)
        }
        .foregroundStyle(O.text)
        .padding(.horizontal, 16).padding(.top, 6).padding(.bottom, 4)
    }

    // MARK: Net summary

    private var summaryCard: some View {
        let net = OrderFilter.net(orders)
        let sold = OrderFilter.soldValue(orders)
        let bought = OrderFilter.boughtValue(orders)
        let vol = OrderFilter.volumeKwh(orders)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Net this week").font(.system(size: 12.5)).foregroundStyle(O.muted)
                Spacer()
                Text(String(format: "%.1f kWh traded", vol)).font(.system(size: 11.5)).foregroundStyle(O.faint)
            }
            Text(signed(net))
                .font(.system(size: 26, weight: .heavy, design: .monospaced))
                .foregroundStyle(net >= 0 ? O.up : O.down)
                .padding(.top, 3)
            HStack(spacing: 18) {
                summaryStat("Sold", String(format: "฿%.0f", sold), O.up)
                summaryStat("Bought", String(format: "฿%.0f", bought), O.text)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(O.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(O.border, lineWidth: 1))
        .padding(.horizontal, 16).padding(.top, 8)
    }

    private func summaryStat(_ label: String, _ value: String, _ valueColor: Color) -> some View {
        (Text(label + " ").foregroundStyle(O.muted)
            + Text(value).foregroundStyle(valueColor).font(.system(size: 12.5, weight: .bold, design: .monospaced)))
            .font(.system(size: 12.5))
    }

    // MARK: Underline tabs

    private var tabBar: some View {
        HStack(spacing: 24) {
            ForEach(tabs, id: \.0) { key, label in
                let on = tab == key
                Button { withAnimation(.easeInOut(duration: 0.15)) { tab = key } } label: {
                    Text(label)
                        .font(.system(size: 14.5, weight: on ? .bold : .regular))
                        .foregroundStyle(on ? O.text : O.muted)
                        .padding(.bottom, 11)
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(on ? O.violet : .clear).frame(height: 2)
                        }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 14)
        .overlay(Rectangle().fill(O.border).frame(height: 1), alignment: .bottom)
    }

    // MARK: Day group

    private func dayGroup(day: String, items: [Order]) -> some View {
        let net = OrderFilter.dayNet(items)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(day.uppercased())
                    .font(.system(size: 12, weight: .bold)).tracking(0.5).foregroundStyle(O.faint)
                Spacer()
                Text(signed(net))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(net >= 0 ? O.up : O.down)
            }
            .padding(.top, 14).padding(.bottom, 8).padding(.horizontal, 2)

            ForEach(items) { orderRow($0) }
        }
    }

    private func orderRow(_ o: Order) -> some View {
        let sideColor = o.side == .buy ? O.up : O.down
        let cancelled = o.status == .cancelled
        return HStack(spacing: 13) {
            Image(systemName: o.side == .sell ? "arrow.up" : "arrow.down")
                .font(.system(size: 16, weight: .bold)).foregroundStyle(sideColor)
                .frame(width: 38, height: 38)
                .background(sideColor.opacity(0.09), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(sideColor.opacity(0.27), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Text("\(o.side.rawValue.capitalized) \(String(format: "%.2f", o.kwh)) kWh")
                        .font(.system(size: 14.5, weight: .semibold))
                    if o.type == .dca {
                        Text("DCA")
                            .font(.system(size: 10, weight: .heavy)).foregroundStyle(O.violetSoft)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(O.violet.opacity(0.2), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                    }
                }
                Text(detailLine(o)).font(.system(size: 12)).foregroundStyle(O.faint)
            }
            .foregroundStyle(O.text)

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                Text(totalLine(o))
                    .font(.system(size: 14.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(cancelled ? O.faint : (o.side == .sell ? O.up : O.text))
                Text(O.statusLabel(o.status))
                    .font(.system(size: 11, weight: .bold)).foregroundStyle(O.statusColor(o.status))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(O.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(O.border, lineWidth: 1))
        .opacity(cancelled ? 0.6 : 1)
        .padding(.bottom, 8)
    }

    private func detailLine(_ o: Order) -> String {
        var s = "\(o.zone) · ฿\(String(format: "%.2f", o.price))/kWh"
        if !o.time.isEmpty { s += " · \(o.time)" }
        return s
    }

    private func totalLine(_ o: Order) -> String {
        if o.status == .cancelled { return "฿\(String(format: "%.2f", o.total))" }
        let sign = o.side == .sell ? "+" : "−"
        return "\(sign)฿\(String(format: "%.2f", o.total))"
    }

    private func signed(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : "−"
        return "\(sign)฿\(String(format: "%.2f", abs(value)))"
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40, weight: .light)).foregroundStyle(O.faint)
            Text("No orders here yet").font(.system(size: 15)).foregroundStyle(O.faint)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

#Preview {
    OrderHistoryView()
}
