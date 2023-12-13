//
//  Screens.swift
//
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import Foundation
import Transactions
import KamaalNavigation

enum Screens: Hashable, Codable, Identifiable, CaseIterable, NavigatorStackValue {
    case transactions
    case settings

    var id: Screens { self }

    var isTabItem: Bool {
        switch self {
        case .transactions, .settings: true
        }
    }

    var isSidebarItem: Bool {
        switch self {
        case .transactions, .settings: true
        }
    }

    var imageSystemName: String {
        switch self {
        case .transactions: "house.fill"
        case .settings: "gear"
        }
    }

    var title: String {
        switch self {
        case .transactions: NSLocalizedString("Transactions", bundle: .module, comment: "")
        case .settings: NSLocalizedString("Settings", bundle: .module, comment: "")
        }
    }

    static var root: Screens = .transactions
}
