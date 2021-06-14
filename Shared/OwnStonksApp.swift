//
//  OwnStonksApp.swift
//  Shared
//
//  Created by Kamaal M Farah on 28/04/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI

@main
struct OwnStonksApp: App {
    var body: some Scene {
        WindowGroup {
            WindowGroupScene()
        }
        #if os(macOS)
        Settings {
            SettingsScene()
        }
        #endif
    }
}
