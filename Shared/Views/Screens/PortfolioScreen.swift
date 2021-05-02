//
//  PortfolioScreen.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//

import SwiftUI
import SalmonUI
import StonksUI

struct PortfolioScreen: View {
    #if canImport(AppKit)
    @EnvironmentObject
    private var navigator: Navigator
    #else
    @State private var showAddTransactionScreen = false
    #endif

    var body: some View {
        #if canImport(UIKit)
        view()
            .navigationBarTitle(Text("Portfolio"), displayMode: .large)
            .navigationBarItems(trailing: Button(action: addTransaction) { Image(systemName: "plus").size(.squared(20)) } )
        #else
        view()
            .toolbar(content: {
                Button(action: addTransaction) {
                    Label("Add transaction", systemImage: "plus")
                }
            })
            .frame(minWidth: Constants.minimumContentWidth)
        #endif
    }

    private func view() -> some View {
        ZStack {
            #if canImport(UIKit)
            NavigationLink(destination: AddTransactionScreen(), isActive: $showAddTransactionScreen) {
                EmptyView()
            }
            #endif
            Color.StonkBackground
            GeometryReader { (geometry: GeometryProxy) in
                ScrollView {
                    PortfolioGridView(data: (0..<10)
                                        .map({
                                            StonksData(
                                                name: "Share \($0 + 1)",
                                                shares: Double((0..<100).randomElement()!),
                                                currentPrice: Double((0..<100).randomElement()!))
                                        }), viewWidth: geometry.size.width)
                }
            }
        }
    }

    private func addTransaction() {
        #if canImport(UIKit)
        showAddTransactionScreen = true
        #else
        navigator.navigateToAddTransactionScreen()
        #endif
    }
}

struct PortfolioScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Navigator())
    }
}
