//
//  TransferView.swift
//  gridtokexios
//
//  Deposit & Withdraw — add or pull THB funds with a shared numeric keypad.
//  Native port of mock-ui/transfer.jsx (DepositPage + WithdrawPage and the
//  shared NumPad). Each entry view drives a custom keypad (no system keyboard):
//  amount hero, quick-amount chips, payment-method / destination rows, then a
//  pinned keypad + CTA. Deposit branches into method detail screens (PromptPay
//  QR, bank transfer, debit card with a 1.5% fee summary); Withdraw validates
//  against an available balance. Amount/format/fee math lives in the pure,
//  testable `TransferAmount` struct. Send / Swap from the JSX are out of scope.
//

import SwiftUI

// MARK: - Pure amount model (testable)

/// Keypad-driven amount entry + display/format/fee math. No SwiftUI so it can
/// be unit-tested directly. `raw` is the literal entry string (may be empty,
/// trailing-dot, etc.); derived getters group/round it for display.
struct TransferAmount: Equatable {
    /// Raw entry string, e.g. "" / "0." / "1500.5".
    var raw: String

    init(_ raw: String = "") { self.raw = raw }

    /// Numeric value; empty/"."/garbage → 0.
    var value: Double {
        if raw.isEmpty || raw == "." { return 0 }
        return Double(raw) ?? 0
    }

    var isEmpty: Bool { raw.isEmpty }
    var isPositive: Bool { value > 0 }

    /// Thousands-grouped display of the raw entry, preserving a typed decimal.
    /// "" / "." → "0"; "1500" → "1,500"; "1500.5" → "1,500.5".
    var grouped: String { Self.group(raw) }

    /// Apply a keypad press: a digit, "." or "del".
    mutating func press(_ key: String) {
        switch key {
        case "del":
            if !raw.isEmpty { raw.removeLast() }
        case ".":
            if !raw.contains(".") { raw = raw.isEmpty ? "0." : raw + "." }
        default: // digit
            let parts = raw.split(separator: ".", omittingEmptySubsequences: false)
            if parts.count == 2, parts[1].count >= 2 { return } // max 2 decimals
            if raw == "0" { raw = key } else { raw += key }
        }
    }

    /// Set from a preset numeric value (drops trailing ".0").
    mutating func set(_ v: Double) {
        raw = v == v.rounded() ? String(Int(v)) : String(v)
    }

    // Card-fee math (mock: 1.5% debit-card fee).
    static let cardFeeRate = 0.015
    var cardFee: Double { value * Self.cardFeeRate }
    var cardTotal: Double { value + cardFee }

    /// Thousands-group a raw amount string, keeping any typed decimal portion.
    static func group(_ str: String) -> String {
        if str.isEmpty || str == "." { return "0" }
        let parts = str.split(separator: ".", omittingEmptySubsequences: false)
        let intPart = Int(parts.first ?? "0") ?? 0
        let gi = intPart.formatted(.number.grouping(.automatic))
        if parts.count == 2 { return "\(gi).\(parts[1])" }
        return gi
    }

    /// "฿1,234.50" style fixed-2 currency from a Double.
    static func baht(_ v: Double) -> String {
        "฿" + group(String(format: "%.2f", v))
    }
}

// MARK: - Palette (mock-ui `T`)

private enum TT {
    static let bg         = Color(hex: "#0B0712")
    static let surface    = Color.white.opacity(0.05)
    static let surface2   = Color.white.opacity(0.08)
    static let border     = Color.white.opacity(0.09)
    static let text       = Color(hex: "#F4F1FA")
    static let muted      = Color(hex: "#F4F1FA", alpha: 0.54)
    static let faint      = Color(hex: "#F4F1FA", alpha: 0.32)
    static let violet     = Color(hex: "#9B6BFF")
    static let violetSoft = Color(hex: "#C9B4FF")
    static let up         = Color(hex: "#2FD08A")
    static let down       = Color(hex: "#FF5C6C")
    static let warning    = Color(hex: "#FFD166")
    static let grad       = LinearGradient(
        colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
        startPoint: .topLeading, endPoint: .bottomTrailing)
}

