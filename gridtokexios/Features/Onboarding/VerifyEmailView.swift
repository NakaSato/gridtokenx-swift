//
//  VerifyEmailView.swift
//  gridtokexios
//
//  Screen 3 · Verify code. Native SwiftUI port of mock-ui screens.jsx.
//

import SwiftUI

struct VerifyEmailView: View {
    var email: String = CreateAccountView.bypassEmail
    var onBack: () -> Void = {}
    var onVerify: () -> Void = {}

    @ObserveInjection var inject

    /// Static bypass code — prefilled so Verify advances straight away.
    static let bypassCode = "419720"

    @State private var code = bypassCode
    @State private var invalid = false
    @FocusState private var focused: Bool

    private var digits: [String] {
        (0..<6).map { i in i < code.count ? String(Array(code)[i]) : "" }
    }
    private var complete: Bool { code.count == 6 }

    private func attemptVerify() {
        if code == Self.bypassCode { onVerify() } else { invalid = true }
    }

    var body: some View {
        ZStack(alignment: .top) {
            GTXColor.bg
                .overlay(alignment: .top) { GTXTopGlow() }
                .clipped()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                GTXBackButton(action: onBack)

                Text("Check your email")
                    .font(.system(size: 28, weight: .bold))
                    .tracking(-0.6)
                    .foregroundStyle(GTXColor.text)
                    .padding(.top, 26)
                    .padding(.bottom, 8)

                (Text("We sent a 6-digit code to\n")
                    + Text(email).foregroundColor(GTXColor.text).fontWeight(.semibold))
                    .font(.system(size: 15.5))
                    .lineSpacing(3)
                    .foregroundStyle(GTXColor.muted)

                codeBoxes
                    .padding(.top, 34)

                Text("Didn't get it? ")
                    .foregroundStyle(GTXColor.muted)
                    + Text("Resend in 0:24").foregroundColor(GTXColor.faint)

                if invalid {
                    Text("That code doesn't match. Use \(Self.bypassCode).")
                        .font(.system(size: 13))
                        .foregroundStyle(GTXColor.sell)
                        .padding(.top, 14)
                }

                Spacer(minLength: 24)

                Button("Verify", action: attemptVerify)
                    .buttonStyle(GTXPrimaryButtonStyle())
                    .opacity(complete ? 1 : 0.5)
                    .disabled(!complete)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 44)
            .font(.system(size: 14.5))
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { focused = true }
        .enableInjection()
    }

    private var codeBoxes: some View {
        ZStack {
            // Hidden field captures keystrokes; tapping any box focuses it.
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focused)
                .opacity(0.01)
                .onChange(of: code) { _, new in
                    code = String(new.filter(\.isNumber).prefix(6))
                    invalid = false
                }

            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { i in
                    digitBox(i)
                }
            }
            .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .onTapGesture { focused = true }
    }

    private func digitBox(_ i: Int) -> some View {
        let d = digits[i]
        let active = i == min(code.count, 5) && focused && !complete
        let filled = !d.isEmpty
        return ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(filled ? GTXColor.violet.opacity(0.12) : GTXColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(active ? GTXColor.violet : (filled ? GTXColor.violet.opacity(0.45) : GTXColor.border),
                                lineWidth: active ? 1.5 : 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(GTXColor.violet.opacity(active ? 0.16 : 0), lineWidth: 4)
                )

            Text(d)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(GTXColor.text)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 62)
    }

}

#Preview {
    VerifyEmailView()
}
