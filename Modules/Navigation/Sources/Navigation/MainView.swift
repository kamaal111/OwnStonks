//
//  MainView.swift
//
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import SwiftUI
import KamaalUI
import KamaalPopUp
import KamaalNavigation

struct MainView: View {
    @StateObject private var popperUpManager = KPopUpManager(config: .init())

    let screen: Screens
    let displayMode: DisplayMode

    init(screen: Screens, displayMode: DisplayMode? = nil) {
        self.screen = screen
        self.displayMode = displayMode ?? (screen.isSidebarItem && screen.isTabItem ? .large : .inline)
    }

    var body: some View {
        KJustStack {
            switch screen {
            case .home: Text("Home")
            }
        }
        .ktakeSizeEagerly()
        .navigationTitle(title: screen.title, displayMode: displayMode)
        .withKPopUp(popperUpManager)
    }
}

#Preview {
    MainView(screen: .home)
}
