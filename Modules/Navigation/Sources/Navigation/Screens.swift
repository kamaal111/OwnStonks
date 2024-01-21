//
//  Screens.swift
//
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import Foundation
import Transactions
import KamaalNavigation
#if DEBUG
import Playground
#endif

enum Screens: Hashable, Codable, Identifiable, CaseIterable, NavigatorStackValue {
    case performances
    case transactions
    case settings
    #if DEBUG
    case playground
    #endif

    var id: Screens { self }

    var isTabItem: Bool {
        switch self {
        case .transactions, .settings, .performances: true
        #if DEBUG
        case .playground: true
        #endif
        }
    }

    var isSidebarItem: Bool {
        switch self {
        case .transactions, .settings, .performances: true
        #if DEBUG
        case .playground: true
        #endif
        }
    }

    var imageSystemName: String {
        switch self {
        case .performances: "chart.pie.fill"
        case .transactions: "house.fill"
        case .settings: "gear"
        #if DEBUG
        case .playground: "theatermasks.fill"
        #endif
        }
    }

    var title: String {
        switch self {
        case .performances: NSLocalizedString("Performances", bundle: .module, comment: "")
        case .transactions: NSLocalizedString("Transactions", bundle: .module, comment: "")
        case .settings: NSLocalizedString("Settings", bundle: .module, comment: "")
        #if DEBUG
        case .playground: "Playground"
        #endif
        }
    }

    static var root: Screens = .performances
}
