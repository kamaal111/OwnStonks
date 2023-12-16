//
//  TransactionsScreen.swift
//
//
//  Created by Kamaal M Farah on 25/11/2023.
//

import SwiftUI
import KamaalUI
import ForexKit
import KamaalPopUp
import UserSettings
import KamaalLogger
import ValutaConversion

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
                    transactions: viewModel.transactions,
                    layout: viewModel.transactionsSectionSize.width < 500 ? .medium : .large,
                    transactionAction: { transaction in viewModel.handleTransactionPress(transaction) }
                )
            }
            .kBindToFrameSize($viewModel.transactionsSectionSize)
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
        .onAppear(perform: handleOnAppear)
        .onChange(of: userSettings.preferredForexCurrency) { _, newValue in handleFetchExchangeRate(of: newValue) }
        .onChange(of: transactionManager.transactions) { _, newValue in handleTransactionsChange(newValue) }
        .onChange(of: valutaConversion.rates) { _, _ in handleRatesChange() }
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
                TransactionDetailsSheet(
                    isShown: $viewModel.showSheet,
                    context: .new(userSettings.preferredForexCurrency),
                    onDone: onModifyTransactionDone
                )
            case let .transactionDetails(transaction):
                TransactionDetailsSheet(
                    isShown: $viewModel.showSheet,
                    context: .details(transaction),
                    onDone: onModifyTransactionDone
                )
            case .none: EmptyView()
            }
        }
    }

    private func onModifyTransactionDone(_ transaction: AppTransaction) {
        switch viewModel.shownSheet {
        case .addTransction: transactionManager.createTransaction(transaction)
        case .transactionDetails:
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
        handleFetchingTransactions()
        handleFetchExchangeRate(of: userSettings.preferredForexCurrency)
    }

    private func handleTransactionsChange(_ newValue: [AppTransaction]) {
        viewModel.setTransactions(convertTransactions(newValue))
    }

    private func handleRatesChange() {
        viewModel.setTransactions(convertTransactions(viewModel.transactions))
    }

    private func convertTransactions(_ transactions: [AppTransaction]) -> [AppTransaction] {
        let preferredCurrency = userSettings.preferredForexCurrency
        return transactions
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
                    fees: fees ?? transaction.fees
                )
            }
    }

    private func handleFetchExchangeRate(of currency: Currencies) {
        Task {
            do {
                try await valutaConversion.fetchExchangeRates(of: currency)
            } catch {
                showError(
                    with: NSLocalizedString("Failed to get exchange rates", bundle: .module, comment: ""),
                    from: error
                )
            }
        }
    }

    private func handleFetchingTransactions() {
        Task {
            do {
                try await transactionManager.fetchTransactions()
            } catch {
                showError(
                    with: NSLocalizedString("Failed to get transactions", bundle: .module, comment: ""),
                    from: error
                )
            }
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
        private(set) var transactions: [AppTransaction] = []

        var showSheet = false {
            didSet { showSheetDidSet() }
        }

        var transactionsSectionSize: CGSize = .zero

        private(set) var shownSheet: Sheets? {
            didSet { shownSheetDidSet() }
        }

        @MainActor
        func setTransactions(_ transactions: [AppTransaction]) {
            self.transactions = transactions
        }

        @MainActor
        func showAddTransactionSheet() {
            shownSheet = .addTransction
        }

        @MainActor
        func handleTransactionPress(_ transaction: AppTransaction) {
            shownSheet = .transactionDetails(transaction)
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
    }
}

#Preview {
    TransactionsScreen()
}
