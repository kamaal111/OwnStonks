//
//  AppNavigationView.swift
//
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import SwiftUI
import KamaalNavigation

public struct AppNavigationView: View {
    public init() { }

    public var body: some View {
        NavigationStackView(
            stack: [Screens](),
            root: { screen in MainView(screen: screen) },
            subView: { screen in MainView(screen: screen, displayMode: .inline) },
            sidebar: { Sidebar() }
        )
    }
}

#Preview {
    AppNavigationView()
}
