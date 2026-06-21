//
//  BillingView.swift
//  gridtokexios
//
//  10 · Electrical billing — monthly statement. Net bill = grid import − P2P
//  energy sold + fixed service fee. Hero amount due, this-period breakdown,
//  solar-savings callout, past statements, pay CTA. Native port of
//  mock-ui/billing.jsx (BillingPage). Same dark + purple system; green/red
//  reserved for credit/charge. Bill math lives in the testable `BillStatement`.
//

import SwiftUI

struct BillingView: View {
    var onBack: () -> Void = {}
    var onHistory: () -> Void = {}

    @ObserveInjection var inject

    // Palette (mock-ui `BL`).
    private enum BL {
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

    private let bill = BillStatement.sample
    private let history = BillStatement.history

    var body: some View {
        ZStack {
            BL.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(spacing: 16) {
                        hero
                        breakdown
                        savingsCallout
                        pastStatements
                    }
                    .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 16)
                    .gtxUniversalWidth()
                }
                ctaBar
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

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold)).foregroundStyle(BL.muted)
            }
            .accessibilityLabel("Back")
            Text("Electrical billing")
                .font(.system(size: 20, weight: .bold)).tracking(-0.3).foregroundStyle(BL.text)
            Spacer()
            Image(systemName: "doc.text")
                .font(.system(size: 18, weight: .regular)).foregroundStyle(BL.muted)
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)
    }

    // MARK: - Hero (amount due)

    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            Circle().fill(Color.white.opacity(0.1))
                .frame(width: 170, height: 170).offset(x: 30, y: -50)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Amount due · June 2026")
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white.opacity(0.85))
                    Spacer()
                    Text("UNPAID")
                        .font(.system(size: 11.5, weight: .bold)).foregroundStyle(.white)
                        .padding(.horizontal, 9).padding(.vertical, 3)
                        .background(BL.gold.opacity(0.28), in: Capsule())
                }
                Text("฿\(BillStatement.group(bill.net))")
                    .font(.system(size: 44, weight: .heavy, design: .monospaced)).tracking(-1.5)
                    .foregroundStyle(.white).padding(.top, 6)
                HStack(spacing: 7) {
                    Image(systemName: "info.circle").font(.system(size: 13, weight: .semibold))
                    Text("Due \(bill.due) · Meter \(bill.meter)")
                }
                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.85)).padding(.top, 4)

                // usage split bar
                GeometryReader { geo in
                    let importW = geo.size.width * bill.importFraction
                    HStack(spacing: 0) {
                        Rectangle().fill(Color.white.opacity(0.92)).frame(width: importW)
                        Rectangle().fill(BL.up.opacity(0.95))
                    }
                }
                .frame(height: 8)
                .clipShape(Capsule())
                .background(Color.black.opacity(0.2), in: Capsule())
                .padding(.top, 16)

                HStack(spacing: 16) {
                    legend(Color.white.opacity(0.92), "Imported \(bill.gridKwh.clean) kWh")
                    legend(BL.up.opacity(0.95), "Sold \(bill.soldKwh.clean) kWh")
                }
                .padding(.top, 9)
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 18, trailing: 20))
        }
        .background(BL.grad, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(hex: "#7C3AED", alpha: 0.42), radius: 18, y: 14)
    }

    private func legend(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 7, height: 7)
            Text(label).font(.system(size: 11.5, weight: .semibold)).foregroundStyle(.white.opacity(0.85))
        }
    }

    // MARK: - Breakdown (this period)

    private var breakdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("THIS PERIOD")
                .font(.system(size: 12, weight: .bold)).tracking(0.5).foregroundStyle(BL.faint)
                .padding(.horizontal, 2).padding(.bottom, 2)
            VStack(spacing: 0) {
                line(icon: "rectangle.split.3x3", color: BL.blue, label: "Grid electricity",
                     sub: "\(bill.gridKwh.clean) kWh imported · ฿4.88/kWh", amount: bill.gridCost)
                divider
                line(icon: "arrow.left.arrow.right", color: BL.up, label: "P2P energy sold",
                     sub: "\(bill.soldKwh.clean) kWh to neighbours", amount: bill.soldCredit, credit: true)
                divider
                line(icon: "gauge.with.dots.needle.bottom.50percent", color: BL.violet,
                     label: "Service & grid fee", sub: "Fixed monthly", amount: bill.serviceFee)
                divider
                HStack(alignment: .firstTextBaseline) {
                    Text("Net total").font(.system(size: 15, weight: .bold)).foregroundStyle(BL.text)
                    Spacer()
                    Text("฿\(BillStatement.group(bill.net))")
                        .font(.system(size: 20, weight: .heavy, design: .monospaced))
                        .foregroundStyle(BL.violetSoft)
                }
                .padding(.vertical, 14)
            }
            .padding(.horizontal, 16)
            .background(BL.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(BL.border, lineWidth: 1))
        }
    }

    private func line(icon: String, color: Color, label: String, sub: String,
                      amount: Double, credit: Bool = false) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold)).foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.094), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(color.opacity(0.25), lineWidth: 1))
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(BL.text)
                Text(sub).font(.system(size: 12.5)).foregroundStyle(BL.faint)
            }
            Spacer(minLength: 8)
            Text("\(credit ? "−" : "")฿\(BillStatement.group(amount))")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(credit ? BL.up : BL.text)
        }
        .padding(.vertical, 13)
    }

    private var divider: some View {
        Rectangle().fill(BL.hair).frame(height: 1)
    }

    // MARK: - Savings callout

    private var savingsCallout: some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf").font(.system(size: 20, weight: .regular)).foregroundStyle(BL.up)
            (Text("Selling your solar cut this bill by ")
                + Text("฿\(BillStatement.group(bill.soldCredit))").foregroundStyle(BL.up).bold()
                + Text(" — about ")
                + Text("\(bill.savingsPercent)%").foregroundStyle(BL.text).bold()
                + Text(" off grid-only."))
                .font(.system(size: 13)).foregroundStyle(BL.muted).lineSpacing(2)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 15).padding(.vertical, 13)
        .background(BL.up.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(BL.up.opacity(0.28), lineWidth: 1))
    }

    // MARK: - Past statements

    private var pastStatements: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("PAST STATEMENTS")
                .font(.system(size: 12, weight: .bold)).tracking(0.5).foregroundStyle(BL.faint)
                .padding(.horizontal, 2).padding(.bottom, 8)
            VStack(spacing: 0) {
                ForEach(Array(history.enumerated()), id: \.offset) { i, h in
                    if i > 0 { divider }
                    Button(action: onHistory) {
                        HStack(spacing: 13) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 16, weight: .regular)).foregroundStyle(BL.muted)
                                .frame(width: 34, height: 34)
                                .background(BL.surface2, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(BL.border, lineWidth: 1))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(h.month).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(BL.text)
                                HStack(spacing: 5) {
                                    Image(systemName: "checkmark").font(.system(size: 10, weight: .heavy))
                                    Text("Paid").font(.system(size: 12))
                                }
                                .foregroundStyle(BL.up)
                            }
                            Spacer(minLength: 8)
                            Text("฿\(BillStatement.group(h.amount))")
                                .font(.system(size: 14.5, weight: .bold, design: .monospaced)).foregroundStyle(BL.muted)
                            Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(BL.faint)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(BL.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(BL.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    // MARK: - CTA

    private var ctaBar: some View {
        VStack(spacing: 0) {
            Button {} label: {
                HStack(spacing: 9) {
                    Image(systemName: "creditcard").font(.system(size: 18, weight: .semibold))
                    Text("Pay ฿\(BillStatement.group(bill.net))").font(.system(size: 17, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(BL.grad, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color(hex: "#7C3AED", alpha: 0.42), radius: 13, y: 10)
            }
            .buttonStyle(.plain)
            .gtxUniversalWidth()
        }
        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 30)
        .background(BL.bg)
        .overlay(Rectangle().fill(BL.border).frame(height: 1), alignment: .top)
    }
}

// MARK: - Bill statement (pure, testable)

/// Monthly electrical statement figures (THB) and derived totals. Net bill =
/// grid import cost − P2P sold credit + fixed service fee. Kept free of SwiftUI
/// so the bill math can be unit-tested directly.
struct BillStatement {
    var gridKwh: Double
    var gridCost: Double
    var soldKwh: Double
    var soldCredit: Double
    var serviceFee: Double
    var due: String
    var meter: String

    var net: Double { gridCost - soldCredit + serviceFee }
    var totalKwh: Double { gridKwh + soldKwh }
    var importFraction: Double { totalKwh == 0 ? 0 : gridKwh / totalKwh }
    /// Solar savings vs grid-only, rounded to whole percent.
    var savingsPercent: Int {
        let gridOnly = gridCost + serviceFee
        return gridOnly == 0 ? 0 : Int((soldCredit / gridOnly * 100).rounded())
    }

    static let sample = BillStatement(
        gridKwh: 214.0, gridCost: 1043.30,
        soldKwh: 96.4, soldCredit: 412.90,
        serviceFee: 38.00,
        due: "28 Jun 2026", meter: "GTX-5821")

    struct Past: Hashable { var month: String; var amount: Double }
    static let history: [Past] = [
        Past(month: "May 2026", amount: 612.40),
        Past(month: "Apr 2026", amount: 738.10),
        Past(month: "Mar 2026", amount: 689.55),
    ]

    /// `n.toLocaleString('en-US', { 2 fraction digits })` — thousands grouping.
    static func group(_ n: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.locale = Locale(identifier: "en_US")
        return f.string(from: NSNumber(value: n)) ?? String(format: "%.2f", n)
    }
}

private extension Double {
    /// Drops a trailing `.0` for kWh labels (214.0 → "214", 96.4 → "96.4").
    var clean: String {
        self == rounded() ? String(Int(self)) : String(self)
    }
}

#Preview {
    BillingView()
}
