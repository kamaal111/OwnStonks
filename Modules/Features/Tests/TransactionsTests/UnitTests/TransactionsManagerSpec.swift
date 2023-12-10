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
                let persistentData = try TestPersistentData()
                let manager = TransactionsManager(persistentData: persistentData)

                await manager.createTransaction(testTransaction)

                expect(manager.transactions.count) == 1
                let expectedTransaction = testTransaction.setID(manager.transactions.first!.id!)
                expect(manager.transactions.first) == expectedTransaction
            }

            it("should create and store transaction and keep in memory when fetched") {
                let persistentData = try TestPersistentData()
                let manager = TransactionsManager(persistentData: persistentData)

                await manager.createTransaction(testTransaction)
                try await manager.fetchTransactions()

                expect(manager.transactions.count) == 1
                let expectedTransaction = testTransaction.setID(manager.transactions.first!.id!)
                expect(manager.transactions.first) == expectedTransaction
            }
        }

        describe("Fetching transactions") {
            it("should fetch transactions with a empty container") {
                let persistentData = try TestPersistentData()
                let manager = TransactionsManager(persistentData: persistentData)

                expect(manager.transactionsAreEmpty) == true

                try await manager.fetchTransactions()

                expect(manager.transactionsAreEmpty) == true
            }

            it("should fetch stored transactions") {
                let persistentData = try TestPersistentData()
                var manager = TransactionsManager(persistentData: persistentData)
                await manager.createTransaction(testTransaction)

                expect(manager.transactions.count) == 1

                manager = TransactionsManager(persistentData: persistentData)

                try await manager.fetchTransactions()

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
