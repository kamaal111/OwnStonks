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
            OSLocales.getText(.TRANSACTIONS)
        case .settings:
            OSLocales.getText(.SETTINGS)
        }
    }

    var imageSystemName: String {
        switch self {
        case .transactions:
            "list.bullet.clipboard.fill"
        case .settings:
            "gearshape"
        }
    }

    var isSidebarItem: Bool {
        switch self {
        case .transactions, .settings:
            true
        }
    }

    var isTabItem: Bool {
        switch self {
        case .transactions, .settings:
            true
        }
    }

    static let root: Self = .transactions
}
