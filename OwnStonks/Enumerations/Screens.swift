//
//  Screens.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 03/01/2023.
//

import OSLocales
import Foundation
import BetterNavigation

enum Screens: Hashable, Codable, CaseIterable, NavigatorStackValue {
    case transactions
    case settings

    var title: String {
        switch self {
        case .transactions:
            return OSLocales.getText(.TRANSACTIONS)
        case .settings:
            return OSLocales.getText(.SETTINGS)
        }
    }

    var imageSystemName: String {
        switch self {
        case .transactions:
            return "list.bullet.clipboard.fill"
        case .settings:
            return "gearshape"
        }
    }

    var isSidebarItem: Bool {
        switch self {
        case .transactions, .settings:
            return true
        }
    }

    var isTabItem: Bool {
        switch self {
        case .transactions, .settings:
            return true
        }
    }

    static let root: Self = .transactions
}
