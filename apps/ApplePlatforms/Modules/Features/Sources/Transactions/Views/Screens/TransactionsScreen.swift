//
//  TransactionsScreen.swift
//
//
//  Created by Kamaal M Farah on 25/11/2023.
//

import SwiftUI
import KamaalUI
import ForexKit
import SharedUI
import KamaalPopUp
import UserSettings
import KamaalLogger
import KamaalExtensions

private let logger = KamaalLogger(from: TransactionsScreen.self, failOnError: true)

public struct TransactionsScreen: View {
    @Environment(TransactionsManager.self) private var transactionsManager
    @Environment(UserSettings.self) private var userSettings
    @EnvironmentObject private var popUpManager: KPopUpManager

    @State private var viewModel = ViewModel()

    public init() { }

    public var body: some View {
        KScrollableForm {
            KSection(header: NSLocalizedString("Transactions", bundle: .module, comment: "")) {
                if transactionsManager.loading {
                    KLoading()
                } else if transactionsManager.transactionsAreEmpty {
                    AddFirstTransactionButton(action: { viewModel.showAddTransactionSheet() })
                }
                TransactionsList(
                    transactions: viewModel.convertedTransactions,
                    previousCloses: transactionsManager.previousCloses,
                    showMoney: userSettings.showMoney,
                    transactionAction: handleTransactionAction,
                    transactionDelete: handleTransactionDelete,
                    transactionEdit: handleTransactionEdit
                )
            }
            #if os(macOS)
            .padding(.horizontal, .medium)
            #endif
        }
        .padding(.vertical, .medium)
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing) { toolbarItem }
            #else
            toolbarItem
            #endif
        }
        .sheet(isPresented: $viewModel.showSheet) { presentedSheet }
        .alert(
            NSLocalizedString("Deletion warning", bundle: .module, comment: ""),
            isPresented: $viewModel.deletingTransaction,
            actions: {
                Button(role: .destructive, action: { onDefiniteTransactionDelete() }) {
                    Text("Sure", bundle: .module)
                }
                Button(role: .cancel, action: { }) {
                    Text("No", bundle: .module)
                }
            }, message: {
                Text("Are you sure you want to delete this transaction?", bundle: .module)
            }
        )
        .fetchAndConvertTransactions(
            transactions: $viewModel.convertedTransactions,
            loading: $viewModel.loadingConvertedTransactions,
            fetchCloses: FeatureFlags.previousClosesInTransactionsScreen
        )
    }

    private var toolbarItem: some View {
        Button(action: { viewModel.showAddTransactionSheet() }) {
            Image(systemName: "plus")
                .bold()
                .foregroundStyle(.tint)
                .accessibilityHint(NSLocalizedString("Open new transaction sheet", bundle: .module, comment: ""))
                .accessibilityLabel(Text("Add Transaction", bundle: .module))
        }
    }

    private var presentedSheet: some View {
        KJustStack {
            switch viewModel.shownSheet {
            case .addTransction:
                makeTransactionDetailsSheet(
                    context: .new(userSettings.preferredForexCurrency),
                    transaction: nil,
                    isNotPendingInTheCloud: true
                )
            case let .transactionDetails(transaction):
                makeTransactionDetailsSheet(
                    context: .details(transaction),
                    transaction: transaction,
                    isNotPendingInTheCloud: transactionsManager.transactionIsNotPendingInTheCloud(transaction)
                )
            case let .transactionEdit(transaction):
                makeTransactionDetailsSheet(
                    context: .edit(transaction),
                    transaction: transaction,
                    isNotPendingInTheCloud: transactionsManager.transactionIsNotPendingInTheCloud(transaction)
                )
            case .none: EmptyView()
            }
        }
    }

    private func makeTransactionDetailsSheet(
        context: TransactionDetailsSheetContext,
        transaction: AppTransaction?,
        isNotPendingInTheCloud: Bool
    ) -> some View {
        TransactionDetailsSheet(
            isShown: $viewModel.showSheet,
            context: context,
            isNotPendingInTheCloud: isNotPendingInTheCloud,
            onDone: onModifyTransactionDone,
            onDelete: {
                guard let transaction else {
                    assertionFailure("Should not be deleting if transaction is not present for some reason")
                    return
                }

                viewModel.onTransactionDelete(transaction)
            }
        )
    }

    private func withOriginalTransaction(
        _ transaction: AppTransaction,
        _ completion: (_ transaction: AppTransaction) -> Void
    ) {
        guard let transaction = transactionsManager.transactions.find(by: \.id, is: transaction.id)
        else {
            assertionFailure("Expected transaction to be present")
            return
        }

        completion(transaction)
    }

    private func handleTransactionAction(_ transaction: AppTransaction) {
        withOriginalTransaction(transaction) { transaction in
            viewModel.handleTransactionPress(transaction)
        }
    }

    private func handleTransactionDelete(_ transaction: AppTransaction) {
        guard transactionsManager.transactionIsNotPendingInTheCloud(transaction) else {
            assertionFailure("Should not be able to delete pending iCloud transaction")
            return
        }

        withOriginalTransaction(transaction) { transaction in
            viewModel.onTransactionDelete(transaction)
        }
    }

    private func handleTransactionEdit(_ transaction: AppTransaction) {
        withOriginalTransaction(transaction) { transaction in
            viewModel.handleTransactionEditSelect(transaction)
        }
    }

    private func onDefiniteTransactionDelete() {
        guard let transactionToDelete = viewModel.transactionToDelete else {
            assertionFailure("Should have a transction to delete")
            return
        }

        transactionsManager.deleteTransaction(transactionToDelete)
        viewModel.onDefiniteTransactionDelete()
    }

    private func onModifyTransactionDone(_ transaction: AppTransaction) {
        switch viewModel.shownSheet {
        case .addTransction:
            do {
                try transactionsManager.createTransaction(transaction)
            } catch {
                showError(
                    with: NSLocalizedString("Failed to create transaction", bundle: .module, comment: ""),
                    from: error
                )
            }
        case .transactionDetails, .transactionEdit:
            do {
                try transactionsManager.editTransaction(transaction)
            } catch {
                showError(
                    with: NSLocalizedString("Failed to update transaction", bundle: .module, comment: ""),
                    from: error
                )
            }
        case .none: assertionFailure("Should not be here!")
        }
    }

    private func showError(with title: String, from error: Error) {
        logger.error(label: title, error: error)
        popUpManager.showPopUp(style: .bottom(title: title, type: .error, description: nil), timeout: 5)
    }
}

