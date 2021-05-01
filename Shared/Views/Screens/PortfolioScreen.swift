//
//  PortfolioScreen.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//

import SwiftUI

struct PortfolioScreen: View {
    var body: some View {
        #if canImport(UIKit)
        view()
            .navigationBarTitle(Text("Portfolio"), displayMode: .large)
        #else
        view()
        #endif
    }

    func view() -> some View {
        GeometryReader { (geometry: GeometryProxy) in
            ScrollView {
                PortfolioGridView(data: (0..<100)
                                    .map({
                                        StonksData(
                                            name: "Share \($0 + 1)",
                                            shares: (0..<100).randomElement()!,
                                            currentPrice: Double((0..<100).randomElement()!))
                                    }), viewWidth: geometry.size.width)
            }
        }
    }
}

struct PortfolioScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Navigator())
    }
}
