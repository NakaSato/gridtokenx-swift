//
//  TxReceiptViews.swift
//  gridtokexios
//
//  Transaction-success notification components — compact (check disc + signed
//  amount) and expanded (receipt row + on-chain settle line). Ported from
//  mock-ui/energy-island.jsx (TxIslandCompact / TxIslandSuccess). Reused by the
//  widget's ActivityConfiguration + DynamicIsland { } regions and by in-app
//  receipt screens.
//

import SwiftUI

// MARK: - Pieces

/// Green success disc with a check mark. Mirrors the mock `CheckDisc`
/// (fill = color @ ~13%, 1.5pt ring, check ≈ 0.55× the disc).
struct CheckDisc: View {
    var size: CGFloat = 44
    var color: Color = .islandUp

    var body: some View {
        Circle()
            .fill(color.opacity(0.13))
            .overlay(Circle().stroke(color, lineWidth: 1.5))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.46, weight: .bold))
                    .foregroundStyle(color)
            )
    }
}

/// Success disc with a small directional badge — paper-plane for send (violet),
/// tray-down for receive (green) — matching the mock's `DP.send`/`DP.receive`.
struct TxBadgeDisc: View {
    let tx: TxReceipt
    var size: CGFloat = 44

    var body: some View {
        CheckDisc(size: size, color: .islandUp)
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(tx.sending ? Color.islandViolet : Color.islandUp)
                    .frame(width: size * 0.45, height: size * 0.45)
                    .overlay(Circle().stroke(.black, lineWidth: 2.5))
                    .overlay(
                        Image(systemName: tx.sending ? "paperplane.fill" : "tray.and.arrow.down.fill")
                            .font(.system(size: size * 0.2, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .offset(x: 3, y: 3)
            }
    }
}

// MARK: - Compact (Dynamic Island leading / trailing)

struct TxIslandCompactLeading: View {
    let tx: TxReceipt
    var body: some View {
        CheckDisc(size: 22, color: .islandUp)
    }
}

struct TxIslandCompactTrailing: View {
    let tx: TxReceipt
    var body: some View {
        Text(tx.compactAmount)
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .foregroundStyle(.white)
    }
}

// MARK: - Expanded (lock screen banner + island expanded + in-app receipt)

struct TxIslandExpanded: View {
    let tx: TxReceipt

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 13) {
                TxBadgeDisc(tx: tx, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(tx.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    Text(tx.who)
                        .font(.system(size: 12.5))
                        .foregroundStyle(Color.islandMuted)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(tx.amountText)
                        .font(.system(size: 17, weight: .heavy, design: .monospaced))
                        .foregroundStyle(tx.accent)
                    Text(tx.fiatText)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.islandFaint)
                }
            }
            .padding(.bottom, 13)

            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)

            // settle line
            HStack(spacing: 8) {
                Circle().fill(Color.islandUp).frame(width: 6, height: 6)
                Text("Settled on-chain")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.islandMuted)
                Spacer()
                Text(tx.txHash)
                    .font(.system(size: 11.5, design: .monospaced))
                    .foregroundStyle(Color.islandFaint)
            }
            .padding(.top, 12)
        }
    }
}

#Preview {
    ZStack { Color.black; TxIslandExpanded(tx: TxReceipt()).padding() }
}
