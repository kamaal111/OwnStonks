//
//  ScreenDecider.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 03/01/2023.
//

import SwiftUI

struct ScreenDecider: View {
    let screen: Screens

    var body: some View {
        switch screen {
        case .transactions:
            TransactionsScreen()
        case .settings:
            Text("Settings")
        }
    }
}

struct ScreenDecider_Previews: PreviewProvider {
    static var previews: some View {
        ScreenDecider(screen: .transactions)
    }
}