// MARK: - Shared numeric keypad

/// 3×4 keypad: 1-9, ".", 0, delete. Mirrors the JSX `NumPad`.
struct NumericKeypad: View {
    var onPress: (String) -> Void

    private let keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "del"]
    private let cols = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        LazyVGrid(columns: cols, spacing: 8) {
            ForEach(keys, id: \.self) { k in
                Button { onPress(k) } label: {
                    Group {
                        if k == "del" {
                            Image(systemName: "delete.left")
                                .font(.system(size: 22, weight: .regular))
                                .foregroundStyle(TT.muted)
                        } else {
                            Text(k)
                                .font(.system(size: 23, weight: .semibold, design: .monospaced))
                                .foregroundStyle(TT.text)
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(TT.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Shared chrome

/// Header back button + title, mirrors JSX `TopBar` / `MethodTopBar`.
private struct TransferTopBar: View {
    var title: String
    var onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold)).foregroundStyle(TT.violetSoft)
                    .frame(width: 38, height: 38)
                    .background(TT.surface, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(TT.border, lineWidth: 1))
            }
            .accessibilityLabel("Back")
            Text(title).font(.system(size: 22, weight: .bold)).tracking(-0.4).foregroundStyle(TT.text)
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)
    }
}

/// Big centred amount with the ฿ glyph; error state recolours to red.
private struct AmountHero: View {
    var amount: TransferAmount
    var sub: String
    var error: String? = nil

    private var color: Color { amount.isEmpty ? TT.faint : (error != nil ? TT.down : TT.text) }

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top, spacing: 4) {
                Text("฿")
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundStyle(color).padding(.top, 8)
                Text(amount.grouped)
                    .font(.system(size: 52, weight: .heavy, design: .monospaced))
                    .tracking(-1).foregroundStyle(color)
            }
            Text(error ?? sub)
                .font(.system(size: 13.5))
                .foregroundStyle(error != nil ? TT.down : TT.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 6).padding(.bottom, 2)
    }
}

