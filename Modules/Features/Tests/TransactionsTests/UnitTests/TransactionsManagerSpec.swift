//
//  TransactionsManagerSpec.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import Quick
import Nimble
import Foundation
import SharedModels
@testable import Transactions

final class TransactionsManagerSpec: AsyncSpec {
    override class func spec() {
        var persistentData: TestPersistentData!
        var manager: TransactionsManager!

        beforeEach {
            persistentData = try TestPersistentData()
            manager = TransactionsManager(persistentData: persistentData)
        }

        describe("Deleting transactions") {
            it("should delete transaction from storage") {
                // Given
                await manager.createTransaction(testTransaction)
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
                await manager.createTransaction(testTransaction)
                let storedTransaction = manager.transactions[0]
                let transactionWithChanges = AppTransaction(
                    id: storedTransaction.id!,
                    name: "NewNewCo",
                    transactionDate: storedTransaction.transactionDate,
                    transactionType: .sell,
                    amount: 22,
                    pricePerUnit: Money(value: 44, currency: .CAD),
                    fees: Money(value: 1, currency: .BGN)
                )

                // Sanity
                expect(storedTransaction) != transactionWithChanges

                // When
                try await manager.editTransaction(transactionWithChanges)

                // Then
                expect(manager.transactions.count) == 1
                expect(manager.transactions[0]) == transactionWithChanges
            }

            it("should keep stored transaction changes in memory after fetch") {
                // Given
                await manager.createTransaction(testTransaction)
                let storedTransaction = manager.transactions[0]
                let transactionWithChanges = AppTransaction(
                    id: storedTransaction.id!,
                    name: "NewNewCo",
                    transactionDate: storedTransaction.transactionDate,
                    transactionType: .sell,
                    amount: 22,
                    pricePerUnit: Money(value: 44, currency: .CAD),
                    fees: Money(value: 1, currency: .BGN)
                )
                try await manager.editTransaction(transactionWithChanges)

                // When
                try await manager.fetchTransactions()

                // Then
                expect(manager.transactions.count) == 1
                expect(manager.transactions[0]) == transactionWithChanges
            }
        }

        describe("Creating transactions") {
            it("should create and store transaction") {
                // When
                await manager.createTransaction(testTransaction)

                // Then
                expect(manager.transactions.count) == 1
                let expectedTransaction = testTransaction.setID(manager.transactions.first!.id!)
                expect(manager.transactions.first) == expectedTransaction
            }

            it("should create and store transaction and keep in memory when fetched") {
                // When
                await manager.createTransaction(testTransaction)
                try await manager.fetchTransactions()

                // Then
                expect(manager.transactions.count) == 1
                let expectedTransaction = testTransaction.setID(manager.transactions.first!.id!)
                expect(manager.transactions.first) == expectedTransaction
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
                await manager.createTransaction(testTransaction)

                // Sanity
                expect(manager.transactions.count) == 1

                // When
                manager = TransactionsManager(persistentData: persistentData)
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
    fees: Money(value: 1, currency: .EUR)
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
            fees: fees
        )
    }
}
