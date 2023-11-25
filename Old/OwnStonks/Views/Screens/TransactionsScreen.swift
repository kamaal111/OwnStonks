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
    @EnvironmentObject private var transactionsManager: TransactionsManager
    @EnvironmentObject private var exchangeRateManager: ExchangeRateManager
    @EnvironmentObject private var popperUpManager: PopperUpManager
    @EnvironmentObject private var userData: UserData

    @Environment(\.editMode) var editMode

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        KScrollableForm {
            KSection(header: OSLocales.getText(.TRANSACTIONS)) {
                if transactionsManager.isLoading {
                    KLoading()
                } else if transactionsManager.transactions.isEmpty {
                    OSButton(action: { viewModel.openAddTransactionSheet() }) {
                        OSText(localized: .ADD_YOUR_FIRST_TRANSACTION)
                            .foregroundColor(.accentColor)
                    }
                }
                ForEach(transactionsManager.transactions, id: \.self) { transaction in
                    TransactionView(
                        transaction: transaction,
                        editMode: editModeValue,
                        preferedCurrency: userData.preferedCurrency,
                        action: { transaction in viewModel.openEditTransactionSheet(with: transaction) },
                        onDelete: handleOnDelete
                    )
                    #if os(macOS)
                    if transactionsManager.transactions.last != transaction {
                        Divider()
                    }
                    #endif
                }
                #if os(iOS)
                .onDelete(perform: { indices in
                    for index in indices {
                        handleOnDelete(transactionsManager.transactions[index])
                    }
                })
                #endif
            }
            #if os(macOS)
            .padding(.horizontal, .medium)
            #endif
        }
        .padding(.vertical, .medium)
        .toolbar(content: { toolbarView })
        .sheet(isPresented: $viewModel.showSheet, content: {
            switch viewModel.shownSheetType {
            case .none:
                EmptyView()
            case .addTransaction, .editTransaction:
                TransactionDetailSheet(
                    isShown: $viewModel.showSheet,
                    context: viewModel.shownSheetType!,
                    submittedTransactions: { transactions in Task { await handleSubmittedTransactions(transactions) } }
                )
            }
        })
        .onAppear(perform: handleOnAppear)
    }

    private var editModeValue: EditMode {
        #if os(macOS)
        editMode
        #else
        editMode?.wrappedValue ?? .inactive
        #endif
    }

    private var toolbarView: some View {
        HStack {
            EditButton()
            Button(action: { viewModel.openAddTransactionSheet() }) {
                Image(systemName: "plus")
                    .foregroundColor(.accentColor)
            }
            .help(OSLocales.getText(.ADD_TRANSACTION))
        }
    }

    private func handleOnDelete(_ transaction: OSTransaction) {
        Task {
            let result = await transactionsManager.deleteTransaction(transaction)
            if case let .failure(failure) = result {
                popperUpManager.showPopup(style: failure.popUpStyle, timeout: 3)
            }
        }
    }

    private func handleOnAppear() {
        Task {
            let result = await transactionsManager.fetch()
            if case let .failure(failure) = result {
                popperUpManager.showPopup(style: failure.popUpStyle, timeout: 3)
            }
            await exchangeRateManager.fetch(preferedCurrency: userData.preferedCurrency)
        }
    }

    private func handleSubmittedTransactions(_ transactions: [OSTransaction]) async {
        var maybeError: TransactionsManager.Errors?
        switch viewModel.shownSheetType {
        case .none:
            assertionFailure("Should not be able to submit when there is no type")
        case .editTransaction:
            let result = await transactionsManager.updateTransactions(transactions)
            if case let .failure(failure) = result {
                maybeError = failure
            }
        case .addTransaction:
            let result = await transactionsManager.addTransaction(transactions)
            if case let .failure(failure) = result {
                maybeError = failure
            }
        }

        if let error = maybeError {
            popperUpManager.showPopup(style: error.popUpStyle, timeout: 3)
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
        if shownSheetType != nil, !showSheet {
            showSheet = true
        } else if shownSheetType == nil, showSheet {
            showSheet = false
        }
    }
}

struct TransactionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsScreen()
    }
}