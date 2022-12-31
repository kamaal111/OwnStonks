//
//  StackNavigationLink.swift
//  
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI

public struct StackNavigationLink<Content: View, NextView: View, Destination: Codable & Hashable>: View {
    @EnvironmentObject private var navigator: Navigator<Destination>

    let destination: Destination
    let nextView: (Destination) -> NextView
    let content: () -> Content

    public init(
        destination: Destination,
        @ViewBuilder nextView: @escaping (Destination) -> NextView,
        @ViewBuilder content: @escaping () -> Content) {
            self.destination = destination
            self.nextView = nextView
            self.content = content
        }

    public var body: some View {
        #if os(macOS)
        Button(action: { navigator.navigate(to: destination) }) {
            content()
        }
        #else
        NavigationLink(destination: { nextView(destination) }) {
            content()
        }
        #endif
    }
}

struct StackNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        StackNavigationLink(destination: 2, nextView: { screen in Text("\(screen)") }) {
            Text("Link")
        }
    }
}
