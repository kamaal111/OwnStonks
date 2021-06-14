//
//  WindowGroupScene.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 14/06/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI

struct WindowGroupScene: View {
    @StateObject private var navigator = Navigator()
    @StateObject private var stonksManager = StonksManager()
    @StateObject private var userData = UserData()

    private let persistenceController = PersistenceController.shared

    var body: some View {
        ContentView()
            .environment(\.managedObjectContext, persistenceController.container!.viewContext)
            .environmentObject(navigator)
            .environmentObject(stonksManager)
            .environmentObject(userData)
    }
}

struct WindowGroupScene_Previews: PreviewProvider {
    static var previews: some View {
        WindowGroupScene()
    }
}
