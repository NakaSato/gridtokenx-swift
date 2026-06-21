//
//  EnergyTradeViews.swift
//  gridtokexios
//
//  Energy-trade notification components — animated FlowBars plus the compact,
//  split, and expanded island presentations. Ported from
//  mock-ui/energy-island.jsx. Reused by the widget's ActivityConfiguration +
//  DynamicIsland { } regions. Pure black = island chrome.
//

import SwiftUI

private let monoNum = Font.system(.body, design: .monospaced)

// MARK: - Flow bars (animated equalizer — energy flowing)

struct FlowBars: View {
    var color: Color
    var count: Int = 4
    /// When set, bar heights step through `steps` keyed on this value. The host
    /// (Live Activity) bumps it each ContentState update, so the island animates
    /// between snapshots. When nil (in-app), a free-running pulse is used instead.
    var phase: Int? = nil
    @State private var animating = false

    private let heights: [CGFloat] = [6, 12, 8, 14]
    // Per-step y-scale per bar — cycled by `phase` to read as flowing energy.
    private let steps: [[CGFloat]] = [
        [1.0, 0.45, 0.80, 0.55],
        [0.55, 1.0, 0.45, 0.85],
        [0.80, 0.60, 1.0, 0.50],
        [0.45, 0.85, 0.60, 1.0],
    ]

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(color)
                    .frame(width: 2.5, height: heights[i % 4])
                    .scaleEffect(y: scaleY(i), anchor: .bottom)
                    .opacity(phase == nil ? (animating ? 0.6 : 1) : 0.92)
                    .animation(barAnimation(i), value: animationKey)
            }
        }
        .frame(height: 14, alignment: .bottom)
        .onAppear { animating = true }
    }

    private var animationKey: Int { phase ?? (animating ? 1 : 0) }

    private func scaleY(_ i: Int) -> CGFloat {
        if let phase { return steps[((phase % steps.count) + steps.count) % steps.count][i % 4] }
        return animating ? 0.45 : 1   // in-app resting pulse
    }

    private func barAnimation(_ i: Int) -> Animation {
        if phase != nil {
            // Smooth interpolation between live updates.
            return .easeInOut(duration: 0.5).delay(Double(i) * 0.04)
        }
        return .easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(Double(i) * 0.12)
    }
}

// MARK: - Compact (leading + trailing of the pill)

struct EnergyIslandCompactLeading: View {
    var trade = EnergyTrade()
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(trade.accent)
            Text(trade.rateText)
                .font(.system(size: 13.5, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
    }
}

struct EnergyIslandCompactTrailing: View {
    var trade = EnergyTrade()
    var body: some View {
        FlowBars(color: trade.accent, count: 4, phase: trade.phase)
    }
}

/// Standalone compact pill (the widget uses the leading/trailing pair).
struct EnergyIslandCompact: View {
    var trade = EnergyTrade()
    var body: some View {
        HStack {
            EnergyIslandCompactLeading(trade: trade)
            Spacer()
            EnergyIslandCompactTrailing(trade: trade)
        }
        .padding(.horizontal, 13)
        .frame(width: 126, height: 37)
        .background(.black, in: Capsule())
    }
}

// MARK: - Split (minimal+ : main pill + detached blob)

struct EnergyIslandSplit: View {
    var trade = EnergyTrade()
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(trade.accent)
                Text(trade.rateText)
                    .font(monoNum.weight(.bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .frame(height: 37)
            .background(.black, in: Capsule())

            FlowBars(color: trade.accent, count: 3, phase: trade.phase)
                .frame(width: 37, height: 37)
                .background(.black, in: Circle())
        }
    }
}

// MARK: - Expanded (full live activity)

struct EnergyIslandExpanded: View {
    var trade = EnergyTrade()
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 14) {
            header
            progressRow
            footer
        }
        .padding(EdgeInsets(top: 14, leading: 18, bottom: 16, trailing: 18))
        .frame(width: 360)
        .background(.black, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
        .shadow(color: .black.opacity(0.6), radius: 25, y: 18)
        .onAppear { pulse = true }
    }

    private var header: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(trade.accent.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(trade.accent.opacity(0.33), lineWidth: 1))
                .overlay(Image(systemName: "bolt.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(trade.accent))
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Text(trade.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    Circle()
                        .fill(trade.accent)
                        .frame(width: 6, height: 6)
                        .opacity(pulse ? 1 : 0.4)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
                }
                Text("\(trade.zone) · GridTokenX")
                    .font(.system(size: 12.5))
                    .foregroundStyle(Color.islandMuted)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 1) {
                Text(trade.rateText)
                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                    .foregroundStyle(trade.accent)
                Text("per kWh")
                    .font(.system(size: 11.5))
                    .foregroundStyle(Color.islandFaint)
            }
        }
    }

    private var progressRow: some View {
        HStack(spacing: 10) {
            FlowBars(color: trade.accent, count: 5, phase: trade.phase)
            GeometryReader { geo in
                Capsule().fill(.white.opacity(0.12))
                    .overlay(alignment: .leading) {
                        Capsule().fill(trade.accent)
                            .frame(width: geo.size.width * trade.progress)
                    }
            }
            .frame(height: 6)
            Text("\(trade.kwh, specifier: "%.1f") kWh")
                .font(.system(size: 12.5, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
    }

    private var footer: some View {
        HStack(spacing: 18) {
            stat(trade.earnedLabel, trade.earnedText)
            stat("Live for", trade.liveFor)
            stat("Counterparty", trade.counterparty)
            Spacer(minLength: 0)
        }
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 11))
                .tracking(0.4)
                .foregroundStyle(Color.islandFaint)
            Text(value)
                .font(.system(size: 13.5, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
    }
}

#Preview("Compact") {
    ZStack { Color.gray.opacity(0.3); EnergyIslandCompact() }
}
