//
//  TransactionDetailsSheetViewModelSpec.swift
//
//
//  Created by Kamaal M Farah on 11/12/2023.
//

import Quick
import Nimble
import XCTest
import ForexKit
import StonksKit
import Foundation
import SharedModels
import MockURLProtocol
@testable import Transactions

final class TransactionDetailsSheetViewModelSpec: AsyncSpec {
    override class func spec() {
        describe("Finalize editing") {
            it("should validate ticker correctly when in edit context") {
                // Given
                let expectedTicker = "GOOG"
                let response = StonksTickersInfoResponse(
                    name: testTransaction.name,
                    close: 300,
                    currency: Currencies.USD.rawValue,
                    symbol: expectedTicker,
                    closeDate: nil
                )
                try makeRequest(withResponse: response, statusCode: 200)
                let cacheStorage = TestTransactionsQuickStorage()
                let viewModel = TransactionDetailsSheet.ViewModel(
                    context: .edit(testTransaction),
                    urlSession: urlSession,
                    cacheStorage: cacheStorage
                )
                viewModel.autoTrackAsset = true
                viewModel.assetTicker = expectedTicker

                // When
                var _finalTransaction: AppTransaction?
                var closed = false
                await viewModel.finalizeEditing(
                    close: { closed = true },
                    done: { transaction in _finalTransaction = transaction }
                )

                // Then
                let finalTransaction = try XCTUnwrap(_finalTransaction)
                expect(finalTransaction.dataSource?.ticker) == expectedTicker
                expect(closed) == true
            }

            it("should validate ticker correctly when in details context") {
                // Given
                let expectedTicker = "AAPL"
                let response = StonksTickersInfoResponse(
                    name: testTransaction.name,
                    close: 500,
                    currency: Currencies.USD.rawValue,
                    symbol: expectedTicker,
                    closeDate: nil
                )
                try makeRequest(withResponse: response, statusCode: 200)
                let cacheStorage = TestTransactionsQuickStorage()
                let viewModel = TransactionDetailsSheet.ViewModel(
                    context: .details(testTransaction),
                    urlSession: urlSession,
                    cacheStorage: cacheStorage
                )
                viewModel.autoTrackAsset = true
                viewModel.assetTicker = expectedTicker

                // When
                var _finalTransaction: AppTransaction?
                await viewModel.finalizeEditing(
                    close: { fail("Should not enter here") },
                    done: { transaction in _finalTransaction = transaction }
                )

                // Then
                let finalTransaction = try XCTUnwrap(_finalTransaction)
                expect(finalTransaction.dataSource?.ticker) == expectedTicker
                expect(viewModel.isEditing) == false
            }

            it("should alert due to ticker not being valid") {
                // Given
                makeRequest(withResponseData: #"{"message": "Oh nooo we failed"}"#.data(using: .utf8)!, statusCode: 404)
                let cacheStorage = TestTransactionsQuickStorage()
                let viewModel = TransactionDetailsSheet.ViewModel(
                    context: .edit(testTransaction),
                    urlSession: urlSession,
                    cacheStorage: cacheStorage
                )
                viewModel.autoTrackAsset = true
                viewModel.assetTicker = "GOOG"

                // When
                await viewModel.finalizeEditing(
                    close: { fail("Should not enter here") },
                    done: { _ in fail("Should not enter here") }
                )

                // Then
                expect(viewModel.showErrorAlert) == true
                expect(viewModel.errorAlertTitle) == NSLocalizedString(
                    "Invalid ticker provided",
                    bundle: .module,
                    comment: ""
                )
            }
        }

        describe("Transction is valid") {
            it("should not be valid when editing transaction is nil") {
                // Given
                let viewModel = TransactionDetailsSheet.ViewModel(context: .edit(testTransaction))

                // When
                viewModel.name = ""

                // Then
                expect(viewModel.transaction).to(beNil())
                expect(viewModel.transactionIsValid) == false
            }

            it("should not be valid when auto track asset is enabled but data source is invalid") {
                // Given
                let viewModel = TransactionDetailsSheet.ViewModel(context: .edit(testTransaction))

                // When
                viewModel.autoTrackAsset = true
                viewModel.assetTicker = ""

                // When
                expect(viewModel.transactionIsValid) == false
            }

            it("should be valid when transaction is valid and auto track asset is disabled") {
                // Given
                let viewModel = TransactionDetailsSheet.ViewModel(context: .edit(testTransaction))

                // When
                viewModel.autoTrackAsset = false

                // When
                expect(viewModel.transactionIsValid) == true
            }

            it("should be valid when transaction is valid and auto track asset is enabled and data source is valid") {
                // Given
                let viewModel = TransactionDetailsSheet.ViewModel(context: .edit(testTransaction))

                // When
                viewModel.autoTrackAsset = true
                viewModel.assetTicker = "GOOG"

                // When
                expect(viewModel.transactionIsValid) == true
            }
        }

        describe("State changes") {
            context("Fees and price per unit currency changes") {
                it("should set fees currency when price per unit changes") {
                    // Given
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .details(testTransaction))

                    // When
                    viewModel.pricePerUnitCurrency = .AUD

                    // Then
                    expect(viewModel.feesCurrency).to(equal(.AUD))
                    expect(viewModel.pricePerUnitCurrency).to(equal(.AUD))
                }

                it("should not set price per unit currency when fees currency changes") {
                    // Given
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .details(testTransaction))

                    // When
                    viewModel.feesCurrency = .JPY

                    // Then
                    expect(viewModel.feesCurrency).to(equal(.JPY))
                    expect(viewModel.pricePerUnitCurrency).to(equal(.USD))
                }
            }
        }

