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

    var id: Screens { self }

    var isTabItem: Bool {
        switch self {
        case .transactions: true
        }
    }

    var isSidebarItem: Bool {
        switch self {
        case .transactions: true
        }
    }

    var imageSystemName: String {
        switch self {
        case .transactions: "house.fill"
        }
    }

    var title: String {
        switch self {
        case .transactions: NSLocalizedString("Transactions", bundle: .module, comment: "")
        }
    }

    static var root: Screens = .transactions
}
