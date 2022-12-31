//
//  TransactionsViewModel.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Models
import Backend
import Logster
import Swinject
import Foundation
import ShrimpExtensions

private let logger = Logster(from: TransactionsViewModel.self)

final class TransactionsViewModel: ObservableObject {
    @Published private(set) var transactions: [OSTransaction] = []

    private let backend: Backend

    init(preview: Bool = false) {
        self.backend = container.resolve(Backend.self, argument: preview)!
    }

    @MainActor
    func fetch() {
        logger.info("Fetching transactions")
        transactions = backend.transactions
            .list()
            .sorted(by: \.date, using: .orderedDescending)
    }

    func addTransaction(_ transaction: OSTransaction) {
        let newTransaction = backend.transactions.create(transaction)

        transactions = transactions
            .appended(newTransaction)
            .sorted(by: \.date, using: .orderedDescending)
    }

    @MainActor
    private func setTransactions(_ transactions: [OSTransaction]) {
        self.transactions = transactions
            .sorted(by: \.date, using: .orderedDescending)
    }
}
