//
//  NotificationsView.swift
//  gridtokexios
//
//  16 · Notifications — in-app activity inbox (trade fills, price alerts, grid
//  events, DCA). Filter chips, New / Earlier groups, swipe-free dismiss, and
//  light-style action pills. Native port of mock-ui/extra-screens.jsx
//  (NotificationsPage). Distinct from Core/Notifications (the UN/ActivityKit
//  delivery infra) — this is the UI list.
//

import SwiftUI

// MARK: - Model

struct GTXNotification: Identifiable {
    let id: Int
    let icon: String        // SF Symbol
    let color: Color
    let cat: String         // trades | alerts | grid
    let title: String
    let body: String
    let time: String
    var read: Bool
    var action: String?     // optional CTA, e.g. "Sell now" / "Sell"
}

extension GTXNotification {
    /// Seed feed mirroring the mock-ui NOTIFS array.
    static let sample: [GTXNotification] = [
        .init(id: 1, icon: "checkmark", color: N.up, cat: "trades",
              title: "Buy filled", body: "3.2 kWh bought at ฿4.28 · Zone 1→2", time: "2m ago", read: false),
        .init(id: 2, icon: "exclamationmark.triangle.fill", color: N.warning, cat: "alerts",
              title: "Price alert triggered", body: "GRX/THB crossed ฿4.50 upward", time: "18m ago", read: false, action: "Sell now"),
        .init(id: 3, icon: "bolt.fill", color: N.violet, cat: "grid",
              title: "Surplus in Zone 2", body: "3.4 kW excess — good time to sell", time: "1h ago", read: false, action: "Sell"),
        .init(id: 4, icon: "checkmark", color: N.down, cat: "trades",
              title: "Sell filled", body: "5.4 kWh sold at ฿4.31 · Zone 2→4", time: "2h ago", read: true),
        .init(id: 5, icon: "arrow.triangle.2.circlepath", color: N.violet, cat: "trades",
              title: "DCA executed", body: "Bought 3.0 kWh as scheduled (daily)", time: "6h ago", read: true),
        .init(id: 6, icon: "info.circle.fill", color: N.blue, cat: "grid",
              title: "Meter online", body: "GTX-5821-4490-1123 reconnected", time: "Yesterday", read: true),
        .init(id: 7, icon: "exclamationmark.triangle.fill", color: N.warning, cat: "alerts",
              title: "Grid event", body: "High demand detected in your zone", time: "2d ago", read: true),
    ]
}

// Palette (mock-ui `EX`).
private enum N {
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
    static let blue       = Color(hex: "#7CA8FF")
    static let warning    = Color(hex: "#FFD166")
}

// MARK: - View

