//
//  Sidebar.swift
//
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import SwiftUI
import KamaalNavigation

struct Sidebar: View {
    var body: some View {
        List {
            Section(content: {
                ForEach(Screens.allCases.filter(\.isSidebarItem), id: \.self) { screen in
                    StackNavigationChangeStackButton(destination: screen) {
                        Label(screen.title, systemImage: screen.imageSystemName)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }, header: {
                Text("Scenes", bundle: .module)
            })
        }
        #if os(macOS)
        .frame(minWidth: 160)
        .toolbar(content: {
            Button(action: toggleSidebar) {
                Label(NSLocalizedString("Toggle Sidebar", bundle: .module, comment: ""), systemImage: "sidebar.left")
                    .foregroundColor(.accentColor)
            }
            .help(NSLocalizedString("Toggle Sidebar", bundle: .module, comment: ""))
        })
        #endif
    }

    #if os(macOS)
    private func toggleSidebar() {
        guard let firstResponder = NSApp.keyWindow?.firstResponder else { return }
        firstResponder.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    #endif
}

#Preview {
    Sidebar()
}
