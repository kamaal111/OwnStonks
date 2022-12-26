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
        Button(action: { navigator.navigate(to: screen + 1) }) {
            Text("Navigate to \(screen + 1)")
        }
    }
}

struct SubViewScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubViewScreen(screen: 1)
    }
}