extension TransactionsScreen {
    @Observable
    final class ViewModel {
        var convertedTransactions: [AppTransaction] = []
        var showSheet = false {
            didSet { showSheetDidSet() }
        }

        var deletingTransaction = false
        private(set) var transactionToDelete: AppTransaction?

        private(set) var shownSheet: Sheets? {
            didSet { shownSheetDidSet() }
        }

        var loadingConvertedTransactions = false

        @MainActor
        func onTransactionDelete(_ transaction: AppTransaction) {
            transactionToDelete = transaction
            deletingTransaction = true
        }

        @MainActor
        func onDefiniteTransactionDelete() {
            guard let transactionToDeleteID = transactionToDelete?.id,
                  let transactionToDeleteIndex = convertedTransactions.findIndex(by: \.id, is: transactionToDeleteID)
            else {
                assertionFailure("Should have transction to delete at this point")
                return
            }

            withAnimation { setConvertedTransactions(convertedTransactions.removed(at: transactionToDeleteIndex)) }
            transactionToDelete = nil
            deletingTransaction = false
        }

        @MainActor
        func setConvertedTransactions(_ transactions: [AppTransaction]) {
            convertedTransactions = transactions
        }

        @MainActor
        func showAddTransactionSheet() {
            shownSheet = .addTransction
        }

        @MainActor
        func handleTransactionPress(_ transaction: AppTransaction) {
            shownSheet = .transactionDetails(transaction)
        }

        @MainActor
        func handleTransactionEditSelect(_ transaction: AppTransaction) {
            shownSheet = .transactionEdit(transaction)
        }

        private func shownSheetDidSet() {
            if shownSheet == nil, showSheet {
                showSheet = false
            } else if shownSheet != nil, !showSheet {
                showSheet = true
            }
        }

        private func showSheetDidSet() {
            if !showSheet, shownSheet != nil {
                shownSheet = nil
            }
        }
    }

    enum Sheets: Equatable {
        case addTransction
        case transactionDetails(_ transaction: AppTransaction)
        case transactionEdit(_ transaction: AppTransaction)
    }
}

#Preview {
    TransactionsScreen()
}
