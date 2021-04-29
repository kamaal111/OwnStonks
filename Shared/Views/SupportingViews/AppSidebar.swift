//
//  AppSidebar.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//

import SwiftUI

struct AppSidebar: View {
    @EnvironmentObject
    private var navigator: Navigator

    var body: some View {
        List {
            Section(header: Text("Screens")) {
                ForEach(Navigator.screens, id: \.self) { (screen: ScreenModel) in
                    NavigationLink(destination: screen.view,
                                   tag: screen.tag,
                                   selection: $navigator.screenSelection) {
                        Label(screen.name, systemImage: screen.imageSystemName)
                    }
                }
            }
        }
    }
}

struct AppSidebar_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebar()
    }
}
