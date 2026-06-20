//
//  EnergyTradeAttributes.swift
//  Shared between gridtokexios (app) and EnergyIslandWidget (extension).
//
//  ActivityKit attributes for the energy-trade Live Activity. The dynamic part
//  (`ContentState`) is the EnergyTrade itself, so the island/banner views bind
//  straight to context.state.
//

import ActivityKit
import Foundation

struct EnergyTradeAttributes: ActivityAttributes {
    typealias ContentState = EnergyTrade   // EnergyTrade is Codable + Hashable

    /// Static for the life of the activity.
    var sessionName: String = "Energy trade"
}
