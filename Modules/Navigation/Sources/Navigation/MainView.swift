//
//  MainView.swift
//
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import SwiftUI
import KamaalUI
import KamaalPopUp
import Performances
import UserSettings
import Transactions
import KamaalNavigation
#if DEBUG
import Playground
#endif

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
            case .transactions: TransactionsScreen()
            case .settings: UserSettingsScreen()
            case .performances: PerformancesScreen()
            #if DEBUG
            case .playground: PlaygroundScreen()
            #endif
            }
        }
        .ktakeSizeEagerly()
        .navigationTitle(title: screen.title, displayMode: displayMode)
        .withKPopUp(popperUpManager)
    }
}

#Preview {
    MainView(screen: .transactions)
}
