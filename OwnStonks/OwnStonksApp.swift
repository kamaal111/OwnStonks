//
//  OwnStonksApp.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import SwiftUI
import SwiftData
import UserSettings
import Transactions
import PersistentData

@main
struct OwnStonksApp: App {
    @State private var userSettings = UserSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 300)
                .transactionEnvironment()
                .userSettingsEnvironment(userSettings: userSettings)
                .modelContainer(PersistentData.shared.dataContainer)
        }
        #if os(macOS)
        Settings {
            UserSettingsScreen()
                .userSettingsEnvironment(userSettings: userSettings)
        }
        #endif
    }
}
