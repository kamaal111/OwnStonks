//
//  TransactionsManager.swift
//
//
//  Created by Kamaal M Farah on 09/12/2023.
//

import CloudKit
import Foundation
import SharedUtils
import Observation
import KamaalLogger
import SharedModels
import PersistentData
import KamaalExtensions

private let logger = KamaalLogger(from: TransactionsManager.self, failOnError: true)

@Observable
final class TransactionsManager {
    private(set) var loading: Bool
    private let persistentData: PersistentDatable
    private var quickStorage: TransactionsQuickStoragable
    private let events: [LocalNotificationEvents] = [
        .iCloudChanges,
    ]
    private(set) var transactions: [AppTransaction] = []

    private var storedTransactions: [StoredTransaction] = []

    convenience init() {
        self.init(persistentData: PersistentData.shared, quickStorage: TransactionsQuickStorage.shared)
    }

    init(persistentData: PersistentDatable, quickStorage: TransactionsQuickStoragable) {
        self.loading = true
        self.persistentData = persistentData
        self.quickStorage = quickStorage

        LocalNotifications.shared.observe(
            to: events,
            selector: #selector(handleNotification),
            from: self
        )
    }

    deinit {
        LocalNotifications.shared.removeObservers(events, from: self)
    }

    var transactionsAreEmpty: Bool {
        transactions.isEmpty
    }

    func transactionIsNotPendingInTheCloud(_ transaction: AppTransaction) -> Bool {
        guard let transactionID = transaction.id else {
            assertionFailure("Transaction should have a id")
            return false
        }

        let storedTransactionsIDs = storedTransactions.compactMap(\.id)
        assert(storedTransactions.count == storedTransactionsIDs.count)
        return storedTransactionsIDs.contains(transactionID)
    }

    func fetchTransactions() async throws {
        try await withLoading {
            let storedTransactions: [StoredTransaction] = try await persistentData
                .list(sorts: [SortDescriptor(\.updatedDate, order: .reverse)])

            if !quickStorage.pendingCloudChanges {
                await setStoredTransactions(storedTransactions, sort: false)
                return
            }

            let fetchedCloudRecords = try await persistentData.listICloud(of: AppTransaction.self)
            let fetchedCloudRecordsTransctions = fetchedCloudRecords
                .compactMap(AppTransaction.fromCKRecord(_:))
            assert(fetchedCloudRecords.count == fetchedCloudRecordsTransctions.count)
            let fetchedRecordIDs = fetchedCloudRecordsTransctions
                .compactMap(\.id)
                .sorted(by: \.uuidString, using: .orderedAscending)
            let transactionsIDs = transactions
                .compactMap(\.id)
                .sorted(by: \.uuidString, using: .orderedAscending)
            if fetchedRecordIDs == transactionsIDs {
                logger.info("Fetched from iCloud and no more changes pending")
                quickStorage.pendingCloudChanges = false
                await setStoredTransactions(storedTransactions, sort: true)
                return
            }

            logger.info("Fetched from iCloud directly and still changes are still pending")
            await setTransactions(fetchedCloudRecordsTransctions, sort: true)
        }

        logger.info("Successfully fetched \(transactions.count) transctions")
    }

    @MainActor
    func deleteTransaction(_ transaction: AppTransaction) {
        guard let transactionID = transaction.id,
              let storedTransactionIndex = storedTransactions.findIndex(by: \.id, is: transactionID) else {
            assertionFailure("Should have transaction here")
            return
        }

        assert(transactionIsNotPendingInTheCloud(transaction))

        let storedTransaction = storedTransactions[storedTransactionIndex]
        storedTransaction.delete()
        setStoredTransactions(storedTransactions.removed(at: storedTransactionIndex), sort: true)
        logger.info("Deleting transaction with ID \(transactionID)")
    }

    @MainActor
    func editTransaction(_ transaction: AppTransaction) throws {
        guard let transactionID = transaction.id,
              let storedTransactionIndex = storedTransactions.findIndex(by: \.id, is: transactionID) else {
            assertionFailure("Should have transaction here")
            return
        }

        let storedTransaction = storedTransactions[storedTransactionIndex]
        let updatedTransaction = try storedTransaction.update(payload: .init(
            name: transaction.name,
            transactionDate: transaction.transactionDate,
            transactionType: transaction.transactionType,
            amount: transaction.amount,
            pricePerUnit: transaction.pricePerUnit,
            fees: transaction.fees,
            assetDataSource: nil
        ))
        var storedTransactions = storedTransactions
        storedTransactions[storedTransactionIndex] = updatedTransaction
        setStoredTransactions(storedTransactions, sort: true)
        logger.info("Edited transaction with ID \(transactionID)")
    }

    @MainActor
    func createTransaction(_ transaction: AppTransaction) throws {
        assert(!transaction.name.trimmingByWhitespacesAndNewLines.isEmpty)
        let storedTransaction = try StoredTransaction.create(
            payload: .init(
                name: transaction.name,
                transactionDate: transaction.transactionDate,
                transactionType: transaction.transactionType,
                amount: transaction.amount,
                pricePerUnit: transaction.pricePerUnit,
                fees: transaction.fees, assetDataSource: nil
            ),
            context: persistentData.dataContainerContext
        )
        setStoredTransactions(storedTransactions.appended(storedTransaction), sort: true)
        logger.info("Created transaction successfully")
    }

    @MainActor
    private func setStoredTransactions(_ transactions: [StoredTransaction], sort: Bool) {
        if sort {
            let sortedTransactions = transactions
                .filter { transaction in transaction.updatedDate != nil }
                .sorted(by: \.updatedDate!, using: .orderedDescending)
            let appTransactions = sortedTransactions.compactMap(\.appTransaction)
            assert(sortedTransactions.count == transactions.count)
            assert(sortedTransactions.count == appTransactions.count)
            storedTransactions = sortedTransactions
            setTransactions(appTransactions, sort: false)
            return
        }

        let appTransactions = transactions.compactMap(\.appTransaction)
        assert(transactions.count == appTransactions.count)
        storedTransactions = transactions
        setTransactions(appTransactions, sort: false)
    }

    @MainActor
    private func setTransactions(_ transactions: [AppTransaction], sort: Bool) {
        if sort {
            let sortedTransactions = transactions
                .filter { transaction in transaction.updatedDate != nil }
                .sorted(by: \.updatedDate!, using: .orderedDescending)
            assert(sortedTransactions.count == transactions.count)
            self.transactions = sortedTransactions
            return
        }

        self.transactions = transactions
    }

    @objc
    private func handleNotification(_ notification: Notification) {
        let event = events.find(by: \.notificationName, is: notification.name)
        switch event {
        case .iCloudChanges: handleICloudChangesNotification(notification)
        default:
            let loggingMessage = "Invalid event of \(notification.name) emitted to TransactionsManager"
            logger.warning(loggingMessage)
            assertionFailure(loggingMessage)
        }
    }

    private func handleICloudChangesNotification(_ notification: Notification) {
        let object = notification.object as? CKNotification
        quickStorage.pendingCloudChanges = true
        Task {
            do {
                try await fetchTransactions()
            } catch {
                logger.error(
                    label: "Failed to fetch transactions after notified about iCloud changes notification",
                    error: error
                )
            }
        }

        logger.info("Received iCloud changes notification with object='\(object as Any)'")
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
