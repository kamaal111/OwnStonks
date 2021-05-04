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
    @EnvironmentObject
    private var navigator: Navigator
    @EnvironmentObject
    private var stonksManager: StonksManager

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
            NavigationLink(destination: AddTransactionScreen(), isActive: $navigator.showAddTransactionScreen) {
                EmptyView()
            }
            #endif
            Color.StonkBackground
            GeometryReader { (geometry: GeometryProxy) in
                ScrollView {
                    PortfolioGridView(data: stonksManager.portfolioStonks, viewWidth: geometry.size.width)
                }
            }
        }
    }

    private func addTransaction() {
        navigator.navigateToAddTransactionScreen()
    }
}

struct PortfolioScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Navigator())
            .environmentObject(StonksManager())
    }
}
