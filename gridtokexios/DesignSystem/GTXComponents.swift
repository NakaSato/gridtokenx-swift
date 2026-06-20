//
//  GTXComponents.swift
//  gridtokexios
//
//  Shared signup-flow atoms (back button, ambient glow, labeled field).
//

import SwiftUI

/// Rounded back chevron used on every secondary screen. Tagged for UI tests.
struct GTXBackButton: View {
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(GTXColor.violetSoft)
                .frame(width: 40, height: 40)
                .background(GTXColor.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(GTXColor.border, lineWidth: 1))
        }
        .accessibilityIdentifier("BackButton")
        .accessibilityLabel("Back")
    }
}

/// Ambient violet glow bleeding down from above the status bar.
struct GTXTopGlow: View {
    var body: some View {
        RadialGradient(
            colors: [Color(hex: "#8C5AFF", alpha: 0.40), Color(hex: "#8C5AFF", alpha: 0.10), .clear],
            center: .center, startRadius: 0, endRadius: 210
        )
        .frame(width: 520, height: 420)
        .blur(radius: 6)
        .offset(y: -160)
        .allowsHitTesting(false)
    }
}

/// Labeled input with focus ring matching the mock's field style.
struct GTXField<Trailing: View>: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool
    var secure: Bool = false
    var keyboard: UIKeyboardType = .default
    @ViewBuilder var trailing: () -> Trailing

    init(label: String, placeholder: String, text: Binding<String>, isFocused: Bool,
         secure: Bool = false, keyboard: UIKeyboardType = .default,
         @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isFocused = isFocused
        self.secure = secure
        self.keyboard = keyboard
        self.trailing = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.1)
                .foregroundStyle(GTXColor.muted)

            HStack(spacing: 10) {
                Group {
                    if secure {
                        SecureField("", text: $text, prompt: prompt)
                    } else {
                        TextField("", text: $text, prompt: prompt)
                    }
                }
                .font(.system(size: 16))
                .foregroundStyle(GTXColor.text)
                .tint(GTXColor.violet)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                trailing()
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(GTXColor.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isFocused ? GTXColor.violet : GTXColor.border, lineWidth: isFocused ? 1.5 : 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(GTXColor.violet.opacity(isFocused ? 0.16 : 0), lineWidth: 4)
            )
        }
    }

    private var prompt: Text {
        Text(placeholder).foregroundColor(GTXColor.faint)
    }
}