struct NotificationsView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    @State private var items: [GTXNotification] = GTXNotification.sample
    @State private var filter = "all"

    private let filters = [("all", "All"), ("trades", "Trades"), ("alerts", "Alerts"), ("grid", "Grid")]

    private var unread: Int { items.filter { !$0.read }.count }
    private var shown: [GTXNotification] { filter == "all" ? items : items.filter { $0.cat == filter } }
    private var newItems: [GTXNotification] { shown.filter { !$0.read } }
    private var earlier: [GTXNotification] { shown.filter { $0.read } }

    var body: some View {
        ZStack {
            N.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                filterBar
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        if !newItems.isEmpty {
                            sectionLabel("New")
                            ForEach(newItems) { card($0) }
                        }
                        if !earlier.isEmpty {
                            sectionLabel("Earlier")
                            ForEach(earlier) { card($0) }
                        }
                        if shown.isEmpty { emptyState }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .enableInjection()
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold)).foregroundStyle(N.muted)
            }
            .accessibilityLabel("Back")

            HStack(spacing: 9) {
                Text("Notifications").font(.system(size: 22, weight: .bold)).tracking(-0.4)
                if unread > 0 {
                    Text("\(unread)")
                        .font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(N.violet, in: Capsule())
                }
            }
            Spacer()
            if unread > 0 {
                Button("Mark all read") { markAll() }
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(N.violetSoft)
            }
        }
        .foregroundStyle(N.text)
        .padding(.horizontal, 16)
        .padding(.top, 6).padding(.bottom, 6)
    }

    // MARK: Filter chips

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(filters, id: \.0) { key, label in
                let on = filter == key
                let cnt = key == "all" ? unread : items.filter { $0.cat == key && !$0.read }.count
                Button { filter = key } label: {
                    HStack(spacing: 6) {
                        Text(label).font(.system(size: 13, weight: .semibold)).fixedSize()
                        if cnt > 0 {
                            Text("\(cnt)")
                                .font(.system(size: 10.5, weight: .heavy))
                                .foregroundStyle(on ? .white : N.violetSoft)
                                .frame(minWidth: 16, minHeight: 16)
                                .padding(.horizontal, 4)
                                .background(on ? Color.white.opacity(0.28) : N.violet.opacity(0.22), in: Capsule())
                        }
                    }
                    .foregroundStyle(on ? .white : N.muted)
                    .frame(height: 32)
                    .padding(.horizontal, 13)
                    .background {
                        if on { LinearGradient.gtxBrand.clipShape(Capsule()) }
                        else { N.surface.clipShape(Capsule()) }
                    }
                    .overlay(Capsule().stroke(on ? .clear : N.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8).padding(.bottom, 4)
    }

    // MARK: Card

    private func card(_ n: GTXNotification) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: n.icon)
                .font(.system(size: 18, weight: .semibold)).foregroundStyle(n.color)
                .frame(width: 40, height: 40)
                .background(n.color.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(n.color.opacity(0.27), lineWidth: 1))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    if !n.read { Circle().fill(N.violet).frame(width: 7, height: 7) }
                    Text(n.title).font(.system(size: 14.5, weight: n.read ? .medium : .bold))
                }
                Text(n.body).font(.system(size: 13)).foregroundStyle(N.muted)
                    .lineSpacing(1.5).fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 12) {
                    Text(n.time).font(.system(size: 11.5)).foregroundStyle(N.faint)
                    if let action = n.action { actionPill(action, id: n.id) }
                }
                .padding(.top, 5)
            }
            .foregroundStyle(N.text)

            Spacer(minLength: 0)

            Button { dismiss(n.id) } label: {
                Image(systemName: "xmark").font(.system(size: 12, weight: .bold))
                    .foregroundStyle(N.muted).opacity(0.4).padding(4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background((n.read ? N.surface : N.violet.opacity(0.09)),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(n.read ? N.border : N.violet.opacity(0.26), lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture { markRead(n.id) }
    }

    /// Light-style CTA pill — soft violet tint, violet outline, violet text
    /// (quieter than the solid gradient against the flat feed).
    private func actionPill(_ label: String, id: Int) -> some View {
        Button { markRead(id) } label: {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(N.violet)
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(N.violet.opacity(0.14), in: Capsule())
                .overlay(Capsule().stroke(N.violet.opacity(0.55), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func sectionLabel(_ t: String) -> some View {
        Text(t.uppercased())
            .font(.system(size: 12, weight: .bold)).tracking(0.5)
            .foregroundStyle(N.faint)
            .padding(.leading, 2).padding(.top, 6).padding(.bottom, 2)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell").font(.system(size: 40, weight: .light)).foregroundStyle(N.faint)
            Text("All caught up").font(.system(size: 15)).foregroundStyle(N.faint)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: Mutations

    private func markAll() {
        withAnimation(.smooth(duration: 0.25)) {
            for i in items.indices { items[i].read = true }
        }
    }
    private func markRead(_ id: Int) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        withAnimation(.smooth(duration: 0.25)) { items[i].read = true }
    }
    private func dismiss(_ id: Int) {
        withAnimation(.smooth(duration: 0.25)) { items.removeAll { $0.id == id } }
    }
}

#Preview {
    NotificationsView()
}
