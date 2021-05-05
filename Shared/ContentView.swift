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
