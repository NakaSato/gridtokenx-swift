//
//  EnergyIslandWidgetBundle.swift
//  EnergyIslandWidget
//
//  Entry point for the widget extension. Hosts the energy-trade Live Activity.
//

import WidgetKit
import SwiftUI

@main
struct EnergyIslandWidgetBundle: WidgetBundle {
    var body: some Widget {
        EnergyIslandLiveActivity()
    }
}
