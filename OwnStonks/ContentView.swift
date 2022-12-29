//
//  ContentView.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI
import BetterNavigation

struct ContentView: View {
    @State private var stack: [Int] = []

    var body: some View {
        NavigationView {
            if shouldHaveASidebar {
                List {
                    Text("Sidbar")
                }
            }
            NavigationStackView(
                stack: stack,
                root: { HomeScreen() },
                subView: { screen in SubViewScreen(screen: screen) })
        }
        .navigationStyle(shouldHaveASidebar ? .columns : .stack)
    }

    private var shouldHaveASidebar: Bool {
        #if os(macOS)
        return true
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return false
        #endif
    }
}

extension NavigationView {
    func navigationStyle(_ style: Style) -> some View {
        #if os(macOS)
        self
        #else
        ZStack {
            switch style {
            case .columns:
                self
                    .navigationViewStyle(.columns)
            case .stack:
                self
                    .navigationViewStyle(.stack)
            }
        }
        #endif
    }

    enum Style {
        case columns
        case stack
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
