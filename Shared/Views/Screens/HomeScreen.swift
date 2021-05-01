//
//  HomeScreen.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        #if canImport(UIKit)
        view()
            .navigationBarTitle(Text("Home"), displayMode: .large)
        #else
        view()
        #endif
    }

    func view() -> some View {
        ScrollView {
            GeometryReader { (geometry: GeometryProxy) in
                HomeGridView(viewWidth: geometry.size.width)
            }
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Navigator())
    }
}
