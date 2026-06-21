//
//  EnergyFlowView.swift
//  gridtokexios
//
//  10 · Energy flow — a Sankey diagram routing sources (Solar/Wind/Grid) through
//  your hub to sinks (Home/EV/Battery/Sold); ribbon thickness ∝ power. Native
//  port of mock-ui/energy-flow.jsx (EnergyFlowPage). The SVG ribbons are redrawn
//  with SwiftUI `Canvas` + cubic-bezier `Path`s. Now/Today toggle swaps datasets.
//

import SwiftUI

// MARK: - Model

struct FlowNode: Identifiable {
    let name: String
    let v: Double
    let color: Color
    var id: String { name }
}

struct FlowDataset {
    let sources: [FlowNode]
    let sinks: [FlowNode]

    static let now = FlowDataset(
        sources: [
            FlowNode(name: "Solar", v: 6.2, color: Color(hex: "#FFD166")),
            FlowNode(name: "Wind", v: 2.8, color: Color(hex: "#2FD08A")),
            FlowNode(name: "Grid buy", v: 1.5, color: Color(hex: "#7CA8FF")),
        ],
        sinks: [
            FlowNode(name: "Home", v: 4.5, color: Color(hex: "#C9B4FF")),
            FlowNode(name: "EV", v: 2.0, color: Color(hex: "#E0A23C")),
            FlowNode(name: "Battery", v: 2.4, color: Color(hex: "#7CA8FF")),
            FlowNode(name: "Sold", v: 1.6, color: Color(hex: "#9B6BFF")),
        ])

    static let today = FlowDataset(
        sources: [
            FlowNode(name: "Solar", v: 48, color: Color(hex: "#FFD166")),
            FlowNode(name: "Wind", v: 19, color: Color(hex: "#2FD08A")),
            FlowNode(name: "Grid buy", v: 9, color: Color(hex: "#7CA8FF")),
        ],
        sinks: [
            FlowNode(name: "Home", v: 34, color: Color(hex: "#C9B4FF")),
            FlowNode(name: "EV", v: 14, color: Color(hex: "#E0A23C")),
            FlowNode(name: "Battery", v: 12, color: Color(hex: "#7CA8FF")),
            FlowNode(name: "Sold", v: 16, color: Color(hex: "#9B6BFF")),
        ])

    // My-home breakdown (per-appliance sinks).
    static let home = FlowDataset(
        sources: [
            FlowNode(name: "Solar", v: 6.2, color: Color(hex: "#FFD166")),
            FlowNode(name: "Battery", v: 1.8, color: Color(hex: "#7CA8FF")),
            FlowNode(name: "Grid buy", v: 0.9, color: Color(hex: "#FF9A5C")),
        ],
        sinks: [
            FlowNode(name: "Air-con", v: 2.6, color: Color(hex: "#7CA8FF")),
            FlowNode(name: "EV charger", v: 2.0, color: Color(hex: "#E0A23C")),
            FlowNode(name: "Kitchen", v: 1.0, color: Color(hex: "#C9B4FF")),
            FlowNode(name: "Water heat", v: 0.8, color: Color(hex: "#FF6B9D")),
            FlowNode(name: "Lights+plug", v: 0.9, color: Color(hex: "#9B6BFF")),
            FlowNode(name: "Sold", v: 1.6, color: Color(hex: "#2FD08A")),
        ])
}

/// Derived flow figures (pure, testable).
struct FlowSummary {
    let dataset: FlowDataset

    var produced: Double { dataset.sources.reduce(0) { $0 + $1.v } }
    var sold: Double { dataset.sinks.first { $0.name == "Sold" }?.v ?? 0 }
    var used: Double { dataset.sinks.filter { $0.name != "Sold" }.reduce(0) { $0 + $1.v } }
    var gridBuy: Double { dataset.sources.first { $0.name == "Grid buy" }?.v ?? 0 }
    var selfSufficient: Int { produced == 0 ? 0 : Int((((produced - gridBuy) / produced) * 100).rounded()) }
}

// MARK: - Palette

private enum EF {
    static let bg         = Color(hex: "#0B0712")
    static let surface    = Color.white.opacity(0.05)
    static let border     = Color.white.opacity(0.09)
    static let text       = Color(hex: "#F4F1FA")
    static let muted      = Color(hex: "#F4F1FA", alpha: 0.54)
    static let faint      = Color(hex: "#F4F1FA", alpha: 0.32)
    static let violet     = Color(hex: "#9B6BFF")
    static let violetSoft = Color(hex: "#C9B4FF")
    static let up         = Color(hex: "#2FD08A")
    static let grad       = LinearGradient(
        colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
        startPoint: .topLeading, endPoint: .bottomTrailing)
}

