//
//  TransactionsScreen.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI
import SalmonUI
import OSLocales
import ShrimpExtensions
import BetterNavigation

struct TransactionsScreen: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        KScrollableForm  {
            KSection(header: OSLocales.getText(.TRANSACTIONS)) {
                if viewModel.transactions.isEmpty {
                    OSButton(action: { viewModel.openAddTransactionSheet() }) {
                        OSText(localized: .ADD_YOUR_FIRST_TRANSACTION)
                            .foregroundColor(.accentColor)
                    }
                }
                ForEach(viewModel.transactions, id: \.self) { transaction in
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
                submittedTransaction: viewModel.handleSubmittedTransaction)
        })
    }

    private var toolbarView: some View {
        Button(action: { viewModel.openAddTransactionSheet() }) {
            Image(systemName: "plus")
                .foregroundColor(.accentColor)
        }
        .help(OSLocales.getText(.ADD_TRANSACTION))
    }
}

private final class ViewModel: ObservableObject {
    @Published var showAddTransactionSheet = false
    @Published private(set) var transactions: [OSTransaction] = []

    func handleSubmittedTransaction(_ transaction: OSTransaction) {
        transactions = transactions
            .appended(transaction)
            .sorted(by: \.date, using: .orderedDescending)
    }

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
