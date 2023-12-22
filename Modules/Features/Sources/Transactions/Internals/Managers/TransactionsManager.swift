//
//  TransactionsManager.swift
//
//
//  Created by Kamaal M Farah on 09/12/2023.
//

import Foundation
import Observation
import KamaalLogger
import SharedModels
import PersistentData
import KamaalExtensions

private let logger = KamaalLogger(from: TransactionsManager.self, failOnError: true)

@Observable
final class TransactionsManager {
    private(set) var storedTransactions: [StoredTransaction]
    private(set) var loading: Bool

    private let persistentData: PersistentDatable

    convenience init() {
        self.init(persistentData: PersistentData.shared)
    }

    init(persistentData: PersistentDatable) {
        self.storedTransactions = []
        self.loading = true
        self.persistentData = persistentData
    }

    var transactions: [AppTransaction] {
        let transactions = storedTransactions.compactMap(\.appTransaction)
        assert(storedTransactions.count == transactions.count)
        return transactions
    }

    var transactionsAreEmpty: Bool {
        storedTransactions.isEmpty
    }

    @MainActor
    func fetchTransactions() async throws {
        try await withLoading {
            logger.info("Fetching transactions")
            let transactions: [StoredTransaction] = try persistentData
                .list(sorts: [SortDescriptor(\.updatedDate, order: .reverse)])
            logger.info("Successfully fetched \(transactions.count) transctions")
            setStoredTransactions(transactions)
        }
    }

    func deleteTransaction(_ transaction: AppTransaction) {
        print("deleting \(transaction)")
    }

    @MainActor
    func editTransaction(_ transaction: AppTransaction) throws {
        assert(transaction.id != nil)
        assert(storedTransactions.contains(where: { $0.id == transaction.id }))
        guard let transactionID = transaction.id,
              let storedTransactionIndex = storedTransactions.findIndex(by: \.id, is: transactionID) else { return }

        let storedTransaction = storedTransactions[storedTransactionIndex]
        let updatedTransaction = try storedTransaction.update(
            name: transaction.name,
            transactionDate: transaction.transactionDate,
            transactionType: transaction.transactionType.rawValue,
            amount: transaction.amount,
            pricePerUnit: (transaction.pricePerUnit.value, transaction.pricePerUnit.currency),
            fees: (transaction.fees.value, transaction.fees.currency)
        )
        var storedTransactions = storedTransactions
        storedTransactions[storedTransactionIndex] = updatedTransaction
        setStoredTransactions(storedTransactions)
    }

    @MainActor
    func createTransaction(_ transaction: AppTransaction) {
        assert(!transaction.name.trimmingByWhitespacesAndNewLines.isEmpty)
        let storedTransaction = StoredTransaction.create(
            name: transaction.name,
            transactionDate: transaction.transactionDate,
            transactionType: transaction.transactionType.rawValue,
            amount: transaction.amount,
            pricePerUnit: Money(value: transaction.pricePerUnit.value, currency: transaction.pricePerUnit.currency),
            fees: Money(value: transaction.fees.value, currency: transaction.fees.currency),
            context: persistentData.dataContainerContext
        )
        setStoredTransactions(storedTransactions.appended(storedTransaction))
    }

    @MainActor
    private func setStoredTransactions(_ transactions: [StoredTransaction]) {
        let newStoredTransactions = transactions
            .filter { transaction in transaction.updatedDate != nil }
            .sorted(by: \.updatedDate!, using: .orderedDescending)
        assert(transactions.count == newStoredTransactions.count)
        storedTransactions = newStoredTransactions
    }

    private func withLoading<T>(_ completion: () async throws -> T) async rethrows -> T {
        await setLoading(true)
        let result = try await completion()
        await setLoading(false)
        return result
    }

    @MainActor
    private func setLoading(_ state: Bool) {
        guard loading != state else { return }

        loading = state
    }
}
