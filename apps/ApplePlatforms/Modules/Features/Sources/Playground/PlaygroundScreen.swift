//
//  PlaygroundScreen.swift
//
//
//  Created by Kamaal M Farah on 17/12/2023.
//

#if DEBUG
import SwiftUI
import KamaalNavigation

public struct PlaygroundScreen: View {
    public init() { }

    public var body: some View {
        NavigationStackView(
            stackWithoutNavigationStack: [PlaygroundScreens](),
            root: { screen in PlaygroundMainView(screen: screen) },
            subView: { screen in PlaygroundMainView(screen: screen) }
        )
    }
}
#endif
