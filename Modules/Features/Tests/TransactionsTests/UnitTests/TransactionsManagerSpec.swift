//
//  TransactionsManagerSpec.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import Quick
import Nimble
import XCTest
import CloudKit
import Foundation
import SharedUtils
import SharedModels
import PersistentData
import KamaalExtensions
@testable import Transactions

final class TransactionsManagerSpec: AsyncSpec {
    override class func spec() {
        var persistentData: TestPersistentData!
        var quickStorage: TestTransactionsQuickStorage!
        var manager: TransactionsManager!

        beforeEach {
            persistentData = try TestPersistentData()
            quickStorage = TestTransactionsQuickStorage()
            manager = TransactionsManager(persistentData: persistentData, quickStorage: quickStorage)
        }

        describe("Handle iCloud changes") {
            it("should have a manager with pending cloud storage changes set to false by default") {
                // Then
                expect(quickStorage.pendingCloudChanges) == false
            }

            it("should set pending cloud changes to true after notification received") {
                // Given
                let testTransaction = testTransaction.setID(UUID())
                persistentData.cloudResponse = [testTransaction.asCKRecord]

                // When
                LocalNotifications.shared.emit(.iCloudChanges)

                // Then
                let conditionMet = retryUntilConditionMet { quickStorage.pendingCloudChanges }
                expect(conditionMet) == true
            }

            it("should handle iCloud changes accordingly") {
                // Given
                let testTransactionID = UUID()
                let testTransaction = testTransaction.setID(testTransactionID)
                persistentData.cloudResponse = [testTransaction.asCKRecord]

                // When
                LocalNotifications.shared.emit(.iCloudChanges)

                // Then
                let conditionMet = retryUntilConditionMet { manager.transactions.count == 1 }
                expect(conditionMet) == true
                expect(quickStorage.pendingCloudChanges) == true
                expect(manager.transactions.first?.id) == testTransactionID
            }

            it("should set pending cloud chages to false when cloud changes are the same as stored changes") {
                // Given
                try await manager.createTransaction(testTransaction)
                expect(manager.transactions.count) == 1
                let transaction = try XCTUnwrap(manager.transactions.first)
                persistentData.cloudResponse = [transaction.asCKRecord]

                // When
                LocalNotifications.shared.emit(.iCloudChanges)

                // Then
                let conditionMet = retryUntilConditionMet { !quickStorage.pendingCloudChanges }
                expect(conditionMet) == true
            }
        }

        describe("Deleting transactions") {
            it("should delete transaction from storage") {
                // Given
                try await manager.createTransaction(testTransaction)
                let storedTransaction = manager.transactions[0]

                // When
                await manager.deleteTransaction(storedTransaction)

                // Then
                expect(manager.transactionsAreEmpty) == true
            }
        }

        describe("Edit transactions") {
            it("should edit transaction") {
                // Given
                try await manager.createTransaction(testTransaction)
                let storedTransaction = manager.transactions[0]
                let transactionWithChanges = AppTransaction(
                    id: storedTransaction.id!,
                    name: "NewNewCo",
                    transactionDate: storedTransaction.transactionDate,
                    transactionType: .sell,
                    amount: 22,
                    pricePerUnit: Money(value: 44, currency: .CAD),
                    fees: Money(value: 1, currency: .BGN),
                    updatedDate: storedTransaction.updatedDate,
                    creationDate: storedTransaction.creationDate
                )

                // Sanity
                expect(storedTransaction) != transactionWithChanges

                // When
                try await manager.editTransaction(transactionWithChanges)

                // Then
                expect(manager.transactions.count) == 1
                expect(manager.transactions[0]) == transactionWithChanges
                    .setUpdatedDate(manager.transactions[0].updatedDate!)
            }

            it("should keep stored transaction changes in memory after fetch") {
                // Given
                try await manager.createTransaction(testTransaction)
                let storedTransaction = manager.transactions[0]
                let transactionWithChanges = AppTransaction(
                    id: storedTransaction.id!,
                    name: "NewNewCo",
                    transactionDate: storedTransaction.transactionDate,
                    transactionType: .sell,
                    amount: 22,
                    pricePerUnit: Money(value: 44, currency: .CAD),
                    fees: Money(value: 1, currency: .BGN),
                    updatedDate: storedTransaction.updatedDate,
                    creationDate: storedTransaction.creationDate
                )
                try await manager.editTransaction(transactionWithChanges)

                // When
                try await manager.fetchTransactions()

                // Then
                expect(manager.transactions.count) == 1
                expect(manager.transactions[0]) == transactionWithChanges
                    .setUpdatedDate(manager.transactions[0].updatedDate!)
            }
        }

        describe("Creating transactions") {
            it("should create and store transaction") {
                // When
                try await manager.createTransaction(testTransaction)

                // Then
                expect(manager.transactions.count) == 1
                let firstTransactionInManager = manager.transactions[0]
                let expectedTransaction = testTransaction
                    .setID(firstTransactionInManager.id!)
                    .setUpdatedDate(firstTransactionInManager.updatedDate!)
                    .setCreationDate(firstTransactionInManager.creationDate!)
                expect(firstTransactionInManager) == expectedTransaction
            }

            it("should create and store transaction and keep in memory when fetched") {
                // When
                try await manager.createTransaction(testTransaction)
                try await manager.fetchTransactions()

                // Then
                expect(manager.transactions.count) == 1
                let firstTransactionInManager = manager.transactions[0]
                let expectedTransaction = testTransaction
                    .setID(firstTransactionInManager.id!)
                    .setUpdatedDate(firstTransactionInManager.updatedDate!)
                    .setCreationDate(firstTransactionInManager.creationDate!)
                expect(firstTransactionInManager) == expectedTransaction
            }
        }

        describe("Fetching transactions") {
            it("should fetch transactions with a empty container") {
                // Sanity
                expect(manager.transactionsAreEmpty) == true

                // When
                try await manager.fetchTransactions()

                // Then
                expect(manager.transactionsAreEmpty) == true
            }

            it("should fetch stored transactions") {
                // Given
                try await manager.createTransaction(testTransaction)

                // Sanity
                expect(manager.transactions.count) == 1

                // When
                manager = TransactionsManager(persistentData: persistentData, quickStorage: quickStorage)
                try await manager.fetchTransactions()

                // Then
                expect(manager.transactions.count) == 1
            }
        }
    }
}

private let testTransaction = AppTransaction(
    name: "Apple",
    transactionDate: Date(),
    transactionType: .buy,
    amount: 25,
    pricePerUnit: Money(value: 100, currency: .USD),
    fees: Money(value: 1, currency: .EUR),
    updatedDate: Date(),
    creationDate: Date()
)

extension AppTransaction {
    fileprivate func setID(_ id: UUID) -> AppTransaction {
        AppTransaction(
            id: id,
            name: name,
            transactionDate: transactionDate,
            transactionType: transactionType,
            amount: amount,
            pricePerUnit: pricePerUnit,
            fees: fees,
            updatedDate: updatedDate,
            creationDate: creationDate
        )
    }
}

private func retryUntilConditionMet(_ predicate: () -> Bool, timeout: TimeInterval = 2) -> Bool {
    var result = predicate()
    let timeoutDate = Date(timeIntervalSinceNow: timeout)
    repeat {
        result = predicate()
    } while !result && Date().compare(timeoutDate) == .orderedAscending

    if !result {
        XCTFail("Failed to meet condition")
    }

    return result
}
