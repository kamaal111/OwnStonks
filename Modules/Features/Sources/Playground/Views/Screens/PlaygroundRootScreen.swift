//
//  PlaygroundRootScreen.swift
//
//
//  Created by Kamaal M Farah on 17/12/2023.
//

import SwiftUI
import KamaalUI
import SharedUI
import KamaalNavigation

struct PlaygroundRootScreen: View {
    @EnvironmentObject private var navigator: Navigator<PlaygroundScreens>

    var body: some View {
        KScrollableForm {
            KSection(header: "Personalization") {
                PlaygroundNavigationButton(title: "App logo", destination: .appLogo)
            }
            .padding(.top, .medium)
            .padding(.horizontal, .medium)
            KSection(header: "Data", content: {
                PlaygroundNavigationButton(title: "Cloud database", destination: .cloudDatabase)
            })
            .padding(.horizontal, .medium)
        }
    }
}

#Preview {
    PlaygroundRootScreen()
}
