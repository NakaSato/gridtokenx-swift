//
//  ReceiptExpandedView.swift
//  gridtokexios
//
//  In-app render of the `DI · Expanded (sent success / received)` artboard —
//  the transaction-receipt card on the design canvas. Reuses the shared
//  notification component `TxIslandExpanded` (from TxReceiptViews.swift).
//

import SwiftUI

struct ReceiptExpandedView: View {
    var tx: TxReceipt = TxReceipt()
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    private var label: String { tx.sending ? "EXPANDED · sent success" : "EXPANDED · received" }

    var body: some View {
        ZStack {
            Color(hex: "#15101F").ignoresSafeArea()

            VStack(spacing: 9) {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(0.4)
                    .foregroundStyle(Color(hex: "#F4F1FA", alpha: 0.5))

                TxIslandExpanded(tx: tx)
                    .padding(EdgeInsets(top: 15, leading: 18, bottom: 16, trailing: 18))
                    .frame(width: 360)
                    .background(.black, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
                    .shadow(color: .black.opacity(0.6), radius: 25, y: 18)
            }
        }
        .overlay(alignment: .topLeading) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.06), in: Circle())
            }
            .padding(.horizontal, 16)
            .accessibilityLabel("Back")
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .enableInjection()
    }
}

#Preview {
    ReceiptExpandedView(tx: TxReceipt(mode: .send))
}
