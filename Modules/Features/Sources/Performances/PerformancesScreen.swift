//
//  PerformancesScreen.swift
//
//
//  Created by Kamaal M Farah on 21/01/2024.
//

import SwiftUI
import KamaalUI
import KamaalPopUp
import KamaalLogger
import Transactions

private let logger = KamaalLogger(from: PerformancesScreen.self, failOnError: true)

public struct PerformancesScreen: View {
    @Environment(TransactionsManager.self) private var transactionsManager

    @EnvironmentObject private var popUpManager: KPopUpManager

    public init() { }

    public var body: some View {
        KScrollableForm {
            KSection(header: "Stuff") {
                ForEach(transactionsManager.transactions) { transaction in
                    Text(transaction.name)
                }
            }
        }
        .onAppear(perform: handleOnAppear)
    }

    private func handleOnAppear() {
        Task { await handleFetchingTransactions() }
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

    private func showError(with title: String, from error: Error) {
        logger.error(label: title, error: error)
        popUpManager.showPopUp(style: .bottom(title: title, type: .error, description: nil), timeout: 5)
    }
}

#Preview {
    PerformancesScreen()
}
