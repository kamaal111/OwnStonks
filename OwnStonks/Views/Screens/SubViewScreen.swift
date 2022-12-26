//
//  SubViewScreen.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI
import BetterNavigation

struct SubViewScreen: View {
    @EnvironmentObject private var navigator: Navigator<Int>

    let screen: Int

    var body: some View {
        VStack {
            StackNavigationLink(destination: screen + 1, nextView: { screen in SubViewScreen(screen: screen) }) {
                Text("Navigate to \(screen + 1)")
            }
            StackNavigationBackButton(screenType: Int.self) {
                Text("Go back")
            }
        }
    }
}

struct SubViewScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubViewScreen(screen: 1)
    }
}