// MARK: - Page

struct EnergyFlowView: View {
    var onBack: () -> Void = {}
    var onHome: () -> Void = {}

    @ObserveInjection var inject
    @State private var period = "now"

    private var dataset: FlowDataset { period == "now" ? .now : .today }
    private var unit: String { period == "now" ? "kW" : "kWh" }
    private var summary: FlowSummary { FlowSummary(dataset: dataset) }

    var body: some View {
        ZStack {
            EF.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        periodToggle
                        headline
                        sankeyCard
                        summaryStats
                        note
                    }
                    .padding(.horizontal, 16).padding(.top, 6).padding(.bottom, 32)
                }
            }
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

    private var topBar: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold)).foregroundStyle(EF.muted)
            }
            .accessibilityLabel("Back")
            Text("Energy flow").font(.system(size: 22, weight: .bold)).tracking(-0.4).foregroundStyle(EF.text)
            Spacer()
            Button(action: onHome) {
                Image(systemName: "house").font(.system(size: 19, weight: .medium)).foregroundStyle(EF.violetSoft)
            }
            .accessibilityLabel("My home flow")
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)
    }

    private var periodToggle: some View {
        HStack(spacing: 6) {
            ForEach([("now", "Now"), ("today", "Today")], id: \.0) { key, label in
                let on = period == key
                Button { withAnimation(.easeInOut(duration: 0.18)) { period = key } } label: {
                    Text(label)
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundStyle(on ? .white : EF.muted)
                        .frame(height: 32).padding(.horizontal, 18)
                        .background { if on { EF.grad.clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous)) } }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(EF.border, lineWidth: 1))
    }

    private var headline: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            (Text(fmt(summary.produced)).font(.system(size: 38, weight: .heavy, design: .monospaced))
                + Text(" \(unit)").font(.system(size: 18, weight: .semibold)).foregroundColor(EF.muted))
                .foregroundStyle(EF.text).tracking(-1)
            Text(period == "now" ? "flowing now" : "today")
                .font(.system(size: 13.5)).foregroundStyle(EF.muted)
        }
    }

    private var sankeyCard: some View {
        SankeyView(sources: dataset.sources, sinks: dataset.sinks)
            .padding(.horizontal, 10).padding(.top, 16).padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .background(EF.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(EF.border, lineWidth: 1))
    }

    private var summaryStats: some View {
        HStack(spacing: 10) {
            stat("Self-powered", "\(summary.selfSufficient)%", EF.up)
            stat("Using", "\(fmt(summary.used)) \(unit)", EF.violetSoft)
            stat("Exporting", "\(fmt(summary.sold)) \(unit)", EF.violet)
        }
    }

    private func stat(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(.system(size: 10.5)).tracking(0.3).foregroundStyle(EF.muted)
            Text(value).font(.system(size: 17, weight: .bold, design: .monospaced)).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12).padding(.vertical, 12)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(EF.border, lineWidth: 1))
    }

    private var note: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "info.circle").font(.system(size: 15)).foregroundStyle(EF.violetSoft)
                .padding(.top, 1)
            (Text("Ribbon thickness shows how much power flows along each path. You sold ")
                .foregroundStyle(EF.muted)
                + Text("\(fmt(summary.sold)) \(unit)").foregroundStyle(EF.text).bold()
                + Text(" of surplus \(period == "now" ? "right now" : "today").").foregroundStyle(EF.muted))
                .font(.system(size: 12.5)).lineSpacing(1.5)
        }
        .padding(.horizontal, 15).padding(.vertical, 13)
        .background(EF.violet.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(EF.violet.opacity(0.2), lineWidth: 1))
    }

    /// Trim trailing ".0" so 6.2 stays 6.2 but 48.0 shows 48.
    private func fmt(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v)
    }
}

// MARK: - Sankey (Canvas)

/// Sankey ribbon diagram. Layout uses the mock's 372-wide coordinate space and
/// scales uniformly to the available width.
struct SankeyView: View {
    let sources: [FlowNode]
    let sinks: [FlowNode]
    var hubLabel = "YOU"

    // Coordinate constants (mock-ui `Sankey`).
    private let W: CGFloat = 372, TOP: CGFloat = 16, H: CGFloat = 326, GAP: CGFloat = 6
    private let leftBarX: CGFloat = 92, barW: CGFloat = 11, hubX: CGFloat = 180, hubW: CGFloat = 13, rightBarX: CGFloat = 268

