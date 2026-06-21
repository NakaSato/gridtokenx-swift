//
//  DCAView.swift
//  gridtokexios
//
//  09 · DCA strategy — set up a recurring (dollar-cost-average) buy/sell order:
//  amount, price cap, frequency, interval. Native port of mock-ui/dca.jsx
//  (DCAStrategy + DCAActive). Reached from the live dashboard "Set up DCA" CTA.
//  Form drives local @State; "Start DCA" swaps to the active confirmation.
//  The mock's "Suggest with AI" (window.claude.complete) maps to a local
//  canned preset — no networking in the native port.
//

import SwiftUI

struct DCAView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    enum Side: String { case buy, sell }

    @State private var started = false
    @State private var side: Side = .buy
    @State private var freq = "daily"
    @State private var amount = "3.0"
    @State private var maxPrice = ""
    @State private var everyN = "1"
    @State private var maxRuns = ""
    @State private var aiNote = ""

    // Palette (mock-ui `DC`).
    private enum D {
        static let bg         = Color(hex: "#0B0712")
        static let surface    = Color.white.opacity(0.05)
        static let field      = Color.white.opacity(0.04)
        static let border     = Color.white.opacity(0.09)
        static let text       = Color(hex: "#F4F1FA")
        static let muted      = Color(hex: "#F4F1FA", alpha: 0.54)
        static let faint      = Color(hex: "#F4F1FA", alpha: 0.34)
        static let violet     = Color(hex: "#9B6BFF")
        static let violetSoft = Color(hex: "#C9B4FF")
        static let buy        = Color(hex: "#2FD08A")
        static let sell       = Color(hex: "#FF5C6C")
        static let grad       = LinearGradient(
            colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
            startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private let freqs: [(String, String, String)] = [
        ("hourly", "Hourly", "clock"),
        ("daily", "Daily", "sun.max"),
        ("weekly", "Weekly", "calendar"),
        ("monthly", "Monthly", "calendar"),
    ]
    private var plan: DCAPlan {
        DCAPlan(side: side, amount: amount, freq: freq, everyN: everyN, maxPrice: maxPrice)
    }
    private var unit: String { plan.unit }
    private var unitSingular: String { plan.unitSingular }
    private var sideColor: Color { side == .buy ? D.buy : D.sell }

    var body: some View {
        ZStack {
            if started {
                DCAActiveView(side: side, amount: amount, freq: freq, unit: unit,
                              everyN: everyN, maxPrice: maxPrice,
                              onEdit: { withAnimation(.smooth(duration: 0.3)) { started = false } })
                    .transition(.opacity)
            } else {
                setup.transition(.opacity)
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
        #if DEBUG
        .onAppear { if ProcessInfo.processInfo.arguments.contains("DCA_ACTIVE") { started = true } }
        #endif
    }

    // MARK: - Setup

    private var setup: some View {
        ZStack {
            D.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        intro
                        labeledField("Amount per execution", hint: "Min: 0.1 kWh") {
                            fieldBox($amount, unit: "kWh", focus: true)
                        }
                        labeledField("Max price (optional)", hint: "Skip if price exceeds") {
                            fieldBox($maxPrice, placeholder: "No limit", unit: "฿/kWh")
                        }
                        labeledField("Frequency", hint: nil) { freqGrid }
                        HStack(spacing: 12) {
                            labeledField("Every N \(unit)", hint: nil) { fieldBox($everyN) }
                            labeledField("Max runs", hint: "∞ if empty") { fieldBox($maxRuns, placeholder: "∞") }
                        }
                        previewCard
                    }
                    .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 12)
                }
                ctaBar
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold)).foregroundStyle(D.violetSoft)
                    .frame(width: 38, height: 38)
                    .background(D.surface, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(D.border, lineWidth: 1))
            }
            .accessibilityLabel("Back")
            HStack(spacing: 8) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 18, weight: .semibold)).foregroundStyle(D.violetSoft)
                Text("DCA strategy").font(.system(size: 22, weight: .bold)).tracking(-0.4).foregroundStyle(D.text)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)
    }

    private var intro: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("Automatically \(side.rawValue) energy on a schedule to average out price swings.")
                .font(.system(size: 14)).foregroundStyle(D.muted).lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button { suggestWithAI() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles").font(.system(size: 13, weight: .semibold))
                    Text("Suggest with AI").font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(D.violetSoft)
                .frame(height: 34).padding(.horizontal, 13)
                .background(D.violet.opacity(0.14), in: Capsule())
                .overlay(Capsule().stroke(D.violet.opacity(0.4), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .fixedSize()
        }
    }

    // MARK: - Fields

    private func labeledField<Content: View>(_ label: String, hint: String?,
                                             @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(label).font(.system(size: 14, weight: .semibold)).foregroundStyle(D.text)
                Spacer()
                if let hint { Text(hint).font(.system(size: 12.5)).foregroundStyle(D.faint) }
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fieldBox(_ text: Binding<String>, placeholder: String = "",
                          unit: String? = nil, focus: Bool = false) -> some View {
        HStack(spacing: 10) {
            TextField(placeholder, text: text)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(D.text)
                .keyboardType(.decimalPad)
            if let unit { Text(unit).font(.system(size: 13.5, weight: .semibold)).foregroundStyle(D.muted) }
        }
        .padding(.horizontal, 15).frame(height: 54)
        .background(D.field, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous)
            .stroke(focus ? D.violet : D.border, lineWidth: 1))
        .shadow(color: focus ? D.violet.opacity(0.14) : .clear, radius: 0)
    }

    private var freqGrid: some View {
        HStack(spacing: 8) {
            ForEach(freqs, id: \.0) { key, label, icon in
                let on = freq == key
                Button { withAnimation(.easeInOut(duration: 0.15)) { freq = key } } label: {
                    VStack(spacing: 7) {
                        Image(systemName: icon).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(on ? AnyShapeStyle(D.grad) : AnyShapeStyle(Color.white.opacity(0.06)),
                                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        Text(label).font(.system(size: 12, weight: .semibold)).foregroundStyle(on ? D.text : D.muted)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background(on ? AnyShapeStyle(D.violet.opacity(0.14)) : AnyShapeStyle(D.surface),
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(on ? D.violet : D.border, lineWidth: 1.5))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var previewCard: some View {
        HStack(spacing: 11) {
            Circle().fill(sideColor).frame(width: 8, height: 8)
            (Text(side == .buy ? "Buys " : "Sells ").foregroundStyle(D.muted)
                + Text("\(amount) kWh").foregroundStyle(D.text).bold()
                + Text(" every ").foregroundStyle(D.muted)
                + Text(unitSingular).foregroundStyle(D.text).bold()
                + Text(" · runs until cancelled").foregroundStyle(D.muted))
                .font(.system(size: 13.5)).lineSpacing(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(D.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(D.border, lineWidth: 1))
    }

    // MARK: - CTA

    private var ctaBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                sideSeg(.buy, "Buy", D.buy)
                sideSeg(.sell, "Sell", D.sell)
            }
            .padding(5)
            .background(D.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(D.border, lineWidth: 1))

            Button { withAnimation(.smooth(duration: 0.3)) { started = true } } label: {
                Text(plan.startLabel)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(side == .buy ? Color(hex: "#08110C") : .white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(sideColor, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: sideColor.opacity(0.33), radius: 14, y: 10)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 8)
        .background(D.bg)
        .overlay(Rectangle().fill(D.border).frame(height: 1), alignment: .top)
    }

    private func sideSeg(_ s: Side, _ label: String, _ color: Color) -> some View {
        let on = side == s
        return Button { withAnimation(.easeInOut(duration: 0.15)) { side = s } } label: {
            Text(label)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(on ? Color(hex: "#08110C") : D.muted)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(on ? AnyShapeStyle(color) : AnyShapeStyle(Color.clear),
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: on ? color.opacity(0.33) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - AI suggest (local canned preset)

    private func suggestWithAI() {
        withAnimation(.smooth(duration: 0.25)) {
            side = .buy
            amount = "2.5"
            freq = "daily"
            everyN = "1"
            maxPrice = "4.50"
            aiNote = "Buy 2.5 kWh daily under ฿4.50 to smooth out price swings."
        }
    }
}

// MARK: - Active confirmation

private struct DCAActiveView: View {
    let side: DCAView.Side
    let amount: String
    let freq: String
    let unit: String
    let everyN: String
    let maxPrice: String
    var onEdit: () -> Void = {}

    private enum D {
        static let bg         = Color(hex: "#0B0712")
        static let surface    = Color.white.opacity(0.05)
        static let border     = Color.white.opacity(0.09)
        static let text       = Color(hex: "#F4F1FA")
        static let muted      = Color(hex: "#F4F1FA", alpha: 0.54)
        static let faint      = Color(hex: "#F4F1FA", alpha: 0.34)
        static let violetSoft = Color(hex: "#C9B4FF")
        static let buy        = Color(hex: "#2FD08A")
        static let sell       = Color(hex: "#FF5C6C")
        static let grad       = LinearGradient(
            colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
            startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var sideColor: Color { side == .buy ? D.buy : D.sell }
    private var plan: DCAPlan {
        DCAPlan(side: side, amount: amount, freq: freq, everyN: everyN, maxPrice: maxPrice)
    }
    /// Summary rows with display colors (text comes from the pure plan).
    private var rows: [(String, String, Color)] {
        plan.summaryRows.enumerated().map { i, r in
            let color: Color = i == 0 ? sideColor : (i == 4 ? D.violetSoft : D.text)
            return (r.0, r.1, color)
        }
    }

    var body: some View {
        ZStack {
            D.bg.ignoresSafeArea()
            // top glow
            Circle().fill(RadialGradient(colors: [Color(hex: "#7C3AED", alpha: 0.34), .clear],
                                         center: .center, startRadius: 0, endRadius: 180))
                .frame(width: 420, height: 360).offset(y: -260)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                RoundedRectangle(cornerRadius: 28, style: .continuous).fill(D.grad)
                    .frame(width: 92, height: 92)
                    .overlay(Image(systemName: "checkmark").font(.system(size: 42, weight: .bold)).foregroundStyle(.white))
                    .shadow(color: Color(hex: "#7C3AED", alpha: 0.5), radius: 24, y: 16)

                Text("DCA strategy active")
                    .font(.system(size: 27, weight: .heavy)).tracking(-0.6).foregroundStyle(D.text)
                    .padding(.top, 28)
                (Text("Your recurring order is live. We'll \(side.rawValue) ")
                    + Text("\(amount) kWh").foregroundStyle(D.text).bold()
                    + Text(" automatically and notify you on every fill."))
                    .font(.system(size: 15)).foregroundStyle(D.muted).lineSpacing(3)
                    .multilineTextAlignment(.center).frame(maxWidth: 290)
                    .padding(.top, 12)

                summaryCard.padding(.top, 26)

                HStack(spacing: 7) {
                    Circle().fill(sideColor).frame(width: 7, height: 7)
                    Text("Running until cancelled").font(.system(size: 12.5)).foregroundStyle(D.faint)
                }
                .padding(.top, 16)

                Spacer()

                VStack(spacing: 10) {
                    Button {} label: {
                        Text("View in orders")
                            .font(.system(size: 16.5, weight: .bold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(D.grad, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color(hex: "#7C3AED", alpha: 0.42), radius: 13, y: 10)
                    }
                    .buttonStyle(.plain)
                    Button(action: onEdit) {
                        Text("Edit strategy")
                            .font(.system(size: 15.5, weight: .semibold)).foregroundStyle(D.muted)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(D.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24).padding(.bottom, 30)
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { i, r in
                if i > 0 { Rectangle().fill(D.border).frame(height: 1) }
                HStack {
                    Text(r.0).font(.system(size: 14)).foregroundStyle(D.muted)
                    Spacer()
                    Text(r.1)
                        .font(.system(size: 14.5, weight: .bold,
                                      design: r.1.contains(where: { $0.isNumber || $0 == "฿" }) ? .monospaced : .default))
                        .foregroundStyle(r.2)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
            }
        }
        .background(D.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(D.border, lineWidth: 1))
    }
}

// MARK: - DCA plan (pure, testable)

/// Recurring-order configuration text: `freq` maps to unit/cadence/next-run
/// labels, and the setup/active screens render the same derived strings. Kept
/// free of SwiftUI so it can be unit-tested directly.
struct DCAPlan {
    var side: DCAView.Side
    var amount: String
    var freq: String
    var everyN: String
    var maxPrice: String

    private static let units = ["hourly": "hours", "daily": "days", "weekly": "weeks", "monthly": "months"]
    private static let cadences = ["hourly": "Hourly", "daily": "Daily", "weekly": "Weekly", "monthly": "Monthly"]
    private static let nextRuns = ["hourly": "In 1 hour", "daily": "Tomorrow, 06:00", "weekly": "Mon, 06:00", "monthly": "1st of month"]

    var unit: String { Self.units[freq] ?? "days" }
    var unitSingular: String { String(unit.dropLast()) }
    var cadence: String { Self.cadences[freq] ?? "Daily" }
    var nextRun: String { Self.nextRuns[freq] ?? "Tomorrow" }
    var startLabel: String { "Start DCA · \(amount) kWh / \(unitSingular)" }
    var frequencyDetail: String {
        cadence + ((Int(everyN) ?? 1) > 1 ? " · every \(everyN) \(unit)" : "")
    }
    var priceCap: String { maxPrice.isEmpty ? "No limit" : "฿\(maxPrice)/kWh" }

    /// Confirmation summary rows (label, value); colors applied by the view.
    var summaryRows: [(String, String)] {
        [
            ("Action", "\(side == .buy ? "Buy" : "Sell") energy"),
            ("Amount", "\(amount) kWh"),
            ("Frequency", frequencyDetail),
            ("Price cap", priceCap),
            ("Next run", nextRun),
        ]
    }
}

#Preview {
    DCAView()
}
