//
//  TransactionsScreen.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 04/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI
import StonksUI
import StonksLocale

struct TransactionsScreen: View {
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
            .navigationBarTitle(Text(localized: .TRANSACTIONS_SCREEN_TITLE))
            .navigationBarItems(trailing: Button(action: {
                showAddTransactionScreen = true
            }) {
                Image(systemName: "plus").size(.squared(20))
            })
        #else
        view()
            .navigationTitle(Text(localized: .TRANSACTIONS_SCREEN_TITLE))
            .toolbar(content: {
                Button(action: { navigator.navigate(to: .addTransaction) }) {
                    Label(StonksLocale.Keys.ADD_TRANSACTION_LABEL.localized, systemImage: "plus")
                }
            })
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
                        TransactionsGridView(multiDimensionedData: transactionRows, viewWidth: geometry.size.width)
                    }
                }
            }
        }
    }

    private var transactionRows: [[StonkGridCellData]] {
        var multiDimensionedData: [[StonkGridCellData]] = []
        var counter = 0
        for transaction in stonksManager.transactions {
            let row = [
                StonkGridCellData(id: counter, content: transaction.name),
                StonkGridCellData(id: counter + 1, content: "\(transaction.shares)"),
                StonkGridCellData(
                    id: counter + 2,
                    content: "\(userData.currency)\(transaction.costPerShare.toFixed(2))")
            ]
            multiDimensionedData.append(row)
            counter += 3
        }
        return multiDimensionedData
    }
}

struct TransactionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsScreen()
            .environmentObject(Navigator())
            .environmentObject(StonksManager())
            .environmentObject(UserData())
    }
}
