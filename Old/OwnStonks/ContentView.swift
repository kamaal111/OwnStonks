//
//  ContentView.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI
import PopperUp
import BetterNavigation

struct ContentView: View {
    @StateObject private var popperUpManager = PopperUpManager()

    var body: some View {
        NavigationStackView(
            stack: [] as [Screens],
            root: { screen in MainView(screen: screen) },
            subView: { screen in MainView(screen: screen, displayMode: .inline) },
            sidebar: { Sidebar() }
        )
        .withEditMode()
        .withPopperUp(popperUpManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}