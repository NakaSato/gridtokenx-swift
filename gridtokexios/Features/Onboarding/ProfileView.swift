//
//  ProfileView.swift
//  gridtokexios
//
//  Screen 4 · Profile + role. Native SwiftUI port of mock-ui screens.jsx.
//

import SwiftUI

struct ProfileView: View {
    var onBack: () -> Void = {}
    var onContinue: (_ name: String, _ role: TradingRole) -> Void = { _, _ in }

    enum TradingRole: CaseIterable {
        case sell, buy
        var title: String { self == .sell ? "Sell energy" : "Buy energy" }
        var desc: String {
            self == .sell ? "I produce solar or wind I want to trade."
                          : "I want to source clean power locally."
        }
        /// Mock rotates the chip 45° for the "sell" role.
        var chipRotation: Angle { self == .sell ? .degrees(45) : .zero }
    }

    @ObserveInjection var inject

    @State private var name = "Maya Chen"
    @State private var role: TradingRole = .sell
    @FocusState private var nameFocused: Bool

    private var canContinue: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack(alignment: .top) {
            GTXColor.bg
                .overlay(alignment: .top) { GTXTopGlow() }
                .clipped()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                GTXBackButton(action: onBack)

                Text("Tell us about you")
                    .font(.system(size: 28, weight: .bold))
                    .tracking(-0.6)
                    .foregroundStyle(GTXColor.text)
                    .padding(.top, 26)
                    .padding(.bottom, 8)

                Text("This sets up your trading profile.")
                    .font(.system(size: 15.5))
                    .foregroundStyle(GTXColor.muted)

                GTXField(label: "DISPLAY NAME", placeholder: "Your name", text: $name,
                         isFocused: nameFocused)
                    .focused($nameFocused)
                    .padding(.top, 26)

                Text("HOW WILL YOU USE GRIDTOKENX?")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(0.1)
                    .foregroundStyle(GTXColor.muted)
                    .padding(.top, 26)
                    .padding(.bottom, 12)

                VStack(spacing: 12) {
                    ForEach(TradingRole.allCases, id: \.self) { r in
                        RoleCard(role: r, selected: role == r) { role = r }
                    }
                }

                Spacer(minLength: 24)

                Button("Continue") { onContinue(name, role) }
                    .buttonStyle(GTXPrimaryButtonStyle())
                    .opacity(canContinue ? 1 : 0.5)
                    .disabled(!canContinue)
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
}

// MARK: - Role card

private struct RoleCard: View {
    let role: ProfileView.TradingRole
    let selected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 13) {
                // Leading chip — gradient when selected.
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(selected ? AnyShapeStyle(LinearGradient.gtxBrand)
                                       : AnyShapeStyle(Color.white.opacity(0.06)))
                        .frame(width: 38, height: 38)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.white)
                        .frame(width: 12, height: 12)
                        .rotationEffect(role.chipRotation)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(role.title)
                        .font(.system(size: 16.5, weight: .semibold))
                        .tracking(-0.2)
                        .foregroundStyle(GTXColor.text)
                    Text(role.desc)
                        .font(.system(size: 13.5))
                        .foregroundStyle(GTXColor.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                // Trailing radio/check.
                ZStack {
                    Circle()
                        .fill(selected ? GTXColor.violet : .clear)
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(selected ? GTXColor.violet : GTXColor.faint, lineWidth: 1.5))
                    if selected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                (selected ? GTXColor.violet.opacity(0.12) : GTXColor.surface),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? GTXColor.violet : GTXColor.border, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileView()
}