/// Quick-amount selector pill.
private struct AmountChip: View {
    var label: String
    var on: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundStyle(on ? TT.violetSoft : TT.muted)
                .frame(maxWidth: .infinity).frame(height: 38)
                .background(on ? AnyShapeStyle(TT.violet.opacity(0.16)) : AnyShapeStyle(TT.surface),
                            in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(on ? TT.violet : TT.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

/// Selectable method / destination row with leading icon + check.
private struct MethodRow: View {
    var icon: String
    var title: String
    var sub: String
    var on: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(on ? AnyShapeStyle(TT.grad) : AnyShapeStyle(Color.white.opacity(0.06)),
                                in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 15.5, weight: .semibold)).foregroundStyle(TT.text)
                    Text(sub).font(.system(size: 12.5)).foregroundStyle(TT.muted)
                }
                Spacer(minLength: 8)
                ZStack {
                    Circle()
                        .fill(on ? TT.violet : Color.clear)
                        .overlay(Circle().stroke(on ? TT.violet : TT.faint, lineWidth: 1.5))
                        .frame(width: 22, height: 22)
                    if on {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .heavy)).foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(on ? AnyShapeStyle(TT.violet.opacity(0.12)) : AnyShapeStyle(TT.surface),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(on ? TT.violet : TT.border, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

/// Pinned keypad + primary CTA above the home indicator.
private struct KeypadBar<CTA: View>: View {
    var onPress: (String) -> Void
    @ViewBuilder var cta: () -> CTA

    var body: some View {
        VStack(spacing: 12) {
            NumericKeypad(onPress: onPress)
            cta()
        }
        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 30)
        .background(TT.bg)
        .overlay(Rectangle().fill(TT.border).frame(height: 1), alignment: .top)
    }
}

/// Disabled-aware gradient CTA used across the transfer screens.
private struct TransferCTA: View {
    var title: String
    var enabled: Bool
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: { if enabled { action() } }) {
            HStack(spacing: 9) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 19, weight: .bold))
                }
                Text(title).font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(enabled ? AnyShapeStyle(TT.grad) : AnyShapeStyle(Color.white.opacity(0.08)),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(enabled ? 1 : 0.6)
            .shadow(color: enabled ? Color(hex: "#7C3AED", alpha: 0.42) : .clear, radius: 13, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

/// Label + value with a Copy button (JSX `CopyRow`).
private struct CopyRow: View {
    var label: String
    var value: String
    var mono: Bool = true

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(label.uppercased())
                    .font(.system(size: 11.5)).tracking(0.4).foregroundStyle(TT.faint)
                Text(value)
                    .font(.system(size: 15.5, weight: .semibold, design: mono ? .monospaced : .default))
                    .tracking(mono ? 0.5 : 0).foregroundStyle(TT.text)
            }
            Spacer(minLength: 8)
            Button { UIPasteboard.general.string = value } label: {
                HStack(spacing: 5) {
                    Image(systemName: "doc.on.doc").font(.system(size: 12, weight: .semibold))
                    Text("Copy").font(.system(size: 12.5, weight: .semibold))
                }
                .foregroundStyle(TT.violetSoft)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(TT.surface, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(TT.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
    }
}

private func hairline(inset: CGFloat = 0) -> some View {
    Rectangle().fill(TT.border).frame(height: 1).padding(.leading, inset)
}

// MARK: - Deposit

/// `Deposit` — add funds to THB balance (mock-ui DepositPage). Amount entry,
/// preset chips, PromptPay / bank / card method rows; Continue branches into the
/// chosen method detail screen.
struct DepositView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    private enum Method: String { case promptpay, bank, card }

    @State private var amount = TransferAmount("500")
    @State private var method: Method = .promptpay
    @State private var screen: Method? = nil

    private let presets: [Double] = [100, 500, 1000, 2000]

    var body: some View {
        ZStack {
            TT.bg.ignoresSafeArea()
            switch screen {
            case .promptpay: DepositPromptPay(amount: amount, onBack: { screen = nil })
            case .bank:      DepositBank(amount: amount, onBack: { screen = nil })
            case .card:      DepositCard(amount: amount, onBack: { screen = nil })
            case .none:      form
            }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .simultaneousGesture(
            DragGesture(minimumDistance: 18).onEnded { v in
                guard screen == nil else { return }
                if v.startLocation.x < 24, v.translation.width > 70, abs(v.translation.height) < 60 {
                    onBack()
                }
            })
        .enableInjection()
    }

    private var form: some View {
        VStack(spacing: 0) {
            TransferTopBar(title: "Deposit", onBack: onBack)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AmountHero(amount: amount, sub: "Add funds to your THB balance")
                    HStack(spacing: 8) {
                        ForEach(presets, id: \.self) { p in
                            AmountChip(label: "฿\(Int(p).formatted())", on: amount.value == p) {
                                amount.set(p)
                            }
                        }
                    }
                    Text("Pay with").font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(TT.muted).padding(.leading, 2).padding(.bottom, -4)
                    VStack(spacing: 10) {
                        MethodRow(icon: "qrcode", title: "PromptPay", sub: "Instant · no fee",
                                  on: method == .promptpay) { method = .promptpay }
                        MethodRow(icon: "building.columns", title: "Bank transfer", sub: "SCB ••4192 · instant",
                                  on: method == .bank) { method = .bank }
                        MethodRow(icon: "creditcard", title: "Debit card", sub: "1.5% fee",
                                  on: method == .card) { method = .card }
                    }
                }
                .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 12)
                .gtxUniversalWidth()
            }
            KeypadBar(onPress: { amount.press($0) }) {
                TransferCTA(
                    title: amount.isPositive ? "Continue · ฿\(amount.grouped)" : "Enter amount",
                    enabled: amount.isPositive
                ) { withAnimation(.smooth(duration: 0.25)) { screen = method } }
            }
        }
    }
}

// MARK: - Deposit method detail screens

private struct MethodDetailScaffold<Content: View, Footer: View>: View {
    var title: String
    var onBack: () -> Void
    @ViewBuilder var content: () -> Content
    @ViewBuilder var footer: () -> Footer

