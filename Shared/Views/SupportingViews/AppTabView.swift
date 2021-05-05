//
//  AppTabView.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI

struct AppTabView: View {
    @EnvironmentObject
    private var navigator: Navigator

    var body: some View {
        TabView(selection: $navigator.tabSelection) {
            ForEach(Navigator.screens, id: \.self) { (screen: ScreenModel) in
                NavigationView { screen.view }
                    .tabItem({
                        Image(systemName: screen.imageSystemName)
                        Text(screen.name)
                    })
                    .tag(screen.tag)
            }
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
            .environmentObject(Navigator())
    }
}
