//
//  PlaygroundMainView.swift
//
//
//  Created by Kamaal M Farah on 17/12/2023.
//

import SwiftUI

struct PlaygroundMainView: View {
    let screen: PlaygroundScreens

    var body: some View {
        switch screen {
        case .root: PlaygroundRootScreen()
        case .appLogo: PlaygroundAppLogoScreen()
        case .cloudDatabase: PlaygroundCloudDatabaseScreen()
        }
    }
}

#Preview {
    PlaygroundMainView(screen: .root)
}
