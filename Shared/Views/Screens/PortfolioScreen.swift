//
//  PortfolioScreen.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI
import SalmonUI
import StonksUI
import StonksLocale
import ShrimpExtensions

struct PortfolioScreen: View {
    #if canImport(AppKit)
    @EnvironmentObject
    private var navigator: Navigator
    #endif
    @EnvironmentObject
    private var stonksManager: StonksManager
    @EnvironmentObject
    private var userData: UserData

    @State private var showAddTransactionScreen = false

    var body: some View {
        #if canImport(UIKit)
        view()
            .navigationBarTitle(Text(localized: .PORTFOLIO_SCREEN_TITLE), displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                showAddTransactionScreen = true
            }) {
                Image(systemName: "plus").size(.squared(20))
            })
        #else
        view()
            .navigationTitle(Text(localized: .PORTFOLIO_SCREEN_TITLE))
            .toolbar(content: {
                Button(action: { navigator.navigate(to: .addTransaction) }) {
                    Label(StonksLocale.Keys.ADD_TRANSACTION_LABEL.localized, systemImage: "plus")
                }
            })
            .frame(minWidth: 305)
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
            if stonksManager.portfolioStonks.isEmpty {
                Button(action: {
                    #if canImport(UIKit)
                    showAddTransactionScreen = true
                    #else
                    navigator.navigate(to: .addTransaction)
                    #endif
                }) {
                    Text(localized: .ADD_FIRST_TRANSACTION_Label)
                        .font(.headline)
                }
            } else {
                GeometryReader { (geometry: GeometryProxy) in
                    ScrollView {
                        PortfolioGridView(multiDimensionedData: portfolioRows, viewWidth: geometry.size.width)
                    }
                }
            }
        }
    }

    private var portfolioRows: [[StonkGridCellData]] {
        var multiDimensionedData: [[StonkGridCellData]] = []
        var counter = 0
        for portfolioItems in stonksManager.portfolioStonks {
            let row = [
                StonkGridCellData(id: counter, content: portfolioItems.name),
                StonkGridCellData(id: counter + 1, content: "\(portfolioItems.shares)"),
                StonkGridCellData(
                    id: counter + 2,
                    content: "\(userData.currency)\(portfolioItems.totalPrice.toFixed(2))")
            ]
            multiDimensionedData.append(row)
            counter += 3
        }
        return multiDimensionedData
    }
}

struct PortfolioScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Navigator())
            .environmentObject(StonksManager())
    }
}
