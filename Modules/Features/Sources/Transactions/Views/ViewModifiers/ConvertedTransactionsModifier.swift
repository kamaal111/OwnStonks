//
//  ConvertedTransactionsModifier.swift
//
//
//  Created by Kamaal M Farah on 24/01/2024.
//

import SwiftUI
import ForexKit
import KamaalPopUp
import UserSettings
import KamaalLogger
import ValutaConversion

private let logger = KamaalLogger(from: FetchAndConvertTransactionsModifier.self, failOnError: true)

extension View {
    public func fetchAndConvertTransactions(_ transactions: Binding<[AppTransaction]>) -> some View {
        modifier(FetchAndConvertTransactionsModifier(transactions: transactions))
    }
}

private struct FetchAndConvertTransactionsModifier: ViewModifier {
    @Environment(TransactionsManager.self) private var transactionsManager
    @Environment(ValutaConversion.self) private var valutaConversion
    @Environment(UserSettings.self) private var userSettings

    @EnvironmentObject private var popUpManager: KPopUpManager

    @Binding var transactions: [AppTransaction]

    func body(content: Content) -> some View {
        content
            .onAppear(perform: handleOnAppear)
            .onChange(of: userSettings.preferredForexCurrency) { _, newValue in
                Task { await handleFetchExchangeRate(of: newValue) }
            }
            .onChange(of: transactionsManager.transactions, handleTransactionsChange)
    }

    private func handleOnAppear() {
        Task {
            async let fetchTransactionWait: () = handleFetchingTransactions()
            async let fetchExchangeRateWait: () = handleFetchExchangeRate(of: userSettings.preferredForexCurrency)
            _ = await [fetchTransactionWait, fetchExchangeRateWait]
            transactions = convertTransactions()
        }
    }

    private func handleTransactionsChange(_: [AppTransaction], _: [AppTransaction]) {
        transactions = convertTransactions()
        handleFetchingCloses()
        logger.info("transactions changed")
    }

    private func handleFetchingCloses() {
        Task {
            await transactionsManager.fetchCloses(
                valutaConversion: valutaConversion,
                preferredCurrency: userSettings.preferredForexCurrency
            )
        }
    }

    private func handleFetchingTransactions() async {
        do {
            try await transactionsManager.fetchTransactions()
        } catch {
            showError(
                with: NSLocalizedString("Failed to get transactions", bundle: .module, comment: ""),
                from: error
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
        }
        transactions = convertTransactions()
    }

    private func convertTransactions() -> [AppTransaction] {
        let preferredCurrency = userSettings.preferredForexCurrency
        return transactionsManager.transactions
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

    private func showError(with title: String, from error: Error) {
        logger.error(label: title, error: error)
        popUpManager.showPopUp(style: .bottom(title: title, type: .error, description: nil), timeout: 5)
    }
}
