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

enum Screens: Int, Hashable, Codable, Identifiable, CaseIterable, NavigatorStackValue {
    case transactions = 0
    case performances = 1
    case settings = 2
    #if DEBUG
    case playground = 69
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
        case .transactions: "dollarsign"
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

    static var root: Screens = .transactions
}
