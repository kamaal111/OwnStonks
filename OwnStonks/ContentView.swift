//
//  ContentView.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            Text("Hello there!")
        } detail: {
            Text("Select an item")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
