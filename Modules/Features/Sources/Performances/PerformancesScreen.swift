//
//  PerformancesScreen.swift
//
//
//  Created by Kamaal M Farah on 21/01/2024.
//

import Charts
import SwiftUI
import KamaalUI
import SharedUI
import ForexKit
import SharedModels
import UserSettings
import Transactions

public struct PerformancesScreen: View {
    @Environment(UserSettings.self) private var userSettings

    @State private var viewModel = ViewModel()

    public init() { }

    public var body: some View {
        KJustStack {
            if viewModel.loadingTransactions {
                KLoading()
            }
            KScrollableForm {
                KSection(header: NSLocalizedString("Holdings", bundle: .module, comment: "")) {
                    if let totalHoldingsMoney = viewModel.totalHoldingsMoney {
                        Text(String(
                            format: NSLocalizedString("Total %@", bundle: .module, comment: ""),
                            totalHoldingsMoney.localized
                        ))
                    }
                    Chart(viewModel.holdingsPieChartPlots) { plot in
                        SectorMark(angle: plot.angle, angularInset: 1)
                            .foregroundStyle(by: plot.style)
                            .cornerRadius(2)
                    }
                }
                #if os(macOS)
                .padding(.horizontal, .medium)
                #endif
            }
            .padding(.vertical, .medium)
        }
        .fetchAndConvertTransactions(transactions: $viewModel.transactions, loading: $viewModel.loadingTransactions)
        .onAppear(perform: handleOnAppear)
        .onChange(of: userSettings.preferredForexCurrency, handlePreferredForexCurrencyChange)
    }

    private func handleOnAppear() {
        let preferredForexCurrency = userSettings.preferredForexCurrency
        handlePreferredForexCurrencyChange(preferredForexCurrency, preferredForexCurrency)
    }

    private func handlePreferredForexCurrencyChange(_: Currencies, _ newValue: Currencies) {
        Task { await viewModel.setPreferredCurrency(newValue) }
    }
}

extension PerformancesScreen {
    @Observable
    final class ViewModel {
        var transactions: [AppTransaction] = []
        var loadingTransactions = false
        var preferredCurrency: Currencies?

        var holdingsPieChartPlots: [HoldingsPieChartPlotItem] {
            let boughtTransactionsMappedByName = boughtTransactionsMappedByName
            return boughtTransactionsMappedByName
                .keys
                .sorted()
                .compactMap { key -> HoldingsPieChartPlotItem? in
                    let value = (boughtTransactionsMappedByName[key] ?? [])
                        .reduce(0.0) { result, transaction in
                            result + transaction.totalPriceExcludingFees.value
                        }
                    guard value > 0 else { return nil }

                    return HoldingsPieChartPlotItem(name: key, value: value)
                }
        }

        var totalHoldingsMoney: Money? {
            guard let preferredCurrency else { return nil }

            let value = boughtTransactionsMappedByName
                .values
                .reduce(0.0) { result, transactions in
                    result + transactions
                        .reduce(0.0) { result, transaction in result + transaction.totalPriceExcludingFees.value }
                }
            return Money(value: value, currency: preferredCurrency)
        }

        @MainActor
        func setPreferredCurrency(_ currency: Currencies) {
            preferredCurrency = currency
        }

        private var boughtTransactionsMappedByName: [String: [AppTransaction]] {
            guard let preferredCurrency else { return [:] }

            let boughtTransactions = transactions
                .filter { transaction in
                    transaction.transactionType == .buy && transaction.pricePerUnit.currency == preferredCurrency
                }
            return Dictionary(grouping: boughtTransactions, by: \.name)
        }
    }

    struct HoldingsPieChartPlotItem: Identifiable, Equatable {
        let name: String
        let value: Double

        var id: String { name }

        var style: PlottableValue<String> {
            .value(NSLocalizedString("Holding", bundle: .module, comment: ""), name)
        }

        var angle: PlottableValue<Double> {
            .value(name, value)
        }
    }
}

#Preview {
    PerformancesScreen()
}
