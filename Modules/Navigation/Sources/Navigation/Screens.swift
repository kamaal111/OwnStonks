//
//  Screens.swift
//
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import Foundation
import KamaalNavigation

enum Screens: Hashable, Codable, Identifiable, CaseIterable, NavigatorStackValue {
    case home

    var id: Screens { self }

    var isTabItem: Bool {
        switch self {
        case .home: true
        }
    }

    var isSidebarItem: Bool {
        switch self {
        case .home: true
        }
    }

    var imageSystemName: String {
        switch self {
        case .home: "house.fill"
        }
    }

    var title: String {
        switch self {
        case .home: "Home"
        }
    }

    static var root: Screens = .home
}
