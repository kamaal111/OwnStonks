//
//  AppTabView.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//

import SwiftUI

struct AppTabView: View {
    @State private var tabSelection = Navigator.screens.first?.tag ?? 0

    var body: some View {
        TabView(selection: $tabSelection) {
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
    }
}
