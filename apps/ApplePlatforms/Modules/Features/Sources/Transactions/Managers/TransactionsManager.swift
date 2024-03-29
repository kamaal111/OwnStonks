//
//  TransactionsManager.swift
//
//
//  Created by Kamaal M Farah on 09/12/2023.
//

import CloudKit
import ForexKit
import StonksKit
import Foundation
import SharedUtils
import Observation
import KamaalLogger
import SharedModels
import PersistentData
import ValutaConversion
import KamaalExtensions

private let logger = KamaalLogger(from: TransactionsManager.self, failOnError: true)

/// Transactions manager class that manages transactions.
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
    private var stonksKit: StonksKit?
    private(set) var previousCloses: [String: Money] = [:]

    convenience init() {
        self.init(
            persistentData: PersistentData.shared,
            quickStorage: TransactionsQuickStorage.shared,
            urlSession: .shared
        )
    }

    init(persistentData: PersistentDatable, quickStorage: TransactionsQuickStoragable, urlSession: URLSession) {
        self.loading = true
        self.persistentData = persistentData
        self.quickStorage = quickStorage
        if let stonksKitURL = SecretsJSON.shared.content?.stonksKitURL {
            self.stonksKit = .init(baseURL: stonksKitURL, urlSession: urlSession, cacheStorage: quickStorage)
        }

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

            let fetchedCloudRecordsTransctions = try await fetchPendingICloudChanges()
            let transactinosArePendingInICloud = checkIfTransactionsArePendingInICloud(
                storedTransactions: storedTransactions,
                iCloudTransactions: fetchedCloudRecordsTransctions
            )
            if !transactinosArePendingInICloud {
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
        var dataSourcePayload: StoredTransactionDataSource.Payload?
        if let dataSource = transaction.dataSource {
            dataSourcePayload = .init(
                id: dataSource.id,
                transaction: storedTransaction,
                sourceType: dataSource.sourceType,
                ticker: dataSource.ticker
            )
        }
        let updatedTransaction = try storedTransaction.update(payload: .init(
            name: transaction.name,
            transactionDate: transaction.transactionDate,
            transactionType: transaction.transactionType,
            amount: transaction.amount,
            pricePerUnit: transaction.pricePerUnit,
            fees: transaction.fees,
            dataSource: dataSourcePayload
        ))
        var storedTransactions = storedTransactions
        storedTransactions[storedTransactionIndex] = updatedTransaction
        setStoredTransactions(storedTransactions, sort: true)
        logger.info("Edited transaction with ID \(transactionID)")
    }

    @MainActor
    func createTransaction(_ transaction: AppTransaction) throws {
        assert(!transaction.name.trimmingByWhitespacesAndNewLines.isEmpty)
        var dataSourcePayload: StoredTransactionDataSource.Payload?
        if let dataSource = transaction.dataSource {
            dataSourcePayload = .init(
                id: dataSource.id,
                transaction: nil,
                sourceType: dataSource.sourceType,
                ticker: dataSource.ticker
            )
        }
        let storedTransaction = try StoredTransaction.create(
            payload: .init(
                name: transaction.name,
                transactionDate: transaction.transactionDate,
                transactionType: transaction.transactionType,
                amount: transaction.amount,
                pricePerUnit: transaction.pricePerUnit,
                fees: transaction.fees,
                dataSource: dataSourcePayload
            ),
            context: persistentData.dataContainerContext
        )
        setStoredTransactions(storedTransactions.appended(storedTransaction), sort: true)
        logger.info("Created transaction successfully")
    }

    func fetchCloses(valutaConversion: ValutaConversion, preferredCurrency: Currencies) async {
        guard let stonksKit else { return }

        let tickers = transactions
            .filter { transaction in transaction.transactionType == .buy && transaction.amount > 0 }
            .compactMap(\.dataSource?.ticker)
        guard !tickers.isEmpty else { return }

        logger.info("Fetching closes for \(tickers.joined(separator: ", "))")
        let previousCloses: [String: Money]
        do {
            previousCloses = try await stonksKit.tickers.info(for: tickers, date: Date())
                .map { success in
                    success
                        .reduce([String: Money]()) { result, info in
                            guard let currency = Currencies(rawValue: info.value.currency) else {
                                assertionFailure("Should be a valid currency")
                                return result
                            }
                            guard let convertedValue = valutaConversion.convertMoney(
                                from: .init(value: info.value.close, currency: currency),
                                to: preferredCurrency
                            ) else { return result }
                            return result.merged(with: [info.key: convertedValue])
                        }
                }
                .get()
        } catch {
            logger.warning("Failed to load transaction infos")
            return
        }
        await setPreviousCloses(previousCloses)
        logger.info("Fetched transactions previous closes")
    }

    func setStonksKit(_ stonksKit: StonksKit) {
        self.stonksKit = stonksKit
    }

    @MainActor
    private func setPreviousCloses(_ previousCloses: [String: Money]) {
        self.previousCloses = previousCloses
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

    private func checkIfTransactionsArePendingInICloud(
        storedTransactions: [StoredTransaction],
        iCloudTransactions: [AppTransaction]
    ) -> Bool {
        let fetchedRecordIDs = iCloudTransactions
            .compactMap(\.id)
            .sorted(by: \.uuidString, using: .orderedAscending)
        let transactionsIDs = storedTransactions
            .compactMap(\.id)
            .sorted(by: \.uuidString, using: .orderedAscending)
        guard fetchedRecordIDs == transactionsIDs else { return true }

        let storedTransactionsMappedByID = storedTransactions.mappedByID
        for (id, iCloudTransaction) in iCloudTransactions.mappedByID {
            guard let id else {
                assertionFailure("Should have ID at this point")
                return true
            }

            guard let storedTransaction = storedTransactionsMappedByID[id] else {
                assertionFailure("Should definitly have storedTransaction at this point")
                return true
            }

            guard iCloudTransaction.name == storedTransaction.name else { return true }
            guard iCloudTransaction.fees == storedTransaction.feesFormatted else { return true }
            guard iCloudTransaction.pricePerUnit == storedTransaction.pricePerUnitFormatted else { return true }
            guard iCloudTransaction.transactionDate == storedTransaction.transactionDate else { return true }
            guard iCloudTransaction.amount == storedTransaction.amount else { return true }
            if iCloudTransaction.dataSource?.ticker != storedTransaction.dataSource?.ticker ||
                iCloudTransaction.dataSource?.sourceType != storedTransaction.dataSource?.sourceTypeFormatted {
                logger.warning("There are changes in the data source")
            }
//            guard iCloudTransaction.dataSource?.ticker == storedTransaction.dataSource?.ticker else { return true }
//            guard iCloudTransaction.dataSource?.sourceType == storedTransaction.dataSource?.sourceTypeFormatted
//            else { return true }
        }
        return false
    }

    private func fetchPendingICloudChanges() async throws -> [AppTransaction] {
        let fetchedCloudRecords = try await persistentData.listICloud(of: AppTransaction.self)
        let recordsWithDataSourcesIDs = fetchedCloudRecords
            .compactMap { record in record[AppTransaction.CloudKeys.dataSource.ckRecordKey] as? String }
        let dataSourcesQuery = NSPredicate(format: "recordName in %@", recordsWithDataSourcesIDs)
        let fetchedDataSources = try await persistentData
            .filterICloud(of: AppTransactionDataSource.self, by: dataSourcesQuery, limit: nil)
        let fetchedCloudRecordsTransctions = fetchedCloudRecords
            .compactMap { record in
                let dataSourceID = record[AppTransaction.CloudKeys.dataSource.ckRecordKey] as? String
                let dataSourceRecord = fetchedDataSources
                    .find(where: { record in record.recordID.recordName == dataSourceID })
                return AppTransaction.fromCKRecord(record, dataSourceRecord: dataSourceRecord)
            }
        assert(fetchedCloudRecords.count == fetchedCloudRecordsTransctions.count)

        return fetchedCloudRecordsTransctions
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
