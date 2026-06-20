//
//  gridtokexiosApp.swift
//  gridtokexios
//
//  Created by Chanthawat Kiriyadee on 20/6/2569 BE.
//

import SwiftUI

@main
struct gridtokexiosApp: App {
    init() {
        #if DEBUG
        // Connect to InjectionIII for hot reload (no-op if the app isn't running).
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