        describe("Toggling editing") {
            it("should toggle editing on") {
                // Given
                let viewModel = TransactionDetailsSheet.ViewModel(context: .details(testTransaction))

                // When
                await viewModel.enableEditing()

                // Then
                expect(viewModel.isEditing) == true
            }

            it("should toggle editing off") {
                // Given
                let viewModel = TransactionDetailsSheet.ViewModel(context: .new(.BGN))

                // When
                await viewModel.disableEditing()

                // Then
                expect(viewModel.isEditing) == false
            }
        }

        describe("Context initializers") {
            context("Details context") {
                it("should set all the right default values") {
                    // Given
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .details(testTransaction))

                    // Then
                    expect(viewModel.transactionIsValid) == true
                    expect(viewModel.transaction) == testTransaction
                    expect(viewModel.context) == .details(testTransaction)
                    expect(viewModel.title) == testTransaction.name
                    expect(viewModel.isEditing) == false
                    expect(viewModel.feesCurrency) == testTransaction.fees.currency
                    expect(viewModel.pricePerUnitCurrency) == testTransaction.pricePerUnit.currency
                }
            }

            context("Edit context") {
                it("should set all the right default values") {
                    // Given
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .edit(testTransaction))

                    // Then
                    expect(viewModel.transactionIsValid) == true
                    expect(viewModel.transaction) == testTransaction
                    expect(viewModel.context) == .edit(testTransaction)
                    expect(viewModel.title) == testTransaction.name
                    expect(viewModel.isEditing) == true
                    expect(viewModel.feesCurrency) == testTransaction.fees.currency
                    expect(viewModel.pricePerUnitCurrency) == testTransaction.pricePerUnit.currency
                }
            }

            context("New context") {
                it("should set all the right default values") {
                    // Given
                    let preferredCurrency: Currencies = .CAD
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .new(preferredCurrency))

                    // Then
                    expect(viewModel.transactionIsValid) == false
                    expect(viewModel.context) == .new(preferredCurrency)
                    expect(viewModel.transaction).to(beNil())
                    expect(viewModel.title) == NSLocalizedString("Add Transaction", bundle: .module, comment: "")
                    expect(viewModel.isEditing) == true
                    expect(viewModel.feesCurrency) == preferredCurrency
                    expect(viewModel.pricePerUnitCurrency) == preferredCurrency
                }
            }
        }
    }
}

private let urlSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: configuration)
}()

private func makeRequest(withResponse responseJSON: some Encodable, statusCode: Int) throws {
    let data = try JSONEncoder().encode(responseJSON)
    makeRequest(withResponseData: data, statusCode: statusCode)
}

private func makeRequest(withResponseData responseJSON: Data, statusCode: Int) {
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(
            url: URL(string: "https://kamaal.io")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!

        return (response, responseJSON)
    }
}

private let testTransaction = AppTransaction(
    id: UUID(uuidString: "7d28a378-6c12-4d92-8843-baf2e2a9bcdc")!,
    name: "Google",
    transactionDate: Date(timeIntervalSince1970: 1_702_328_316),
    transactionType: .sell,
    amount: 100,
    pricePerUnit: Money(value: 500, currency: .USD),
    fees: Money(value: 3.2, currency: .EUR),
    dataSource: nil,
    updatedDate: Date(timeIntervalSince1970: 1_702_328_316),
    creationDate: Date(timeIntervalSince1970: 1_702_328_316)
)
