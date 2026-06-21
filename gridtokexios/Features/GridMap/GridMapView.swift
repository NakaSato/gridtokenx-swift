//
//  GridMapView.swift
//  gridtokexios
//
//  15 · Live grid map — a tappable energy network. Generation / storage / hub /
//  consumer nodes positioned on a 100×100 canvas, linked by dashed edges. Tap a
//  node to select it (dim the rest, draw a detail panel); tap again to deselect.
//  LIVE pill + gen/load/surplus stat chips + a colour legend. Native port of
//  mock-ui/extra-screens.jsx (GridMapMobile / screen 15). Self-driven @State.
//

import SwiftUI

// MARK: - Model

/// A node on the energy network. `x`/`y` are percentages on a 0…100 canvas
/// (matching the JSX SVG coords); `kind` drives the shape (hub = rounded square).
struct GridNode: Identifiable {
    let id: String
    let label: String
    let kind: Kind
    let x: CGFloat        // 0…100
    let y: CGFloat        // 0…100
    let color: Color
    let value: String     // current reading, e.g. "4.2 kW"
    let icon: String      // SF Symbol

    enum Kind: String {
        case solar, wind, storage, hub, consumer, ev
        var title: String { rawValue.capitalized }
    }
}

/// An edge between two nodes (index into the node array) with its flow colour.
struct GridEdge {
    let a: Int
    let b: Int
    let color: Color
}

enum GridMapData {
    static let nodes: [GridNode] = [
        .init(id: "solar", label: "Solar A", kind: .solar,    x: 22, y: 22, color: GM.gold,   value: "4.2 kW",  icon: "sun.max.fill"),
        .init(id: "wind",  label: "Wind",    kind: .wind,     x: 72, y: 16, color: GM.teal,   value: "6.1 kW",  icon: "wind"),
        .init(id: "bat",   label: "Battery", kind: .storage,  x: 28, y: 55, color: GM.blue,   value: "78%",     icon: "minus.plus.batteryblock.fill"),
        .init(id: "hub",   label: "Hub",     kind: .hub,      x: 56, y: 52, color: GM.violet, value: "14.1 kW", icon: "bolt.fill"),
        .init(id: "res",   label: "Home",    kind: .consumer, x: 16, y: 80, color: GM.violetSoft, value: "2.1 kW", icon: "house.fill"),
        .init(id: "com",   label: "Office",  kind: .consumer, x: 54, y: 82, color: GM.violetSoft, value: "3.4 kW", icon: "house.fill"),
        .init(id: "ind",   label: "Factory", kind: .consumer, x: 82, y: 74, color: GM.orange, value: "4.7 kW",  icon: "building.2.fill"),
        .init(id: "ev",    label: "EV",      kind: .ev,       x: 88, y: 45, color: GM.ev,     value: "0.9 kW",  icon: "bolt.car.fill"),
    ]

    static let edges: [GridEdge] = [
        .init(a: 0, b: 3, color: GM.gold),
        .init(a: 1, b: 3, color: GM.teal),
        .init(a: 3, b: 2, color: GM.blue),
        .init(a: 3, b: 4, color: GM.violet),
        .init(a: 3, b: 5, color: GM.violet),
        .init(a: 3, b: 6, color: GM.gradTop),
        .init(a: 2, b: 4, color: GM.ev),
        .init(a: 7, b: 6, color: GM.ev),
    ]
}

// Palette (mock-ui `EX`).
private enum GM {
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
    static let teal       = Color(hex: "#2FD08A")
    static let blue       = Color(hex: "#7CA8FF")
    static let orange     = Color(hex: "#FF9A5C")
    static let ev         = Color(hex: "#E0A23C")
    static let gradTop    = Color(hex: "#A974FF")
}

// MARK: - View