    private struct Placed { let node: FlowNode; let y: CGFloat; let h: CGFloat }

    private var total: Double { sources.reduce(0) { $0 + $1.v } }

    private func stack(_ nodes: [FlowNode], scale: CGFloat) -> [Placed] {
        var y = TOP
        return nodes.map { n in
            let h = CGFloat(n.v) * scale
            defer { y += h + GAP }
            return Placed(node: n, y: y, h: h)
        }
    }

    /// Hub-side start offsets (stacked with no gaps).
    private func hubOffsets(_ placed: [Placed]) -> [CGFloat] {
        var y = TOP
        return placed.map { p in defer { y += p.h }; return y }
    }

    private func ribbon(x0: CGFloat, y0: CGFloat, x1: CGFloat, y1: CGFloat, h: CGFloat) -> Path {
        let mx = (x0 + x1) / 2
        var p = Path()
        p.move(to: CGPoint(x: x0, y: y0))
        p.addCurve(to: CGPoint(x: x1, y: y1), control1: CGPoint(x: mx, y: y0), control2: CGPoint(x: mx, y: y1))
        p.addLine(to: CGPoint(x: x1, y: y1 + h))
        p.addCurve(to: CGPoint(x: x0, y: y0 + h), control1: CGPoint(x: mx, y: y1 + h), control2: CGPoint(x: mx, y: y0 + h))
        p.closeSubpath()
        return p
    }

    var body: some View {
        let total = max(self.total, 0.0001)
        let sScale = (H - CGFloat(sources.count - 1) * GAP) / CGFloat(total)
        let kScale = (H - CGFloat(sinks.count - 1) * GAP) / CGFloat(total)
        let sNodes = stack(sources, scale: sScale)
        let kNodes = stack(sinks, scale: kScale)
        let sHub = hubOffsets(sNodes)
        let kHub = hubOffsets(kNodes)
        let hubBot = max(sHub.last.map { $0 + sNodes.last!.h } ?? TOP,
                         kHub.last.map { $0 + kNodes.last!.h } ?? TOP)
        let canvasH = hubBot + 16

        let leftRibX0 = leftBarX + barW
        let hubLeft = hubX, hubRight = hubX + hubW

        return Canvas { ctx, size in
            let s = size.width / W
            ctx.scaleBy(x: s, y: s)

            // left ribbons
            for (i, n) in sNodes.enumerated() {
                ctx.fill(ribbon(x0: leftRibX0, y0: n.y, x1: hubLeft, y1: sHub[i], h: n.h),
                         with: .color(n.node.color.opacity(0.4)))
            }
            // right ribbons
            for (i, n) in kNodes.enumerated() {
                ctx.fill(ribbon(x0: hubRight, y0: kHub[i], x1: rightBarX, y1: n.y, h: n.h),
                         with: .color(n.node.color.opacity(0.4)))
            }
            // hub bar
            let hubRect = CGRect(x: hubX, y: TOP, width: hubW, height: hubBot - TOP)
            ctx.fill(Path(roundedRect: hubRect, cornerRadius: 3),
                     with: .linearGradient(Gradient(colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")]),
                                           startPoint: CGPoint(x: hubRect.midX, y: hubRect.minY),
                                           endPoint: CGPoint(x: hubRect.midX, y: hubRect.maxY)))

            // left nodes + labels
            for n in sNodes {
                ctx.fill(Path(roundedRect: CGRect(x: leftBarX, y: n.y, width: barW, height: n.h), cornerRadius: 3),
                         with: .color(n.node.color))
                drawLabel(ctx, n, x: leftBarX - 8, trailing: true)
            }
            // right nodes + labels
            for n in kNodes {
                ctx.fill(Path(roundedRect: CGRect(x: rightBarX, y: n.y, width: barW, height: n.h), cornerRadius: 3),
                         with: .color(n.node.color))
                drawLabel(ctx, n, x: rightBarX + barW + 8, trailing: false)
            }

            // hub caption
            ctx.draw(Text(hubLabel).font(.system(size: 10.5, weight: .bold)).foregroundColor(EF.violetSoft),
                     at: CGPoint(x: hubX + hubW / 2, y: TOP - 9), anchor: .center)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(W / canvasH, contentMode: .fit)
    }

    private func drawLabel(_ ctx: GraphicsContext, _ p: Placed, x: CGFloat, trailing: Bool) {
        let anchor: UnitPoint = trailing ? .trailing : .leading
        ctx.draw(Text(p.node.name).font(.system(size: 12.5, weight: .semibold)).foregroundColor(EF.text),
                 at: CGPoint(x: x, y: p.y + p.h / 2 - 2), anchor: anchor)
        ctx.draw(Text(numText(p.node.v)).font(.system(size: 11, design: .monospaced)).foregroundColor(EF.muted),
                 at: CGPoint(x: x, y: p.y + p.h / 2 + 11), anchor: anchor)
    }

    private func numText(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v)
    }
}

// MARK: - My home flow

/// Per-appliance breakdown of the household's live power, with a self-sufficiency
/// hero card. Port of mock-ui/energy-flow.jsx `MyHomeFlow`; reuses `SankeyView`.
struct MyHomeFlowView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    private let dataset = FlowDataset.home
    private var summary: FlowSummary { FlowSummary(dataset: dataset) }
    private var homeUse: Double { summary.used }

