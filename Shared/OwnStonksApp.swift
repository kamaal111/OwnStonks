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
    @StateObject private var navigator = Navigator()
    @StateObject private var stonksManager = StonksManager()

    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container!.viewContext)
                .environmentObject(navigator)
                .environmentObject(stonksManager)
        }
    }
}
