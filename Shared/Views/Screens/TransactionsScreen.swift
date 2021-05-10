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
    @EnvironmentObject
    private var stonksManager: StonksManager
    @EnvironmentObject
    private var userData: UserData
    #if canImport(AppKit)
    @EnvironmentObject
    private var navigator: Navigator
    #else
    @State private var showAddTransactionScreen = false
    #endif

    @ObservedObject
    private var viewModel = ViewModel()

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
            .frame(minWidth: 416)
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
                        TransactionsGridView(
                            multiDimensionedData: transactionRows,
                            viewWidth: geometry.size.width,
                            onCellPress: { viewModel.selectCell($0, from: stonksManager.sortedTransactions) })
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showTransactionSheet) {
            TransactionSheet(
                transaction: viewModel.selectedTranaction,
                currency: userData.currency,
                close: { viewModel.showTransactionSheet = false })
        }
    }

    private var transactionRows: [[StonkGridCellData]] {
        var multiDimensionedData: [[StonkGridCellData]] = []
        var counter = 0
        for transaction in stonksManager.sortedTransactions {
            let row = [
                StonkGridCellData(id: counter, content: transaction.name, transactionID: transaction.id),
                StonkGridCellData(id: counter + 1, content: "\(transaction.shares)", transactionID: transaction.id),
                StonkGridCellData(
                    id: counter + 2,
                    content: "\(userData.currency)\(transaction.costPerShare.toFixed(2))",
                    transactionID: transaction.id),
                StonkGridCellData(
                    id: counter + 3,
                    content: "\(userData.currency)\(transaction.totalPrice.toFixed(2))",
                    transactionID: transaction.id)
            ]
            multiDimensionedData.append(row)
            counter += row.count
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