    var body: some View {
        ZStack {
            EF.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 16) {
                        hero
                        sankeyCard
                        note
                    }
                    .padding(.horizontal, 16).padding(.top, 6).padding(.bottom, 32)
                }
            }
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

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left").font(.system(size: 22, weight: .semibold)).foregroundStyle(EF.muted)
            }
            .accessibilityLabel("Back")
            VStack(alignment: .leading, spacing: 1) {
                Text("My home").font(.system(size: 21, weight: .bold)).tracking(-0.4).foregroundStyle(EF.text)
                Text("Zone 2 · Bangkok · live").font(.system(size: 12)).foregroundStyle(EF.faint)
            }
            Spacer()
            HStack(spacing: 6) {
                Circle().fill(EF.up).frame(width: 6, height: 6)
                Text("LIVE").font(.system(size: 11.5, weight: .bold)).foregroundStyle(EF.up)
            }
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(EF.up.opacity(0.12), in: Capsule())
            .overlay(Capsule().stroke(EF.up.opacity(0.3), lineWidth: 1))
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)
    }

    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            Circle().fill(.white.opacity(0.1)).frame(width: 130, height: 130).offset(x: 20, y: -30)
            VStack(alignment: .leading, spacing: 2) {
                Text("Powered by your own clean energy")
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white.opacity(0.85))
                Text("\(summary.selfSufficient)%")
                    .font(.system(size: 40, weight: .black, design: .monospaced)).tracking(-1).foregroundStyle(.white)
                HStack(spacing: 18) {
                    heroStat("\(fmt(summary.produced)) kW", "supply")
                    heroStat("\(fmt(homeUse)) kW", "home use")
                    heroStat("\(fmt(summary.sold)) kW", "exported")
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .background(EF.grad)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: "#7C3AED", alpha: 0.4), radius: 20, y: 14)
    }

    private func heroStat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value).font(.system(size: 15, weight: .bold, design: .monospaced)).foregroundStyle(.white)
            Text(label).font(.system(size: 11)).foregroundStyle(.white.opacity(0.75))
        }
    }

    private var sankeyCard: some View {
        VStack(spacing: 4) {
            Text("Where your power comes from & goes")
                .font(.system(size: 12.5, weight: .semibold)).foregroundStyle(EF.muted)
            SankeyView(sources: dataset.sources, sinks: dataset.sinks, hubLabel: "HOME")
        }
        .padding(.horizontal, 10).padding(.top, 16).padding(.bottom, 12)
        .frame(maxWidth: .infinity)
        .background(EF.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(EF.border, lineWidth: 1))
    }

    private var note: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "info.circle").font(.system(size: 15)).foregroundStyle(EF.violetSoft).padding(.top, 1)
            (Text("Ribbon thickness = power along each path. Your ").foregroundStyle(EF.muted)
                + Text("Air-con").foregroundStyle(EF.text).bold()
                + Text(" is the biggest load right now; surplus ").foregroundStyle(EF.muted)
                + Text("\(fmt(summary.sold)) kW").foregroundStyle(EF.text).bold()
                + Text(" is being sold to neighbours.").foregroundStyle(EF.muted))
                .font(.system(size: 12.5)).lineSpacing(1.5)
        }
        .padding(.horizontal, 15).padding(.vertical, 13)
        .background(EF.violet.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(EF.violet.opacity(0.2), lineWidth: 1))
    }

    private func fmt(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v)
    }
}

#Preview {
    EnergyFlowView()
}

#Preview("My home") {
    MyHomeFlowView()
}
