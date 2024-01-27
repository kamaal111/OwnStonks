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
import UserSettings
import Transactions

public struct PerformancesScreen: View {
    @Environment(UserSettings.self) private var userSettings

    @State private var viewModel = ViewModel()

    public init() { }

    public var body: some View {
        KScrollableForm {
            KSection(header: NSLocalizedString("Holdings", bundle: .module, comment: "")) {
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
            guard let preferredCurrency else { return [] }

            let boughtTransactions = transactions
                .filter { transaction in
                    transaction.transactionType == .buy && transaction.pricePerUnit.currency == preferredCurrency
                }
            let boughtTransactionsMappedByName = Dictionary(grouping: boughtTransactions, by: \.name)
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

        @MainActor
        func setPreferredCurrency(_ currency: Currencies) {
            preferredCurrency = currency
        }
    }

    struct HoldingsPieChartPlotItem: Identifiable {
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
