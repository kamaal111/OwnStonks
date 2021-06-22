//
//  ContentView.swift
//  Shared
//
//  Created by Kamaal M Farah on 28/04/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        #if canImport(UIKit)
        IOSContentView()
        #else
        MacContentView()
        #endif
    }
}

#if canImport(UIKit)
struct IOSContentView: View {
    #if DEBUG
    @State private var showDebugSheet = false
    #endif

    var body: some View {
        ZStack {
            if UIDevice.current.isIpad {
                NavigationView {
                    AppSidebar()
                    PortfolioScreen()
                }
            } else {
                AppTabView()
            }
        }
        #if DEBUG
        .onShake(perform: {
            showDebugSheet = true
        })
        .confirmationDialog(Text("Playground"), isPresented: $showDebugSheet, actions: {
            Button("First") { }
            Button("Second") { }
            Button("Third") { }
        })
        #endif
    }
}
#else
struct MacContentView: View {
    var body: some View {
        NavigationView {
            AppSidebar()
            PortfolioScreen()
        }
    }
}
#endif

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
