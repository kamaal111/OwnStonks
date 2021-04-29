//
//  OwnStonksApp.swift
//  Shared
//
//  Created by Kamaal M Farah on 28/04/2021.
//

import SwiftUI

@main
struct OwnStonksApp: App {
    @StateObject private var navigator = Navigator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigator)
        }
    }
}
