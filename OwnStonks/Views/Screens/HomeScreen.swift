//
//  HomeScreen.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI
import SalmonUI
import OSLocales
import BetterNavigation

struct HomeScreen: View {
    @State private var showAddSymbolSheet = false

    var body: some View {
        VStack {
            StackNavigationLink(destination: 1, nextView: { screen in SubViewScreen(screen: screen) }) {
                Text("Next screen")
            }
        }
        .toolbar(content: { toolbarView })
        .sheet(isPresented: $showAddSymbolSheet, content: { AddSymbolSheet() })
    }

    private var toolbarView: some View {
        Button(action: { showAddSymbolSheet = true }) {
            Image(systemName: "plus")
                .foregroundColor(.accentColor)
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