    var body: some View {
        VStack(spacing: 0) {
            TransferTopBar(title: title, onBack: onBack)
            ScrollView {
                VStack(spacing: 16) { content() }
                    .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 16)
                    .gtxUniversalWidth()
            }
            VStack { footer() }
                .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 30)
                .background(TT.bg)
                .overlay(Rectangle().fill(TT.border).frame(height: 1), alignment: .top)
        }
    }
}

private struct DepositPromptPay: View {
    var amount: TransferAmount
    var onBack: () -> Void

    var body: some View {
        MethodDetailScaffold(title: "PromptPay", onBack: onBack) {
            VStack(spacing: 2) {
                Text("Scan to add").font(.system(size: 13.5)).foregroundStyle(TT.muted)
                Text("฿\(amount.grouped)")
                    .font(.system(size: 34, weight: .heavy, design: .monospaced))
                    .tracking(-1).foregroundStyle(TT.text)
            }
            FakeQR()
            HStack(spacing: 7) {
                Image(systemName: "clock").font(.system(size: 15, weight: .medium)).foregroundStyle(TT.faint)
                Text("Expires in ").font(.system(size: 13)).foregroundStyle(TT.muted)
                    + Text("04:58").font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundStyle(TT.text)
            }
            VStack(spacing: 0) {
                CopyRow(label: "PromptPay ID", value: "0812345678")
                hairline(inset: 16)
                CopyRow(label: "Reference", value: "GTX-DEP-8842")
            }
            .background(TT.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(TT.border, lineWidth: 1))
            Text("Open any Thai banking app, scan the QR or enter the PromptPay ID. Funds arrive instantly.")
                .font(.system(size: 12.5)).foregroundStyle(TT.faint)
                .multilineTextAlignment(.center).lineSpacing(2)
        } footer: {
            TransferCTA(title: "I've paid", enabled: true) {}
        }
    }
}

private struct DepositBank: View {
    var amount: TransferAmount
    var onBack: () -> Void

    var body: some View {
        MethodDetailScaffold(title: "Bank transfer", onBack: onBack) {
            VStack(spacing: 2) {
                Text("Transfer exactly").font(.system(size: 13.5)).foregroundStyle(TT.muted)
                Text("฿\(amount.grouped)")
                    .font(.system(size: 34, weight: .heavy, design: .monospaced))
                    .tracking(-1).foregroundStyle(TT.text)
            }
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(TT.grad, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Siam Commercial Bank").font(.system(size: 15.5, weight: .semibold)).foregroundStyle(TT.text)
                        Text("GridTokenX (Thailand) Co.").font(.system(size: 12.5)).foregroundStyle(TT.muted)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                hairline()
                CopyRow(label: "Account number", value: "123-4-56789-0")
                hairline(inset: 16)
                CopyRow(label: "Reference (required)", value: "GTX-DEP-8842")
            }
            .background(TT.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(TT.border, lineWidth: 1))
            HStack(alignment: .top, spacing: 9) {
                Image(systemName: "shield").font(.system(size: 15, weight: .medium)).foregroundStyle(TT.warning)
                (Text("Always include the ").foregroundStyle(TT.muted)
                    + Text("reference").foregroundStyle(TT.text).bold()
                    + Text(" so we can match your transfer. Arrives in seconds for most Thai banks.").foregroundStyle(TT.muted))
                    .font(.system(size: 12.5)).lineSpacing(1)
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(TT.warning.opacity(0.1), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(TT.warning.opacity(0.28), lineWidth: 1))
        } footer: {
            TransferCTA(title: "I've transferred", enabled: true) {}
        }
    }
}

private struct DepositCard: View {
    var amount: TransferAmount
    var onBack: () -> Void

