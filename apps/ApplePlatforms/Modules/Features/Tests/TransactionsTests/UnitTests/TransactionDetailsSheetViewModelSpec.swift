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
import KamaalExtensions
import ValutaConversion
@testable import Transactions

final class TransactionDetailsSheetViewModelSpec: AsyncSpec {
    override class func spec() {
        let url = URL(staticString: "https://kamaal.io")
        var cacheStorage: TestTransactionsQuickStorage!
        var transaction: AppTransaction!
        var stonksKit: StonksKit!

        beforeEach {
            cacheStorage = TestTransactionsQuickStorage()
            transaction = AppTransaction(
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
            stonksKit = StonksKit(baseURL: url, urlSession: urlSession, cacheStorage: cacheStorage)
        }

        describe("Fetch price per unit") {
            it("should fetch price per unit and convert price") {
                // Given
                let expectedTicker = "MSFT"
                let infoResponse = [
                    expectedTicker: StonksTickersInfoResponse(
                        name: "MicroShaft",
                        close: 200,
                        currency: Currencies.USD.rawValue,
                        closeDate: nil
                    ),
                ]
                try MockURLProtocol.makeRequests(with: [
                    .init(data: JSONEncoder().encode(testExchangeRates), statusCode: 200, url: url),
                    .init(data: JSONEncoder().encode(infoResponse), statusCode: 200, url: url),
                ])
                let valutaConversion = ValutaConversion(
                    symbols: testExchangeRates.ratesMappedByCurrency.keys.asArray(),
                    quickStorage: cacheStorage,
                    urlSession: urlSession,
                    failOnError: true,
                    skipCaching: true
                )
                try await valutaConversion.fetchExchangeRates(of: .EUR)
                let viewModel = TransactionDetailsSheet.ViewModel(
                    context: .edit(transaction),
                    urlSession: urlSession,
                    cacheStorage: cacheStorage
                )
                viewModel.setStonksKit(stonksKit)
                viewModel.pricePerUnitCurrency = .EUR
                viewModel.pricePerUnit = String(0.0)
                viewModel.autoTrackAsset = true
                viewModel.assetTicker = expectedTicker

                // When
                await viewModel.fetchPricePerUnit(valutaConversion: valutaConversion)

                // Then
                expect(viewModel.pricePerUnitCurrency) == .EUR
                expect(Double(viewModel.pricePerUnit)?.toFixed(2)) == "187.51"
            }

            it("should fetch price per unit but fail to convert price") {
                // Given
                let expectedTicker = "GHRD"
                let infoResponse = [
                    expectedTicker: StonksTickersInfoResponse(
                        name: "GigaHard",
                        close: 200,
                        currency: Currencies.USD.rawValue,
                        closeDate: nil
                    ),
                ]
                try MockURLProtocol.makeRequests(with: [
                    .init(data: JSONEncoder().encode(infoResponse), statusCode: 200, url: url),
                ])
                let valutaConversion = ValutaConversion(
                    symbols: testExchangeRates.ratesMappedByCurrency.keys.asArray(),
                    quickStorage: cacheStorage,
                    urlSession: urlSession,
                    failOnError: true,
                    skipCaching: true
                )
                let viewModel = TransactionDetailsSheet.ViewModel(
                    context: .edit(transaction),
                    urlSession: urlSession,
                    cacheStorage: cacheStorage
                )
                viewModel.setStonksKit(stonksKit)
                viewModel.pricePerUnitCurrency = .EUR
                viewModel.pricePerUnit = String(0.0)
                viewModel.autoTrackAsset = true
                viewModel.assetTicker = expectedTicker

                // When
                await viewModel.fetchPricePerUnit(valutaConversion: valutaConversion)

                // Then
                expect(viewModel.pricePerUnitCurrency) == .USD
                expect(Double(viewModel.pricePerUnit)?.toFixed(2)) == "200.00"
            }

            it("should fail to fetch price per unit") {
                // Given
                MockURLProtocol.makeRequests(with: [
                    .init(
                        data: #"{"message": "Oh no we failed, well you're just unlucky 🤷‍♂️"}"#.data(using: .utf8)!,
                        statusCode: 500,
                        url: url
                    ),
                ])
                let valutaConversion = ValutaConversion(
                    symbols: testExchangeRates.ratesMappedByCurrency.keys.asArray(),
                    quickStorage: cacheStorage,
                    urlSession: urlSession,
                    failOnError: true,
                    skipCaching: true
                )
                let viewModel = TransactionDetailsSheet.ViewModel(
                    context: .edit(transaction),
                    urlSession: urlSession,
                    cacheStorage: cacheStorage
                )
                viewModel.setStonksKit(stonksKit)
                viewModel.autoTrackAsset = true
                viewModel.assetTicker = "YES"

                // When
                await viewModel.fetchPricePerUnit(valutaConversion: valutaConversion)

                // Then
                expect(viewModel.showErrorAlert) == true
                expect(viewModel.errorAlertTitle) == NSLocalizedString(
                    "Failed to sync price",
                    bundle: .module,
                    comment: ""
                )
            }
        }

        describe("Finalize editing") {
            it("should validate ticker correctly when in edit context") {
                // Given
                let expectedTicker = "GOOG"
                let response = [
                    expectedTicker: StonksTickersInfoResponse(
                        name: transaction.name,
                        close: 300,
                        currency: Currencies.USD.rawValue,
                        closeDate: nil
                    ),
                ]
                try MockURLProtocol
                    .makeRequest(withResponse: response, statusCode: 200, url: URL(staticString: "https://kamaal.io"))
                let viewModel = TransactionDetailsSheet.ViewModel(
                    context: .edit(transaction),
                    urlSession: urlSession,
                    cacheStorage: cacheStorage
                )
                viewModel.setStonksKit(stonksKit)
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
                let response = [
                    expectedTicker: StonksTickersInfoResponse(
                        name: transaction.name,
                        close: 500,
                        currency: Currencies.USD.rawValue,
                        closeDate: nil
                    ),
                ]
                try MockURLProtocol
                    .makeRequests(with: [
                        .init(data: JSONEncoder().encode(response), statusCode: 200, url: url),
                        .init(data: Data(), statusCode: 200, url: url),
                    ])
                let viewModel = TransactionDetailsSheet.ViewModel(
                    context: .details(transaction),
                    urlSession: urlSession,
                    cacheStorage: cacheStorage
                )
                viewModel.setStonksKit(stonksKit)
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

            it("should skip validating ticker due to auto track set being set to false and unsets data source") {
                // Given
                let response = [
                    "SQ": StonksTickersInfoResponse(
                        name: "Block",
                        close: 69,
                        currency: Currencies.USD.rawValue,
                        closeDate: nil
                    ),
                ]
                try MockURLProtocol
                    .makeRequests(with: [
                        .init(data: JSONEncoder().encode(response), statusCode: 200, url: url),
                        .init(data: Data(), statusCode: 200, url: url),
                    ])
                let viewModel = TransactionDetailsSheet.ViewModel(
                    context: .details(transaction),
                    urlSession: urlSession,
                    cacheStorage: cacheStorage
                )
                viewModel.autoTrackAsset = true
                viewModel.assetTicker = response.keys.first!
                await viewModel.finalizeEditing(
                    close: { fail("Should not enter here") },
                    done: { _ in }
                )
                await viewModel.enableEditing()

                // When
                viewModel.autoTrackAsset = false
                var _finalTransaction: AppTransaction?
                await viewModel.finalizeEditing(
                    close: { fail("Should not enter here") },
                    done: { transaction in _finalTransaction = transaction }
                )

                // Then
                let finalTransaction = try XCTUnwrap(_finalTransaction)
                expect(finalTransaction.dataSource).to(beNil())
            }

            it("should alert due to ticker not being valid") {
                // Given
                MockURLProtocol.makeRequest(
                    withResponseJSONString: #"{"message": "Oh nooo we failed"}"#,
                    statusCode: 404,
                    url: URL(staticString: "https://kamaal.io")
                )
                let viewModel = TransactionDetailsSheet.ViewModel(
                    context: .edit(transaction),
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
                let viewModel = TransactionDetailsSheet.ViewModel(context: .edit(transaction))

                // When
                viewModel.name = ""

                // Then
                expect(viewModel.transaction).to(beNil())
                expect(viewModel.transactionIsValid) == false
            }

            it("should not be valid when auto track asset is enabled but data source is invalid") {
                // Given
                let viewModel = TransactionDetailsSheet.ViewModel(context: .edit(transaction))

                // When
                viewModel.autoTrackAsset = true
                viewModel.assetTicker = ""

                // When
                expect(viewModel.transactionIsValid) == false
            }

            it("should be valid when transaction is valid and auto track asset is disabled") {
                // Given
                let viewModel = TransactionDetailsSheet.ViewModel(context: .edit(transaction))

                // When
                viewModel.autoTrackAsset = false

                // When
                expect(viewModel.transactionIsValid) == true
            }

            it("should be valid when transaction is valid and auto track asset is enabled and data source is valid") {
                // Given
                let viewModel = TransactionDetailsSheet.ViewModel(context: .edit(transaction))

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
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .details(transaction))

                    // When
                    viewModel.pricePerUnitCurrency = .AUD

                    // Then
                    expect(viewModel.feesCurrency).to(equal(.AUD))
                    expect(viewModel.pricePerUnitCurrency).to(equal(.AUD))
                }

                it("should not set price per unit currency when fees currency changes") {
                    // Given
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .details(transaction))

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
                let viewModel = TransactionDetailsSheet.ViewModel(context: .details(transaction))

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
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .details(transaction))

                    // Then
                    expect(viewModel.transactionIsValid) == true
                    expect(viewModel.transaction) == transaction
                    expect(viewModel.context) == .details(transaction)
                    expect(viewModel.title) == transaction.name
                    expect(viewModel.isEditing) == false
                    expect(viewModel.feesCurrency) == transaction.fees.currency
                    expect(viewModel.pricePerUnitCurrency) == transaction.pricePerUnit.currency
                }
            }

            context("Edit context") {
                it("should set all the right default values") {
                    // Given
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .edit(transaction))

                    // Then
                    expect(viewModel.transactionIsValid) == true
                    expect(viewModel.transaction) == transaction
                    expect(viewModel.context) == .edit(transaction)
                    expect(viewModel.title) == transaction.name
                    expect(viewModel.isEditing) == true
                    expect(viewModel.feesCurrency) == transaction.fees.currency
                    expect(viewModel.pricePerUnitCurrency) == transaction.pricePerUnit.currency
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
