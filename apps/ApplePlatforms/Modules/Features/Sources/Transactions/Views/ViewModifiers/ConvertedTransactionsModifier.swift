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
    public func fetchAndConvertTransactions(
        transactions: Binding<[AppTransaction]>,
        loading: Binding<Bool>,
        fetchCloses: Bool
    ) -> some View {
        modifier(FetchAndConvertTransactionsModifier(
            transactions: transactions,
            loading: loading,
            fetchCloses: fetchCloses
        ))
    }
}

private struct FetchAndConvertTransactionsModifier: ViewModifier {
    @Environment(TransactionsManager.self) private var transactionsManager
    @Environment(ValutaConversion.self) private var valutaConversion
    @Environment(UserSettings.self) private var userSettings

    @EnvironmentObject private var popUpManager: KPopUpManager

    @Binding var transactions: [AppTransaction]
    @Binding var loading: Bool
    let fetchCloses: Bool

    func body(content: Content) -> some View {
        content
            .onAppear(perform: handleOnAppear)
            .onChange(of: userSettings.preferredForexCurrency) { _, newValue in
                Task { await handleFetchExchangeRate(of: newValue) }
            }
            .onChange(of: transactionsManager.transactions, handleTransactionsChange)
    }

    private func withLoading(completion: () async -> Void) async {
        loading = true
        await completion()
        loading = false
    }

    private func handleOnAppear() {
        Task {
            await withLoading {
                async let fetchTransactionWait: () = handleFetchingTransactions()
                async let fetchExchangeRateWait: () = handleFetchExchangeRate(of: userSettings.preferredForexCurrency)
                _ = await [fetchTransactionWait, fetchExchangeRateWait]
                let previousTransactionsCount = transactions.count
                transactions = convertTransactions()
                guard previousTransactionsCount != 0 else { return }

                handleFetchingCloses()
            }
        }
    }

    private func handleTransactionsChange(_: [AppTransaction], _: [AppTransaction]) {
        transactions = convertTransactions()
        handleFetchingCloses()
        logger.info("transactions changed")
    }

    private func handleFetchingCloses() {
        guard fetchCloses else { return }

        Task {
            await withLoading {
                await transactionsManager.fetchCloses(
                    valutaConversion: valutaConversion,
                    preferredCurrency: userSettings.preferredForexCurrency
                )
            }
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