    var body: some View {
        MethodDetailScaffold(title: "Debit card", onBack: onBack) {
            CardPreview()
            CardField(label: "Card number", value: "4242 4242 4242 1234")
            HStack(spacing: 12) {
                CardField(label: "Expiry", value: "09 / 27")
                CardField(label: "CVC", value: nil, placeholder: "123")
            }
            VStack(spacing: 8) {
                summaryRow("Amount", TransferAmount.baht(amount.value))
                summaryRow("Card fee (1.5%)", TransferAmount.baht(amount.cardFee))
                hairline()
                HStack {
                    Text("Total").font(.system(size: 14.5, weight: .semibold)).foregroundStyle(TT.text)
                    Spacer()
                    Text(TransferAmount.baht(amount.cardTotal))
                        .font(.system(size: 19, weight: .heavy, design: .monospaced))
                        .foregroundStyle(TT.violetSoft)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(TT.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(TT.border, lineWidth: 1))
            HStack(spacing: 6) {
                Image(systemName: "lock").font(.system(size: 13, weight: .medium))
                Text("Encrypted · 3-D Secure").font(.system(size: 12))
            }
            .foregroundStyle(TT.faint)
        } footer: {
            TransferCTA(title: "Pay \(TransferAmount.baht(amount.cardTotal))", enabled: true) {}
        }
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 13.5)).foregroundStyle(TT.muted)
            Spacer()
            Text(value).font(.system(size: 13.5, weight: .semibold, design: .monospaced)).foregroundStyle(TT.text)
        }
    }

    private struct CardField: View {
        var label: String
        var value: String?
        var placeholder: String = ""

