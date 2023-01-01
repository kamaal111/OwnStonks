//
//  TransactionsScreen.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import Models
import SwiftUI
import SalmonUI
import PopperUp
import OSLocales
import ShrimpExtensions
import BetterNavigation

struct TransactionsScreen: View {
    @EnvironmentObject private var transactionsViewModel: TransactionsViewModel
    @EnvironmentObject private var popperUpManager: PopperUpManager

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
                    TransactionView(transaction: transaction, action: { transaction in
                        viewModel.openEditTransactionSheet(with: transaction)
                    })
                    #if os(macOS)
                    if transactionsViewModel.transactions.last != transaction {
                        Divider()
                    }
                    #endif
                }
            }
            #if os(macOS)
            .padding(.horizontal, .medium)
            #endif
        }
        .padding(.vertical, .medium)
        .toolbar(content: { toolbarView })
        .navigationTitle(title: OSLocales.getText(.TRANSACTIONS), displayMode: .large)
        .sheet(isPresented: $viewModel.showSheet, content: {
            switch viewModel.shownSheetType {
            case .none:
                EmptyView()
            case .addTransaction, .editTransaction:
                TransactionDetailSheet(
                    isShown: $viewModel.showSheet,
                    context: viewModel.shownSheetType!,
                    submittedTransaction: handleSubmittedTransaction)
            }
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
        let result = transactionsViewModel.fetch()
        switch result {
        case .failure(let failure):
            popperUpManager.showPopup(style: failure.popUpStyle, timeout: 3)
        case .success:
            break
        }
    }

    private func handleSubmittedTransaction(_ transaction: OSTransaction) {
        switch viewModel.shownSheetType {
        case .none:
            assertionFailure("Should not be able to submit when there is no type")
        case .editTransaction(transaction: let transaction):
            #warning("Handle edited transaction")
            print("came from editing")
        case .addTransaction:
            let result = transactionsViewModel.addTransaction(transaction)
            switch result {
            case .failure(let failure):
                popperUpManager.showPopup(style: failure.popUpStyle, timeout: 3)
            case .success:
                break
            }
        }
    }
}

private final class ViewModel: ObservableObject {
    @Published var showSheet = false
    @Published private(set) var shownSheetType: TransactionDetailSheetContext? {
        didSet { Task { await shownSheetDidSet() } }
    }

    @MainActor
    func openAddTransactionSheet() {
        shownSheetType = .addTransaction
    }

    @MainActor
    func openEditTransactionSheet(with transaction: OSTransaction) {
        shownSheetType = .editTransaction(transaction: transaction)
    }

    @MainActor
    func shownSheetDidSet() {
        if shownSheetType != nil && !showSheet {
            showSheet = true
        } else if shownSheetType == nil && showSheet {
            showSheet = false
        }
    }
}

struct TransactionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsScreen()
    }
}
