//
//  CreateAccountView.swift
//  gridtokexios
//
//  Screen 2 · Create account. Native SwiftUI port of mock-ui screens.jsx.
//

import SwiftUI

struct CreateAccountView: View {
    var onBack: () -> Void = {}
    var onContinue: () -> Void = {}

    @ObserveInjection var inject

    // Static bypass credentials — prefilled so Continue skips straight into the app.
    static let bypassEmail = "maya.chen@gmail.com"
    static let bypassPassword = "gridtokenx"

    @State private var email = bypassEmail
    @State private var password = bypassPassword
    @State private var showPassword = false
    @State private var invalid = false
    @FocusState private var focus: FieldID?

    private enum FieldID { case email, password }

    private var credsMatch: Bool {
        email.trimmingCharacters(in: .whitespaces).lowercased() == Self.bypassEmail
            && password == Self.bypassPassword
    }

    private func attemptContinue() {
        if credsMatch { onContinue() } else { invalid = true }
    }

    var body: some View {
        ZStack(alignment: .top) {
            GTXColor.bg
                .overlay(alignment: .top) { GTXTopGlow() }
                .clipped()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                GTXBackButton(action: onBack)

                Text("Create your account")
                    .font(.system(size: 28, weight: .bold))
                    .tracking(-0.6)
                    .foregroundStyle(GTXColor.text)
                    .padding(.top, 26)
                    .padding(.bottom, 8)

                Text("Start trading energy in under a minute.")
                    .font(.system(size: 15.5))
                    .lineSpacing(3)
                    .foregroundStyle(GTXColor.muted)

                VStack(spacing: 18) {
                    GTXField(label: "EMAIL", placeholder: "you@example.com", text: $email,
                             isFocused: focus == .email, keyboard: .emailAddress)
                        .focused($focus, equals: .email)

                    GTXField(label: "PASSWORD", placeholder: "••••••••••", text: $password,
                             isFocused: focus == .password, secure: !showPassword,
                             trailing: {
                                 Button(showPassword ? "Hide" : "Show") { showPassword.toggle() }
                                     .font(.system(size: 14, weight: .semibold))
                                     .foregroundStyle(GTXColor.violetSoft)
                             })
                        .focused($focus, equals: .password)
                }
                .padding(.top, 30)
                .onChange(of: email) { invalid = false }
                .onChange(of: password) { invalid = false }

                Spacer(minLength: 24)

                VStack(spacing: 16) {
                    if invalid {
                        Text("Use \(Self.bypassEmail) / \(Self.bypassPassword) to continue.")
                            .font(.system(size: 13))
                            .foregroundStyle(GTXColor.sell)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button("Continue", action: attemptContinue)
                        .buttonStyle(GTXPrimaryButtonStyle())

                    orDivider

                    walletTile

                    legal
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 44)
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .enableInjection()
    }

    private var orDivider: some View {
        HStack(spacing: 12) {
            Rectangle().fill(GTXColor.border).frame(height: 1)
            Text("or").font(.system(size: 13)).foregroundStyle(GTXColor.faint)
            Rectangle().fill(GTXColor.border).frame(height: 1)
        }
    }

    private var walletTile: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 5)
                .fill(LinearGradient.gtxBrand)
                .frame(width: 18, height: 18)
            Text("Continue with wallet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(GTXColor.text)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(GTXColor.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(GTXColor.border, lineWidth: 1))
    }

    private var legal: some View {
        (Text("By continuing you agree to our ")
            + Text("Terms").foregroundColor(GTXColor.muted)
            + Text(" & ")
            + Text("Privacy Policy").foregroundColor(GTXColor.muted)
            + Text("."))
            .font(.system(size: 12.5))
            .foregroundStyle(GTXColor.faint)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    CreateAccountView()
}
