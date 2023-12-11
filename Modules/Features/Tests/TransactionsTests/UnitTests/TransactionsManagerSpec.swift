//
//  TransactionsManagerSpec.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import Quick
import Nimble
import Foundation
@testable import Transactions

final class TransactionsManagerSpec: AsyncSpec {
    override class func spec() {
        describe("Creating transactions") {
            it("should create and store transaction") {
                // Given
                let persistentData = try TestPersistentData()
                let manager = TransactionsManager(persistentData: persistentData)

                // When
                await manager.createTransaction(testTransaction)

                // Then
                expect(manager.transactions.count) == 1
                let expectedTransaction = testTransaction.setID(manager.transactions.first!.id!)
                expect(manager.transactions.first) == expectedTransaction
            }

            it("should create and store transaction and keep in memory when fetched") {
                // Given
                let persistentData = try TestPersistentData()
                let manager = TransactionsManager(persistentData: persistentData)

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
                // Given
                let persistentData = try TestPersistentData()
                let manager = TransactionsManager(persistentData: persistentData)

                // Sanity
                expect(manager.transactionsAreEmpty) == true

                // When
                try await manager.fetchTransactions()

                // Then
                expect(manager.transactionsAreEmpty) == true
            }

            it("should fetch stored transactions") {
                // Given
                let persistentData = try TestPersistentData()
                var manager = TransactionsManager(persistentData: persistentData)
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
