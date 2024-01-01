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
import ValutaConversion
import KamaalExtensions

private let logger = KamaalLogger(from: TransactionsScreen.self, failOnError: true)

public struct TransactionsScreen: View {
    @Environment(TransactionsManager.self) private var transactionManager
    @Environment(UserSettings.self) private var userSettings
    @Environment(ValutaConversion.self) private var valutaConversion
    @EnvironmentObject private var popUpManager: KPopUpManager

    @State private var viewModel = ViewModel()

    public init() { }

    public var body: some View {
        KScrollableForm {
            KSection(header: NSLocalizedString("Transactions", bundle: .module, comment: "")) {
                if transactionManager.loading {
                    KLoading()
                } else if transactionManager.transactionsAreEmpty {
                    AddFirstTransactionButton(action: { viewModel.showAddTransactionSheet() })
                }
                TransactionsList(
                    transactions: viewModel.convertedTransactions,
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
        .onAppear(perform: handleOnAppear)
        .onChange(of: userSettings.preferredForexCurrency) { _, newValue in
            Task { await handleFetchExchangeRate(of: newValue) }
        }
        .onChange(of: transactionManager.transactions) { _, _ in
            viewModel.setConvertedTransactions(convertTransactions())
        }
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
                    isNotPendingInTheCloud: transactionManager.transactionIsNotPendingInTheCloud(transaction)
                )
            case let .transactionEdit(transaction):
                makeTransactionDetailsSheet(
                    context: .edit(transaction),
                    transaction: transaction,
                    isNotPendingInTheCloud: transactionManager.transactionIsNotPendingInTheCloud(transaction)
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
        guard let transaction = transactionManager.transactions.find(by: \.id, is: transaction.id)
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
        guard transactionManager.transactionIsNotPendingInTheCloud(transaction) else {
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

        transactionManager.deleteTransaction(transactionToDelete)
        viewModel.onDefiniteTransactionDelete()
    }

    private func onModifyTransactionDone(_ transaction: AppTransaction) {
        switch viewModel.shownSheet {
        case .addTransction:
            do {
                try transactionManager.createTransaction(transaction)
            } catch {
                showError(
                    with: NSLocalizedString("Failed to create transaction", bundle: .module, comment: ""),
                    from: error
                )
            }
        case .transactionDetails, .transactionEdit:
            do {
                try transactionManager.editTransaction(transaction)
            } catch {
                showError(
                    with: NSLocalizedString("Failed to update transaction", bundle: .module, comment: ""),
                    from: error
                )
            }
        case .none: assertionFailure("Should not be here!")
        }
    }

    private func handleOnAppear() {
        Task {
            async let fetchTransactionWait: () = handleFetchingTransactions()
            async let fetchExchangeRateWait: () = handleFetchExchangeRate(of: userSettings.preferredForexCurrency)
            _ = await [fetchTransactionWait, fetchExchangeRateWait]
            viewModel.setConvertedTransactions(convertTransactions())
        }
    }

    private func convertTransactions() -> [AppTransaction] {
        let preferredCurrency = userSettings.preferredForexCurrency
        return transactionManager.transactions
            .map { transaction in
                let pricePerUnit = valutaConversion.convertMoney(from: transaction.pricePerUnit, to: preferredCurrency)
                let fees = valutaConversion.convertMoney(from: transaction.fees, to: preferredCurrency)
                return AppTransaction(
                    id: transaction.id,
                    name: transaction.name,
                    transactionDate: transaction.transactionDate,
                    transactionType: transaction.transactionType,
                    amount: transaction.amount,
                    pricePerUnit: pricePerUnit ?? transaction.pricePerUnit,
                    fees: fees ?? transaction.fees,
                    dataSource: transaction.dataSource,
                    updatedDate: transaction.updatedDate,
                    creationDate: transaction.creationDate
                )
            }
    }

    private func handleFetchExchangeRate(of currency: Currencies) async {
        do {
            try await valutaConversion.fetchExchangeRates(of: currency)
        } catch {
            showError(
                with: NSLocalizedString("Failed to get exchange rates", bundle: .module, comment: ""),
                from: error
            )
            return
        }
        viewModel.setConvertedTransactions(convertTransactions())
    }

    private func handleFetchingTransactions() async {
        do {
            try await transactionManager.fetchTransactions()
        } catch {
            showError(
                with: NSLocalizedString("Failed to get transactions", bundle: .module, comment: ""),
                from: error
            )
            return
        }
        viewModel.setConvertedTransactions(convertTransactions())
    }

    private func showError(with title: String, from error: Error) {
        logger.error(label: title, error: error)
        popUpManager.showPopUp(style: .bottom(title: title, type: .error, description: nil), timeout: 5)
    }
}

extension TransactionsScreen {
    @Observable
    final class ViewModel {
        private(set) var convertedTransactions: [AppTransaction] = []
        var showSheet = false {
            didSet { showSheetDidSet() }
        }

        var deletingTransaction = false
        private(set) var transactionToDelete: AppTransaction?

        private(set) var shownSheet: Sheets? {
            didSet { shownSheetDidSet() }
        }

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
