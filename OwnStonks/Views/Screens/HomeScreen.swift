//
//  HomeScreen.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI
import BetterNavigation

struct HomeScreen: View {
    @EnvironmentObject private var navigator: Navigator<Int>

    var body: some View {
        Button(action: { navigator.navigate(to: 1) }) {
            Text("Next screen")
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
