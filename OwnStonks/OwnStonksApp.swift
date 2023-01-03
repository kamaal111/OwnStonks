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
    @StateObject private var exchangeRateManager = ExchangeRateManager()
    @StateObject private var userData = UserData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 300)
                .environmentObject(transactionsManager)
                .environmentObject(exchangeRateManager)
                .environmentObject(userData)
        }
    }
}
