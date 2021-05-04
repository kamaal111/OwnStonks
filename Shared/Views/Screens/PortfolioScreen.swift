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
            .navigationBarItems(trailing: Button(action: navigator.navigateToAddTransactionScreen) {
                Image(systemName: "plus").size(.squared(20))
            })
        #else
        view()
            .navigationTitle(Text("Portfolio"))
            .toolbar(content: {
                Button(action: navigator.navigateToAddTransactionScreen) {
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
            if stonksManager.portfolioStonks.isEmpty {
                Button(action: navigator.navigateToAddTransactionScreen) {
                    Text("Add your first transaction")
                        .font(.headline)
                }
            } else {
                GeometryReader { (geometry: GeometryProxy) in
                    ScrollView {
                        PortfolioGridView(data: stonksManager.portfolioStonks, viewWidth: geometry.size.width)
                    }
                }
            }
        }
    }
}

struct PortfolioScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Navigator())
            .environmentObject(StonksManager())
    }
}
