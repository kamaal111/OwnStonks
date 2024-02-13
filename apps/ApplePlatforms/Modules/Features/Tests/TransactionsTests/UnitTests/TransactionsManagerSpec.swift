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
import ForexKit
import StonksKit
import Foundation
import SharedUtils
import SharedModels
import PersistentData
import MockURLProtocol
import KamaalExtensions
import ValutaConversion
@testable import Transactions

final class TransactionsManagerSpec: AsyncSpec {
    override class func spec() {
        var persistentData: TestPersistentData!
        var quickStorage: TestTransactionsQuickStorage!
        var manager: TransactionsManager!
        var valutaConversion: ValutaConversion!
        let url = URL(staticString: "https://kamaal.io")

        beforeEach {
            persistentData = try TestPersistentData()
            quickStorage = TestTransactionsQuickStorage()
            manager = TransactionsManager(
                persistentData: persistentData,
                quickStorage: quickStorage,
                urlSession: urlSession
            )
            valutaConversion = ValutaConversion(
                symbols: testExchangeRates.ratesMappedByCurrency.keys.asArray(),
                quickStorage: quickStorage,
                urlSession: urlSession,
                failOnError: true,
                skipCaching: true
            )
        }

        describe("Fetch closes") {
            it("should fetch closes successfully") {
                // Given
                let infoResponse = [
                    testTransactionWithDataSource.dataSource!.ticker: StonksTickersInfoResponse(
                        name: testTransactionWithDataSource.name,
                        close: 222,
                        currency: Currencies.USD.rawValue,
                        closeDate: nil
                    ),
                ]
                try MockURLProtocol
                    .makeRequests(with: [
                        .init(data: JSONEncoder().encode(testExchangeRates), statusCode: 200, url: url),
                        .init(data: JSONEncoder().encode(infoResponse), statusCode: 200, url: url),
                    ])
                try await valutaConversion.fetchExchangeRates(of: .EUR)
                try await manager.createTransaction(testTransactionWithDataSource)

                // When
                await manager.fetchCloses(valutaConversion: valutaConversion, preferredCurrency: .EUR)

                // Then
                expect(manager.previousCloses.count) == 1
                let previousClose = try XCTUnwrap(
                    manager.previousCloses[testTransactionWithDataSource.dataSource!.ticker]
                )
                expect(previousClose.currency) == .EUR
                expect(previousClose.value.toFixed(2)) == "208.14"
            }
        }

        describe("Handle iCloud changes") {
            it("should have a manager with pending cloud storage changes set to false by default") {
                // Then
                expect(quickStorage.pendingCloudChanges) == false
            }

            it("should set pending cloud changes to true after notification received") {
                // Given
                let testTransaction = testTransaction.setID(UUID())
                persistentData.cloudResponse = [[testTransaction.asCKRecord]]

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
                persistentData.cloudResponse = [[testTransaction.asCKRecord]]

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
                persistentData.cloudResponse = [[transaction.asCKRecord]]

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
                    dataSource: nil,
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
                    dataSource: nil,
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
                manager = TransactionsManager(
                    persistentData: persistentData,
                    quickStorage: quickStorage,
                    urlSession: urlSession
                )
                try await manager.fetchTransactions()

                // Then
                expect(manager.transactions.count) == 1
            }
        }
    }
}

private let urlSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: configuration)
}()

private let testTransaction = AppTransaction(
    name: "Apple",
    transactionDate: Date(),
    transactionType: .buy,
    amount: 25,
    pricePerUnit: Money(value: 100, currency: .USD),
    fees: Money(value: 1, currency: .EUR),
    dataSource: nil,
    updatedDate: Date(),
    creationDate: Date()
)

let testTransactionWithDataSource = AppTransaction(
    name: "Apple",
    transactionDate: Date(),
    transactionType: .buy,
    amount: 25,
    pricePerUnit: Money(value: 100, currency: .USD),
    fees: Money(value: 1, currency: .EUR),
    dataSource: .init(
        sourceType: .stocks,
        ticker: "AAPL",
        updatedDate: Date(),
        creationDate: Date(),
        transactionRecordID: nil,
        recordID: nil
    ),
    updatedDate: Date(),
    creationDate: Date()
)

private let testExchangeRates = ExchangeRates(
    base: .EUR,
    date: Date(timeIntervalSince1970: 1_672_358_400),
    rates: [
        .CAD: 1.444,
        .GBP: 0.88693,
        .JPY: 140.66,
        .TRY: 19.9649,
        .USD: 1.0666,
    ]
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
            dataSource: nil,
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
