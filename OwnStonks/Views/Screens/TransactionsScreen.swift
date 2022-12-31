//
//  TransactionsScreen.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import Models
import SwiftUI
import SalmonUI
import OSLocales
import ShrimpExtensions
import BetterNavigation

struct TransactionsScreen: View {
    @EnvironmentObject private var transactionsViewModel: TransactionsViewModel

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        KScrollableForm  {
            KSection(header: OSLocales.getText(.TRANSACTIONS)) {
                if transactionsViewModel.transactions.isEmpty {
                    OSButton(action: { viewModel.openAddTransactionSheet() }) {
                        OSText(localized: .ADD_YOUR_FIRST_TRANSACTION)
                            .foregroundColor(.accentColor)
                    }
                }
                ForEach(transactionsViewModel.transactions, id: \.self) { transaction in
                    TransactionView(transaction: transaction)
                        .padding(.horizontal, .medium)
                }
            }
            #if os(macOS)
            .padding(.horizontal, .medium)
            #endif
        }
        .padding(.vertical, .medium)
        .toolbar(content: { toolbarView })
        .navigationTitle(title: OSLocales.getText(.TRANSACTIONS), displayMode: .large)
        .sheet(isPresented: $viewModel.showAddTransactionSheet, content: {
            AddTransactionSheet(
                isShown: $viewModel.showAddTransactionSheet,
                submittedTransaction: transactionsViewModel.addTransaction)
        })
        .onAppear(perform: handleOnAppear)
    }

    private var toolbarView: some View {
        Button(action: { viewModel.openAddTransactionSheet() }) {
            Image(systemName: "plus")
                .foregroundColor(.accentColor)
        }
        .help(OSLocales.getText(.ADD_TRANSACTION))
    }

    private func handleOnAppear() {
        transactionsViewModel.fetch()
    }
}

private final class ViewModel: ObservableObject {
    @Published var showAddTransactionSheet = false

    @MainActor
    func openAddTransactionSheet() {
        showAddTransactionSheet = true
    }
}

struct TransactionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsScreen()
    }
}
