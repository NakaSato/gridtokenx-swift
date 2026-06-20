//
//  TxReceiptAttributes.swift
//  gridtokexios
//
//  ActivityAttributes for the transaction-success Live Activity (token send /
//  receive). Shared between the app target and the EnergyIslandWidget extension.
//

import ActivityKit
import Foundation

struct TxReceiptAttributes: ActivityAttributes {
    typealias ContentState = TxReceipt

    var label: String = "Transaction"
}
