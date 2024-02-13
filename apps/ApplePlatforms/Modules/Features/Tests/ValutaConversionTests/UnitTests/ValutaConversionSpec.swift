//
//  ValutaConversionSpec.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import Quick
import Nimble
import XCTest
import ForexKit
import Foundation
import SharedModels
import MockURLProtocol
import KamaalExtensions
@testable import ValutaConversion

final class ValutaConversionSpec: AsyncSpec {
    override class func spec() {
        describe("Converting money") {
            it("should convert money correctly") {
                // Given
                try makeRequest(withResponse: JSONEncoder().encode(testExchangeRates), statusCode: 200)
                let storage = TestQuickStorage()
                let valutaConversion = ValutaConversion(
                    symbols: testExchangeRates.ratesMappedByCurrency.keys.asArray(),
                    quickStorage: storage,
                    urlSession: urlSession,
                    failOnError: true,
                    skipCaching: false
                )
                try await valutaConversion.fetchExchangeRates(of: .EUR)

                // When
                let result = valutaConversion.convertMoney(from: Money(value: 3000, currency: .JPY), to: .EUR)

                // Then
                expect(result?.currency) == .EUR
                expect(result?.value.int) == 21
            }

            it("should not be able to convert due to rates being fetched") {
                // Given
                let storage = TestQuickStorage()
                let valutaConversion = ValutaConversion(
                    symbols: testExchangeRates.ratesMappedByCurrency.keys.asArray(),
                    quickStorage: storage,
                    urlSession: urlSession,
                    failOnError: true,
                    skipCaching: false
                )

                // When
                let result = valutaConversion.convertMoney(from: Money(value: 3000, currency: .JPY), to: .EUR)

                // Then
                expect(result).to(beNil())
            }

            it("should not be able to convert due to exchange rate for a currency not being available") {
                // Given
                try makeRequest(withResponse: JSONEncoder().encode(testExchangeRates), statusCode: 200)
                let storage = TestQuickStorage()
                let valutaConversion = ValutaConversion(
                    symbols: testExchangeRates.ratesMappedByCurrency.keys.asArray(),
                    quickStorage: storage,
                    urlSession: urlSession,
                    failOnError: true,
                    skipCaching: false
                )
                try await valutaConversion.fetchExchangeRates(of: .EUR)

                // When
                let result = valutaConversion.convertMoney(from: Money(value: 420, currency: .PHP), to: .EUR)

                // Then
                expect(result).to(beNil())
            }
        }

        describe("Fetching exchange rates") {
            it("should fetch exchange rates successfully") {
                // Given
                try makeRequest(withResponse: JSONEncoder().encode(testExchangeRates), statusCode: 200)
                let storage = TestQuickStorage()
                let valutaConversion = ValutaConversion(
                    symbols: testExchangeRates.ratesMappedByCurrency.keys.asArray(),
                    quickStorage: storage,
                    urlSession: urlSession,
                    failOnError: true,
                    skipCaching: false
                )

                // When
                try await valutaConversion.fetchExchangeRates(of: .EUR)

                // Then
                expect(valutaConversion.rates) == testExchangeRates
                let storedExchangeRates = storage.exchangeRates?.values.flatMap { $0 }
                expect(storedExchangeRates?.count) == 1
                expect(storedExchangeRates?.first) == testExchangeRates
            }

            it("should use fallback when latest exchange rates call fails") {
                // Given
                let cacheDate = Date(timeIntervalSince1970: 1_702_681_200)
                makeRequest(withResponse: #"{ "message": "Failed!!!" }"#.data(using: .utf8)!, statusCode: 400)
                let storage = TestQuickStorage(exchangeRates: [cacheDate: [testExchangeRates]])
                let valutaConversion = ValutaConversion(
                    symbols: testExchangeRates.ratesMappedByCurrency.keys.asArray(),
                    quickStorage: storage,
                    urlSession: urlSession,
                    failOnError: false,
                    skipCaching: true
                )

                // When
                try await valutaConversion.fetchExchangeRates(of: .EUR)

                // Then
                expect(valutaConversion.rates?.base) == testExchangeRates.base
                expect(valutaConversion.rates?.rates) == testExchangeRates.rates
                expect(valutaConversion.rates?.date) == cacheDate
            }

            it("should throw error because no rates could be fetched") {
                // Given
                makeRequest(withResponse: #"{ "message": "AAAAAHHHHH!!!" }"#.data(using: .utf8)!, statusCode: 400)
                let storage = TestQuickStorage()
                let valutaConversion = ValutaConversion(
                    symbols: testExchangeRates.ratesMappedByCurrency.keys.asArray(),
                    quickStorage: storage,
                    urlSession: urlSession,
                    failOnError: false,
                    skipCaching: false
                )

                // Then
                do {
                    try await valutaConversion.fetchExchangeRates(of: .EUR)
                    fail("Should have failed")
                } catch { }
            }
        }
    }
}

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

private let urlSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: configuration)
}()

private func makeRequest(withResponse responseJSON: Data, statusCode: Int) {
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(
            url: URL(string: "https://kamaal.io")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!

        let data = responseJSON
        return (response, data)
    }
}
