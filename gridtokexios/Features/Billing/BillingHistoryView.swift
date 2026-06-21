//
//  BillingHistoryView.swift
//  gridtokexios
//
//  Historical billing — list of monthly statements with a deep per-statement
//  detail. Internal router: list view → tap a statement → full statement
//  detail (hero net total, breakdown, meter & payment, download CTA). Native
//  port of mock-ui/billing-history.jsx (HistoricalBilling + StatementDetail).
//  Statement dataset is modeled as a pure `Statement` struct with derived
//  totals; the screen drives list/detail with local @State.
//

import SwiftUI

struct BillingHistoryView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    @State private var selected: Statement?
    @State private var year = 2026

    // Palette (mock-ui `HB`).
    private enum H {
        static let bg         = Color(hex: "#0B0712")
        static let surface    = Color.white.opacity(0.05)
        static let surface2   = Color.white.opacity(0.03)
        static let border     = Color.white.opacity(0.09)
        static let hair       = Color.white.opacity(0.07)
        static let text       = Color(hex: "#F4F1FA")
        static let muted      = Color(hex: "#F4F1FA", alpha: 0.54)
        static let faint      = Color(hex: "#F4F1FA", alpha: 0.34)
        static let violet     = Color(hex: "#9B6BFF")
        static let violetSoft = Color(hex: "#C9B4FF")
        static let up         = Color(hex: "#2FD08A")
        static let down       = Color(hex: "#FF5C6C")
        static let gold       = Color(hex: "#FFD166")
        static let blue       = Color(hex: "#7CA8FF")
        static let grad       = LinearGradient(
            colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
            startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ZStack {
            if let selected {
                detail(selected)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                list
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .simultaneousGesture(
            DragGesture(minimumDistance: 18).onEnded { v in
                if v.startLocation.x < 24, v.translation.width > 70, abs(v.translation.height) < 60 {
                    if selected != nil {
                        withAnimation(.smooth(duration: 0.3)) { selected = nil }
                    } else {
                        onBack()
                    }
                }
            })
        .enableInjection()
    }

    // MARK: - List

    private var rows: [Statement] { Statement.all.filter { $0.year == year } }
    private var yearTotal: Double { rows.reduce(0) { $0 + $1.amount } }
    private var yearKwh: Double { rows.reduce(0) { $0 + $1.importKwh } }
    private var avg: Double { rows.isEmpty ? 0 : yearTotal / Double(rows.count) }
    private var maxAmt: Double { Statement.all.map(\.amount).max() ?? 1 }

    private var list: some View {
        ZStack {
            H.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                listTopBar
                yearSegmented
                ScrollView {
                    VStack(spacing: 16) {
                        yearSummary
                        statementList
                    }
                    .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 20)
                    .gtxUniversalWidth()
                }
            }
        }
    }

    private var listTopBar: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold)).foregroundStyle(H.muted)
            }
            .accessibilityLabel("Back")
            Text("Billing history")
                .font(.system(size: 20, weight: .bold)).tracking(-0.3).foregroundStyle(H.text)
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .regular)).foregroundStyle(H.muted)
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)
        .gtxUniversalWidth()
    }

    private var yearSegmented: some View {
        HStack(spacing: 6) {
            ForEach([2026, 2025], id: \.self) { y in
                let on = year == y
                Button { withAnimation(.easeInOut(duration: 0.15)) { year = y } } label: {
                    Text(String(y))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(on ? .white : H.muted)
                        .frame(maxWidth: .infinity, minHeight: 34)
                        .background(on ? AnyShapeStyle(H.grad) : AnyShapeStyle(Color.clear),
                                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .shadow(color: on ? Color(hex: "#7C3AED", alpha: 0.35) : .clear, radius: 6, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(H.surface, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(H.border, lineWidth: 1))
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 4)
        .gtxUniversalWidth()
    }

    private var yearSummary: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Total billed in \(String(year))")
                    .font(.system(size: 12.5)).foregroundStyle(H.muted)
                Spacer()
                Text("\(rows.count) statements")
                    .font(.system(size: 11.5)).foregroundStyle(H.faint)
            }
            Text("฿\(hbMoney(yearTotal))")
                .font(.system(size: 30, weight: .heavy, design: .monospaced)).tracking(-1)
                .foregroundStyle(H.text).padding(.top, 3)
            HStack(spacing: 22) {
                summaryStat("Avg / mo", "฿\(hbMoney(avg))")
                summaryStat("Imported", "\(Int(yearKwh)) kWh")
            }
            .padding(.top, 10)
            miniBarChart.padding(.top, 16)
        }
        .padding(.horizontal, 16).padding(.vertical, 15)
        .background(H.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(H.border, lineWidth: 1))
    }

    private func summaryStat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 11)).tracking(0.4).foregroundStyle(H.faint)
            Text(value)
                .font(.system(size: 14.5, weight: .bold, design: .monospaced)).foregroundStyle(H.text)
        }
    }

    private var miniBarChart: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(rows.reversed()) { d in
                Button { open(d) } label: {
                    VStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(H.grad).opacity(0.85)
                            .frame(maxWidth: 18, minHeight: 6)
                            .frame(height: d.amount / maxAmt * 42 + 6)
                            .frame(maxWidth: .infinity)
                        Text(String(d.monthAbbrev.prefix(1)))
                            .font(.system(size: 9.5)).foregroundStyle(H.faint)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 54)
    }

    private var statementList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Statements")
                .font(.system(size: 12, weight: .bold)).tracking(0.5).foregroundStyle(H.faint)
                .padding(.horizontal, 2).padding(.bottom, 8)
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.element.id) { i, d in
                    if i > 0 { Rectangle().fill(H.hair).frame(height: 1) }
                    statementRow(d)
                }
            }
            .background(H.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(H.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private func statementRow(_ d: Statement) -> some View {
        Button { open(d) } label: {
            HStack(spacing: 13) {
                VStack(spacing: 1) {
                    Text(d.monthAbbrev)
                        .font(.system(size: 11, weight: .heavy)).foregroundStyle(H.violetSoft)
                    Text(String(String(d.year).suffix(2)))
                        .font(.system(size: 8)).foregroundStyle(H.faint)
                }
                .frame(width: 38, height: 38)
                .background(H.surface2, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(H.border, lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(d.label).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(H.text)
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark").font(.system(size: 10, weight: .bold))
                        Text("Paid · \(Int(d.importKwh)) kWh").font(.system(size: 12))
                    }
                    .foregroundStyle(H.up)
                }
                Spacer(minLength: 8)
                Text("฿\(hbMoney(d.amount))")
                    .font(.system(size: 15, weight: .bold, design: .monospaced)).foregroundStyle(H.text)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(H.faint)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func open(_ d: Statement) {
        withAnimation(.smooth(duration: 0.3)) { selected = d }
    }

    // MARK: - Detail

    private func detail(_ d: Statement) -> some View {
        ZStack {
            H.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                detailTopBar(d)
                ScrollView {
                    VStack(spacing: 16) {
                        detailHero(d)
                        breakdown(d)
                        meterPayment(d)
                    }
                    .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 16)
                    .gtxUniversalWidth()
                }
                detailCTA
            }
        }
    }

    private func detailTopBar(_ d: Statement) -> some View {
        HStack(spacing: 12) {
            Button { withAnimation(.smooth(duration: 0.3)) { selected = nil } } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold)).foregroundStyle(H.violetSoft)
                    .frame(width: 38, height: 38)
                    .background(H.surface, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(H.border, lineWidth: 1))
            }
            .accessibilityLabel("Back to statements")
            Text(d.label)
                .font(.system(size: 18, weight: .bold)).tracking(-0.3).foregroundStyle(H.text)
            Spacer()
            Button {} label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 17, weight: .regular)).foregroundStyle(H.violetSoft)
                    .frame(width: 38, height: 38)
                    .background(H.surface, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(H.border, lineWidth: 1))
            }
            .accessibilityLabel("Share")
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)
        .gtxUniversalWidth()
    }

    private func detailHero(_ d: Statement) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Net total paid")
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white.opacity(0.85))
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: "checkmark").font(.system(size: 11, weight: .heavy))
                    Text("PAID").font(.system(size: 11.5, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 3)
                .background(H.up.opacity(0.3), in: Capsule())
            }
            Text("฿\(hbMoney(d.net))")
                .font(.system(size: 44, weight: .heavy, design: .monospaced)).tracking(-1.5)
                .foregroundStyle(.white).padding(.top, 6)
            HStack(spacing: 7) {
                Image(systemName: "calendar").font(.system(size: 13, weight: .semibold))
                Text("Paid \(d.paidOn) · \(d.method)").font(.system(size: 13))
            }
            .foregroundStyle(.white.opacity(0.85)).padding(.top, 4)

            // usage split
            GeometryReader { geo in
                HStack(spacing: 0) {
                    Rectangle().fill(Color.white.opacity(0.92))
                        .frame(width: geo.size.width * d.importKwh / d.totalKwh)
                    Rectangle().fill(H.up.opacity(0.95))
                }
            }
            .frame(height: 8)
            .clipShape(Capsule())
            .background(Color.black.opacity(0.2), in: Capsule())
            .padding(.top, 16)

            HStack(spacing: 16) {
                usageLegend(Color.white.opacity(0.92), "Imported \(fmtKwh(d.importKwh)) kWh")
                usageLegend(H.up.opacity(0.95), "Sold \(fmtKwh(d.sold)) kWh")
            }
            .padding(.top, 9)
        }
        .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 18)
        .background(
            ZStack(alignment: .topTrailing) {
                H.grad
                Circle().fill(Color.white.opacity(0.1)).frame(width: 170, height: 170)
                    .offset(x: 30, y: -50)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(hex: "#7C3AED", alpha: 0.42), radius: 18, y: 14)
    }

    private func usageLegend(_ color: Color, _ text: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2, style: .continuous).fill(color).frame(width: 7, height: 7)
            Text(text).font(.system(size: 11.5, weight: .semibold)).foregroundStyle(.white.opacity(0.85))
        }
    }

    private func breakdown(_ d: Statement) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Breakdown")
                .font(.system(size: 12, weight: .bold)).tracking(0.5).foregroundStyle(H.faint)
                .padding(.horizontal, 2)
            VStack(spacing: 0) {
                line("square.grid.2x2", H.blue, "Grid electricity",
                     "\(fmtKwh(d.importKwh)) kWh · ฿\(String(format: "%.2f", d.rate))/kWh",
                     d.gridCost, credit: false)
                Rectangle().fill(H.hair).frame(height: 1)
                line("arrow.left.arrow.right", H.up, "P2P energy sold",
                     "\(fmtKwh(d.sold)) kWh to neighbours", d.credit, credit: true)
                Rectangle().fill(H.hair).frame(height: 1)
                line("gauge.with.dots.needle.bottom.50percent", H.violet, "Service & grid fee",
                     "Fixed monthly", d.fee, credit: false)
                Rectangle().fill(H.hair).frame(height: 1)
                HStack(alignment: .firstTextBaseline) {
                    Text("Net total").font(.system(size: 15, weight: .bold)).foregroundStyle(H.text)
                    Spacer()
                    Text("฿\(hbMoney(d.net))")
                        .font(.system(size: 20, weight: .heavy, design: .monospaced)).foregroundStyle(H.violetSoft)
                }
                .padding(.vertical, 14)
            }
            .padding(.horizontal, 16)
            .background(H.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(H.border, lineWidth: 1))
        }
    }

    private func line(_ icon: String, _ color: Color, _ label: String,
                      _ sub: String, _ amount: Double, credit: Bool) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.094), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(color.opacity(0.25), lineWidth: 1))
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(H.text)
                Text(sub).font(.system(size: 12.5)).foregroundStyle(H.faint)
            }
            Spacer(minLength: 8)
            Text("\(credit ? "−" : "")฿\(hbMoney(amount))")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(credit ? H.up : H.text)
        }
        .padding(.vertical, 13)
    }

    private func meterPayment(_ d: Statement) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Meter & payment")
                .font(.system(size: 12, weight: .bold)).tracking(0.5).foregroundStyle(H.faint)
                .padding(.horizontal, 2)
            VStack(spacing: 0) {
                meta("Meter", "GTX-5821", first: true)
                meta("Previous read", "\(d.read0) kWh")
                meta("Current read", "\(d.read1) kWh")
                meta("Payment method", d.method)
                meta("Reference", "GTX-\(d.id.replacingOccurrences(of: "-", with: ""))")
            }
            .padding(.horizontal, 16)
            .background(H.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(H.border, lineWidth: 1))
        }
    }

    private func meta(_ label: String, _ value: String, first: Bool = false) -> some View {
        VStack(spacing: 0) {
            if !first { Rectangle().fill(H.hair).frame(height: 1) }
            HStack {
                Text(label).font(.system(size: 13.5)).foregroundStyle(H.muted)
                Spacer()
                Text(value).font(.system(size: 13.5, weight: .semibold, design: .monospaced)).foregroundStyle(H.text)
            }
            .padding(.vertical, 11)
        }
    }

    private var detailCTA: some View {
        HStack(spacing: 10) {
            Button {} label: {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text").font(.system(size: 17, weight: .regular))
                    Text("View receipt").font(.system(size: 15.5, weight: .semibold))
                }
                .foregroundStyle(H.text)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(H.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(H.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
            Button {} label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.to.line").font(.system(size: 17, weight: .semibold))
                    Text("PDF").font(.system(size: 15.5, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(H.grad, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .shadow(color: Color(hex: "#7C3AED", alpha: 0.42), radius: 13, y: 10)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 16)
        .gtxUniversalWidth()
        .frame(maxWidth: .infinity)
        .background(H.bg)
        .overlay(Rectangle().fill(H.border).frame(height: 1), alignment: .top)
    }

    // MARK: - Formatting

    private func hbMoney(_ n: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: n)) ?? String(format: "%.2f", n)
    }

    /// kWh values: render integers without a trailing .0, else one decimal.
    private func fmtKwh(_ n: Double) -> String {
        n == n.rounded() ? String(Int(n)) : String(format: "%.1f", n)
    }
}

// MARK: - Statement (pure, testable)

/// One monthly billing statement. `net` and `totalKwh`/`rate` are derived so the
/// list and detail render consistent figures. Kept free of SwiftUI for testing.
struct Statement: Identifiable, Equatable {
    let id: String          // "2026-05"
    let monthAbbrev: String // "May"
    let year: Int
    let label: String       // "May 2026"
    let amount: Double       // headline billed amount (list)
    let importKwh: Double
    let sold: Double
    let fee: Double
    let gridCost: Double
    let credit: Double
    let paidOn: String
    let method: String
    let read0: Int
    let read1: Int

    /// Net total paid = grid cost − P2P credit + fixed fee.
    var net: Double { gridCost - credit + fee }
    var totalKwh: Double { importKwh + sold }
    var rate: Double { importKwh == 0 ? 0 : gridCost / importKwh }

    static let all: [Statement] = [
        Statement(id: "2026-05", monthAbbrev: "May", year: 2026, label: "May 2026", amount: 612.40, importKwh: 198.0, sold: 104.2, fee: 38, gridCost: 966.20, credit: 391.80, paidOn: "26 May 2026", method: "PromptPay", read0: 41820, read1: 42018),
        Statement(id: "2026-04", monthAbbrev: "Apr", year: 2026, label: "Apr 2026", amount: 738.10, importKwh: 232.0, sold: 88.6, fee: 38, gridCost: 1132.20, credit: 432.10, paidOn: "27 Apr 2026", method: "Debit ••1234", read0: 41588, read1: 41820),
        Statement(id: "2026-03", monthAbbrev: "Mar", year: 2026, label: "Mar 2026", amount: 689.55, importKwh: 221.0, sold: 92.0, fee: 38, gridCost: 1078.80, credit: 427.25, paidOn: "25 Mar 2026", method: "PromptPay", read0: 41367, read1: 41588),
        Statement(id: "2026-02", monthAbbrev: "Feb", year: 2026, label: "Feb 2026", amount: 534.20, importKwh: 176.0, sold: 118.4, fee: 38, gridCost: 858.90, credit: 362.70, paidOn: "24 Feb 2026", method: "Bank transfer", read0: 41191, read1: 41367),
        Statement(id: "2026-01", monthAbbrev: "Jan", year: 2026, label: "Jan 2026", amount: 801.30, importKwh: 248.0, sold: 71.2, fee: 38, gridCost: 1210.50, credit: 447.20, paidOn: "26 Jan 2026", method: "Debit ••1234", read0: 40943, read1: 41191),
        Statement(id: "2025-12", monthAbbrev: "Dec", year: 2025, label: "Dec 2025", amount: 845.90, importKwh: 261.0, sold: 64.0, fee: 38, gridCost: 1273.60, credit: 465.70, paidOn: "27 Dec 2025", method: "PromptPay", read0: 40682, read1: 40943),
        Statement(id: "2025-11", monthAbbrev: "Nov", year: 2025, label: "Nov 2025", amount: 712.00, importKwh: 224.0, sold: 86.0, fee: 38, gridCost: 1094.40, credit: 420.40, paidOn: "25 Nov 2025", method: "PromptPay", read0: 40458, read1: 40682),
        Statement(id: "2025-10", monthAbbrev: "Oct", year: 2025, label: "Oct 2025", amount: 598.70, importKwh: 190.0, sold: 109.6, fee: 38, gridCost: 928.40, credit: 367.70, paidOn: "26 Oct 2025", method: "Bank transfer", read0: 40268, read1: 40458),
    ]
}

#Preview {
    BillingHistoryView()
}
