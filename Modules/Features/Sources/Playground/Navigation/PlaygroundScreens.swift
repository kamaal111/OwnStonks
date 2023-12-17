//
//  PlaygroundScreens.swift
//
//
//  Created by Kamaal M Farah on 17/12/2023.
//

import KamaalNavigation

enum PlaygroundScreens: NavigatorStackValue {
    case root
    case appLogo

    var isTabItem: Bool { false }

    var imageSystemName: String { "questionmark" }

    var title: String {
        switch self {
        case .root: "Playground"
        case .appLogo: "App logo"
        }
    }
}
