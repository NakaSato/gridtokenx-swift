//
//  TxReceiptIsland.swift
//  gridtokexios
//
//  Transaction-success model — token send & receive receipt. Doubles as the
//  Live Activity `ContentState`. Shared between the app target (drives it via
//  TxLiveActivityManager) and the EnergyIslandWidget extension. The SwiftUI
//  presentations live in TxReceiptViews.swift.
//

import SwiftUI

struct TxReceipt: Codable, Hashable {
    enum Mode: String, Codable { case send, receive }

    var mode: Mode = .send
    var amountGTX: Double = 25.0
    var fiatText: String = "≈ ฿108.00"
    var counterparty: String = "Somchai"
    var handle: String = "@somchai_p"
    var txHash: String = "0x7a3f…c2e1"

    var sending: Bool { mode == .send }
    /// Amount tint — violet for outgoing, green for incoming.
    var accent: Color { sending ? .islandVioletSoft : .islandUp }
    var title: String { sending ? "Sent successfully" : "Received" }
    var who: String { (sending ? "To " : "From ") + counterparty + " · " + handle }
    var amountText: String { (sending ? "−" : "+") + String(format: "%.2f", amountGTX) }
    var compactAmount: String {
        (sending ? "−" : "+") + String(format: "%.0f", amountGTX) + " GTX"
    }
}
