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
        #if canImport(UIKit)
        view()
        #else
        view()
            .toolbar(content: {
                Button(action: toggleSidebar) {
                    Label("Toggle Sidebar", systemImage: "sidebar.left")
                }
            })
        #endif
    }

    private func view() -> some View {
        List {
            Section(header: Text("Screens")) {
                ForEach(Navigator.screens, id: \.self) { (screen: ScreenModel) in
                    NavigationLink(
                        destination: screen.view,
                        tag: screen.tag,
                        selection: $navigator.screenSelection) {
                        Label(screen.name, systemImage: screen.imageSystemName)
                    }
                }
                #if canImport(AppKit)
                NavigationLink(
                    destination: AddTransactionScreen(),
                    tag: Navigator.ScreenNames.addTransaction.rawValue,
                    selection: $navigator.screenSelection) {
                    Label("Add Transaction", systemImage: "plus")
                }
                #endif
            }
        }
    }

    #if os(macOS)
    private func toggleSidebar() {
        guard let firstResponder = NSApp.keyWindow?.firstResponder else { return }
        firstResponder.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    #endif
}

struct AppSidebar_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebar()
    }
}
