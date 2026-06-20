//
//  SuccessView.swift
//  gridtokexios
//
//  Screen 5 · Success. Native SwiftUI port of mock-ui screens.jsx.
//

import SwiftUI

struct SuccessView: View {
    var name: String = "Maya"
    var onEnter: () -> Void = {}

    @ObserveInjection var inject

    private struct Stat: Identifiable {
        let id = UUID()
        let value: String
        let label: String
    }
    private let stats = [
        Stat(value: "12.4", label: "kWh credits"),
        Stat(value: "0.0", label: "GTX balance"),
        Stat(value: "8", label: "sellers nearby"),
    ]

    var body: some View {
        ZStack(alignment: .top) {
            GTXColor.bg
                .overlay(alignment: .top) { GTXTopGlow() }
                .clipped()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                badge

                Text("You're all set")
                    .font(.system(size: 30, weight: .bold))
                    .tracking(-0.7)
                    .foregroundStyle(GTXColor.text)
                    .padding(.top, 34)

                Text("Welcome to GridTokenX, \(name). Your wallet is ready and the marketplace is live.")
                    .font(.system(size: 16.5))
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(GTXColor.muted)
                    .frame(maxWidth: 290)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 14)

                statRow
                    .padding(.top, 28)

                Spacer()

                Button("Enter GridTokenX", action: onEnter)
                    .buttonStyle(GTXPrimaryButtonStyle())
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 44)
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .enableInjection()
    }

    private var badge: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(LinearGradient.gtxBrand)
            .frame(width: 96, height: 96)
            .overlay(
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(.white)
            )
            .shadow(color: GTXColor.violetDeep.opacity(0.55), radius: 25, y: 16)
    }

    private var statRow: some View {
        HStack(spacing: 10) {
            ForEach(stats) { stat in
                VStack(alignment: .leading, spacing: 3) {
                    Text(stat.value)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(GTXColor.violetSoft)
                    Text(stat.label)
                        .font(.system(size: 11.5))
                        .foregroundStyle(GTXColor.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(GTXColor.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(GTXColor.border, lineWidth: 1))
            }
        }
    }
}

#Preview {
    SuccessView()
}