struct GridMapView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    @State private var selected: Int? = nil

    private let nodes = GridMapData.nodes
    private let edges = GridMapData.edges

    private var selectedNode: GridNode? {
        guard let i = selected, nodes.indices.contains(i) else { return nil }
        return nodes[i]
    }

    private let legend: [(Color, String)] = [
        (GM.gold, "Solar"), (GM.teal, "Wind"), (GM.blue, "Storage"),
        (GM.violet, "Hub"), (GM.violetSoft, "Consumer"), (GM.ev, "EV"),
    ]

    var body: some View {
        ZStack {
            GM.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                statChips
                map
                legendBar
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
                    .font(.system(size: 20, weight: .semibold)).foregroundStyle(GM.muted)
            }
            .accessibilityLabel("Back")

            Text("Live grid map").font(.system(size: 18, weight: .bold)).tracking(-0.3)
            Spacer()
            livePill
        }
        .foregroundStyle(GM.text)
        .padding(.horizontal, 16).padding(.top, 6).padding(.bottom, 4)
    }

    private var livePill: some View {
        HStack(spacing: 6) {
            Circle().fill(GM.up).frame(width: 6, height: 6)
            Text("LIVE").font(.system(size: 11.5, weight: .bold))
        }
        .foregroundStyle(GM.up)
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(GM.up.opacity(0.12), in: Capsule())
        .overlay(Capsule().stroke(GM.up.opacity(0.3), lineWidth: 1))
    }

    // MARK: Stat chips

    private var statChips: some View {
        HStack(spacing: 8) {
            statChip(GM.gold, "14.1 kW", "gen")
            statChip(GM.down, "11.1 kW", "load")
            statChip(GM.violet, "+3.0 kW", "surplus")
        }
        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 4)
    }

    private func statChip(_ color: Color, _ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 5) {
                Circle().fill(color).frame(width: 6, height: 6)
                Text(label.uppercased())
                    .font(.system(size: 9.5, weight: .semibold)).tracking(0.4)
                    .foregroundStyle(GM.faint)
            }
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10).padding(.vertical, 9)
        .background(GM.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(GM.border, lineWidth: 1))
    }

    // MARK: Network map

    private var map: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // Closure (not a `func`): ViewBuilder closures forbid local function declarations.
            let pt = { (n: GridNode) in CGPoint(x: n.x / 100 * w, y: n.y / 100 * h) }

            ZStack {
                gridTexture

                // edges
                Canvas { ctx, _ in
                    for e in edges {
                        let dim = selected != nil && selected != e.a && selected != e.b
                        var path = Path()
                        path.move(to: pt(nodes[e.a]))
                        path.addLine(to: pt(nodes[e.b]))
                        ctx.stroke(
                            path,
                            with: .color(e.color.opacity(dim ? 0.12 : 0.65)),
                            style: StrokeStyle(lineWidth: 1.4, lineCap: .round, dash: [3, 4]))
                    }
                }

                // nodes
                ForEach(Array(nodes.enumerated()), id: \.element.id) { i, n in
                    nodeButton(i, n).position(pt(n))
                }

                // detail panel
                if let node = selectedNode {
                    VStack {
                        Spacer()
                        detailPanel(node).padding(14)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(
            RadialGradient(colors: [Color(hex: "#1A1330"), GM.bg],
                           center: UnitPoint(x: 0.48, y: 0.38), startRadius: 0, endRadius: 360),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(GM.border, lineWidth: 1))
        .padding(.horizontal, 16).padding(.vertical, 6)
    }

    private var gridTexture: some View {
        Canvas { ctx, size in
            let step: CGFloat = 36
            let line = GraphicsContext.Shading.color(Color.white.opacity(0.03))
            var x: CGFloat = 0
            while x <= size.width {
                var p = Path(); p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height))
                ctx.stroke(p, with: line, lineWidth: 1); x += step
            }
            var y: CGFloat = 0
            while y <= size.height {
                var p = Path(); p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y))
                ctx.stroke(p, with: line, lineWidth: 1); y += step
            }
        }
    }

    private func nodeButton(_ i: Int, _ n: GridNode) -> some View {
        let on = selected == i
        let dim = selected != nil && !on
        let isHub = n.kind == .hub
        let size: CGFloat = isHub ? 52 : 40
        let radius: CGFloat = isHub ? 18 : size / 2
        return Button {
            withAnimation(.easeInOut(duration: 0.18)) { selected = on ? nil : i }
        } label: {
            Image(systemName: n.icon)
                .font(.system(size: isHub ? 20 : 17, weight: .semibold))
                .foregroundStyle(n.color)
                .frame(width: size, height: size)
                .background(
                    (on ? n.color.opacity(0.16) : Color(hex: "#0E0A18", alpha: 0.9)),
                    in: RoundedRectangle(cornerRadius: radius, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(on ? n.color : n.color.opacity(0.38), lineWidth: on ? 2 : 1.5))
                .shadow(color: n.color.opacity(on ? 0.27 : 0.2), radius: on ? 14 : 8, y: on ? 8 : 4)
        }
        .buttonStyle(.plain)
        .opacity(dim ? 0.3 : 1)
        .accessibilityLabel("\(n.label), \(n.value)")
    }

    private func detailPanel(_ node: GridNode) -> some View {
        HStack(spacing: 12) {
            Image(systemName: node.icon)
                .font(.system(size: 18, weight: .semibold)).foregroundStyle(node.color)
                .frame(width: 36, height: 36)
                .background(node.color.opacity(0.13), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(node.color.opacity(0.33), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(node.label).font(.system(size: 15, weight: .bold)).foregroundStyle(GM.text)
                Text(node.kind.title).font(.system(size: 12.5)).foregroundStyle(GM.muted)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 2) {
                Text(node.value)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(node.color)
                Text("current").font(.system(size: 11)).foregroundStyle(GM.faint)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(GM.bg.opacity(0.92), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(node.color.opacity(0.27), lineWidth: 1))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: Legend

    private var legendBar: some View {
        FlowLayout(spacing: 10, rowSpacing: 6) {
            ForEach(Array(legend.enumerated()), id: \.offset) { _, item in
                HStack(spacing: 5) {
                    Circle().fill(item.0).frame(width: 7, height: 7)
                    Text(item.1).font(.system(size: 11.5)).foregroundStyle(GM.muted)
                }
            }
        }
        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 28)
    }
}

// MARK: - FlowLayout (wrapping legend chips)

/// Minimal wrapping layout — lays children left-to-right, wrapping to a new row
/// when the line is full (mirrors the JSX `flexWrap: 'wrap'` legend).
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var rowSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > maxWidth, x > 0 {
                x = 0; y += rowHeight + rowSpacing; rowHeight = 0
            }
            x += s.width + spacing
            rowHeight = max(rowHeight, s.height)
        }
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += rowHeight + rowSpacing; rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            rowHeight = max(rowHeight, s.height)
        }
    }
}

#Preview {
    GridMapView()
}
