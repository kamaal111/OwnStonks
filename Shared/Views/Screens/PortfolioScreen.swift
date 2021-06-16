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
import StonksNetworker

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
        view()
            #if canImport(UIKit) // iOS and iPad
            .navigationBarTitle(Text(localized: .PORTFOLIO_SCREEN_TITLE), displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                showAddTransactionScreen = true
            }) {
                Image(systemName: "plus").size(.squared(20))
            })
            #else // macOS
            .navigationTitle(Text(localized: .PORTFOLIO_SCREEN_TITLE))
            .frame(minWidth: 305)
            #endif
            .onAppear(perform: {
                if #available(macOS 12.0, *) {
                    detach {
                        await readRoot()
                    }
                }
            })
    }

    @available(macOS 12.0, *)
    private func readRoot() async {
        let networker = StonksNetworker()
        let rootResult = await networker.getRoot()
        switch rootResult {
        case .failure(let error): print(error)
        case .success(let success):
            if let success = success {
                print("success", success)
            }
        }
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
                VStack {
                    PortfolioTotalsSection(total: totalString)
                    GeometryReader { (geometry: GeometryProxy) in
                        ScrollView {
                            PortfolioGridView(multiDimensionedData: portfolioRows, viewWidth: geometry.size.width)
                        }
                    }
                }
            }
        }
    }

    private var totalString: String {
        userData.moneyString(from: stonksManager.totalStonksPrice)
    }

    private var portfolioRows: [[StonkGridCellData]] {
        var multiDimensionedData: [[StonkGridCellData]] = []
        var counter = 0
        for portfolioItem in stonksManager.portfolioStonks {
            let row = [
                StonkGridCellData(id: counter, content: portfolioItem.name, transactionID: portfolioItem.id),
                StonkGridCellData(id: counter + 1, content: "\(portfolioItem.shares)", transactionID: portfolioItem.id),
                StonkGridCellData(
                    id: counter + 2,
                    content: userData.moneyString(from: portfolioItem.totalPrice),
                    transactionID: portfolioItem.id)
            ]
            multiDimensionedData.append(row)
            counter += row.count
        }
        return multiDimensionedData
    }
}

struct PortfolioScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Navigator())
            .environmentObject(StonksManager(preview: true))
    }
}
