//
//  ContentView.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import SwiftUI
import SwiftData
import Navigation

struct ContentView: View {
    var body: some View {
        AppNavigationView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
