//
//  OwnStonksApp.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI

@main
struct OwnStonksApp: App {
    @StateObject private var transactionsManager = TransactionsManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 300)
                .environmentObject(transactionsManager)
        }
    }
}
