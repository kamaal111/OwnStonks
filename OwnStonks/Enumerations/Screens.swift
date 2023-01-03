//
//  Screens.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 03/01/2023.
//

import OSLocales
import Foundation

enum Screens: Hashable, Codable, CaseIterable {
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

    var shouldBeOnSidebar: Bool {
        switch self {
        case .transactions, .settings:
            return true
        }
    }
}