        var body: some View {
            VStack(alignment: .leading, spacing: 7) {
                Text(label).font(.system(size: 12, weight: .semibold)).foregroundStyle(TT.muted)
                HStack {
                    Text(value ?? placeholder)
                        .font(.system(size: 16, design: .monospaced)).tracking(1)
                        .foregroundStyle(value != nil ? TT.text : TT.faint)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14).frame(height: 52)
                .background(TT.surface, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(TT.border, lineWidth: 1))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private struct CardPreview: View {
        var body: some View {
            ZStack {
                LinearGradient(colors: [Color(hex: "#7C3AED"), Color(hex: "#A974FF"), Color(hex: "#6D28D9")],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                VStack {
                    HStack {
                        (Text("GridToken").foregroundStyle(.white)
                            + Text("X").foregroundStyle(.white.opacity(0.7)))
                            .font(.system(size: 14, weight: .heavy)).tracking(0.5)
                        Spacer()
                        Image(systemName: "wave.3.right").font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(LinearGradient(colors: [Color(hex: "#F5D98B"), Color(hex: "#C9A24B")],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 33)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("4242 •••• •••• 1234")
                        .font(.system(size: 21, weight: .semibold, design: .monospaced)).tracking(2.5)
                        .foregroundStyle(.white).shadow(color: .black.opacity(0.25), radius: 1, y: 1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    HStack(alignment: .bottom) {
                        cardMeta("CARD HOLDER", "MAYA CHEN", mono: false)
                        Spacer()
                        cardMeta("EXPIRES", "09/27", mono: true)
                        Spacer()
                        HStack(spacing: -11) {
                            Circle().fill(Color(red: 1, green: 80/255, blue: 90/255).opacity(0.9))
                            Circle().fill(Color(red: 1, green: 179/255, blue: 71/255).opacity(0.85))
                        }
                        .frame(width: 41, height: 26)
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 18)
            }
            .aspectRatio(1.586, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color(hex: "#7C3AED", alpha: 0.5), radius: 20, y: 16)
        }

        private func cardMeta(_ label: String, _ value: String, mono: Bool) -> some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 8.5, weight: .semibold)).tracking(1)
                    .foregroundStyle(.white.opacity(0.6))
                Text(value)
                    .font(.system(size: 13.5, weight: .semibold, design: mono ? .monospaced : .default))
                    .tracking(mono ? 0 : 0.5).foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Faux QR

/// Deterministic fake QR on a white tile (port of JSX `FakeQR`).
private struct FakeQR: View {
    var size: CGFloat = 176

    private static let N = 23
    private var cells: [(Int, Int)] {
        let n = Self.N
        func finder(_ r: Int, _ c: Int) -> Bool {
            (r < 7 && c < 7) || (r < 7 && c >= n - 7) || (r >= n - 7 && c < 7)
        }
        var out: [(Int, Int)] = []
        for r in 0..<n {
            for c in 0..<n {
                let on: Bool
                if finder(r, c) {
                    let lr = r < 7 ? r : r - (n - 7)
                    let lc = c < 7 ? c : c - (n - 7)
                    on = lr == 0 || lr == 6 || lc == 0 || lc == 6 || (lr >= 2 && lr <= 4 && lc >= 2 && lc <= 4)
                } else {
                    on = (r * 7 + c * 13 + (r ^ c) * 5) % 3 == 0
                }
                if on { out.append((r, c)) }
            }
        }
        return out
    }

    var body: some View {
        let n = CGFloat(Self.N)
        let cell = size / n
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white)
            Canvas { ctx, _ in
                for (r, c) in cells {
                    let rect = CGRect(x: CGFloat(c) * cell, y: CGFloat(r) * cell,
                                      width: cell * 1.02, height: cell * 1.02)
                    ctx.fill(Path(rect), with: .color(Color(hex: "#0B0712")))
                }
            }
            .frame(width: size, height: size)
        }
        .frame(width: size + 24, height: size + 24)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Withdraw

/// `Withdraw` — pull THB out to a bank / PromptPay (mock-ui WithdrawPage).
/// Validates the amount against the available balance; CTA disables on over/zero.
struct WithdrawView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    private enum Dest: String { case scb, promptpay }

    private static let available = 320.0

    @State private var amount = TransferAmount("200")
    @State private var dest: Dest = .scb

    private var over: Bool { amount.value > Self.available }
    private var valid: Bool { amount.isPositive && !over }

    private var chips: [(String, Double)] {
        [("฿50", 50), ("฿100", 100), ("฿200", 200), ("Max", Self.available)]
    }

    var body: some View {
        ZStack {
            TT.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                TransferTopBar(title: "Withdraw", onBack: onBack)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        AmountHero(amount: amount,
                                   sub: "Available \(TransferAmount.baht(Self.available))",
                                   error: over ? "Exceeds available balance" : nil)
                        HStack(spacing: 8) {
                            ForEach(chips, id: \.0) { label, v in
                                AmountChip(label: label, on: amount.value == v) { amount.set(v) }
                            }
                        }
                        Text("Withdraw to").font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(TT.muted).padding(.leading, 2).padding(.bottom, -4)
                        VStack(spacing: 10) {
                            MethodRow(icon: "building.columns", title: "SCB Savings",
                                      sub: "••4192 · 1–2 business days", on: dest == .scb) { dest = .scb }
                            MethodRow(icon: "bolt.fill", title: "Instant to PromptPay",
                                      sub: "฿10 fee · arrives now", on: dest == .promptpay) { dest = .promptpay }
                        }
                        Button {} label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus").font(.system(size: 16, weight: .semibold))
                                Text("Add bank account").font(.system(size: 14.5, weight: .semibold))
                            }
                            .foregroundStyle(TT.violetSoft)
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(TT.border, style: StrokeStyle(lineWidth: 1, dash: [5, 4])))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 12)
                    .gtxUniversalWidth()
                }
                KeypadBar(onPress: { amount.press($0) }) {
                    TransferCTA(
                        title: over ? "Amount too high"
                            : amount.isPositive ? "Withdraw ฿\(amount.grouped)" : "Enter amount",
                        enabled: valid
                    ) {}
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
}

#Preview { DepositView() }

#Preview("Withdraw") { WithdrawView() }
