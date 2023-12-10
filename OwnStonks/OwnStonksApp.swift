//
//  OwnStonksApp.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import SwiftUI
import Transactions
import PersistentData

@main
struct OwnStonksApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 300)
                .transactionEnvironment()
                .modelContainer(PersistentData.shared.dataContainer)
        }
    }
}
