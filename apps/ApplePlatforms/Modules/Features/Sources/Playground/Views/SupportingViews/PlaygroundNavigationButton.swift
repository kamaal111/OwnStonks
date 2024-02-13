//
//  PlaygroundNavigationButton.swift
//
//
//  Created by Kamaal M Farah on 17/12/2023.
//

#if DEBUG
import SwiftUI
import KamaalUI
import KamaalNavigation

struct PlaygroundNavigationButton: View {
    let title: String
    let destination: PlaygroundScreens

    var body: some View {
        StackNavigationLink(destination: destination, nextView: { screen in PlaygroundMainView(screen: screen) }) {
            HStack {
                Text(title)
                    .foregroundColor(.accentColor)
                Spacer()
                #if os(macOS)
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                #endif
            }
            .kInvisibleFill()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlaygroundNavigationButton(title: "Titler", destination: .appLogo)
}
#endif
