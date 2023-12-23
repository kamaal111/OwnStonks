//
//  OwnStonksApp.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import SwiftUI
import UserSettings
import Transactions
import ValutaConversion

@main
struct OwnStonksApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #else
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #endif

    @State private var userSettings = UserSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 300)
                .transactionEnvironment()
                .userSettingsEnvironment(userSettings: userSettings)
                .valutaConversionEnvironment()
        }
        #if os(macOS)
        Settings {
            UserSettingsScreen()
                .userSettingsEnvironment(userSettings: userSettings)
        }
        #endif
    }
}
