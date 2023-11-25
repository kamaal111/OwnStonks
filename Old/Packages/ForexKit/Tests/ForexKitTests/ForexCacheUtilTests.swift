//
//  ForexCacheUtilTests.swift
//
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import XCTest
@testable import ForexKit

final class ForexCacheUtilTests: XCTestCase {
    func testGetFallbackFromCompleteEntryWithSameBase() throws {
        let expectedResult = ExchangeRates(base: .CAD, date: Date(), rates: [.EUR: 420, .USD: 69])
        let initialCacheContainerData = [Date(): [expectedResult]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let cacheUtil = ForexCacheUtil(container: container)

        let result = try XCTUnwrap(cacheUtil.getFallback(base: .CAD, symbols: [.EUR, .USD]))
        XCTAssertEqual(result.base, expectedResult.base)
        XCTAssertEqual(result.date, expectedResult.date)
        XCTAssertEqual(result.rates, expectedResult.rates)
    }

    func testGetFallbackFromPartialyCompleteEntryWithSameBase() throws {
        let initialCacheContainerData = [Date(): [
            ExchangeRates(base: .CAD, date: Date(), rates: [.EUR: 420]),
            ExchangeRates(base: .USD, date: Date(), rates: [.CAD: 2]),
        ]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let cacheUtil = ForexCacheUtil(container: container)

        let result = try XCTUnwrap(cacheUtil.getFallback(base: .CAD, symbols: [.EUR, .USD]))
        XCTAssertEqual(result.baseCurrency, .CAD)
        XCTAssertEqual(result.ratesMappedByCurrency, [.EUR: 420, .USD: 0.5])
    }

    func testGetFallbackFromNonBaseEntry() throws {
        let initialCacheContainerData = [Date(): [
            ExchangeRates(base: .EUR, date: Date(), rates: [.CAD: 0.5]),
            ExchangeRates(base: .USD, date: Date(), rates: [.CAD: 2]),
        ]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let cacheUtil = ForexCacheUtil(container: container)

        let result = try XCTUnwrap(cacheUtil.getFallback(base: .CAD, symbols: [.EUR, .USD]))
        XCTAssertEqual(result.baseCurrency, .CAD)
        XCTAssertEqual(result.ratesMappedByCurrency, [.EUR: 2, .USD: 0.5])
    }

    func testGetFallbackNotFound() throws {
        let initialCacheContainerData = [Date(): [
            ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 0.5]),
        ]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let cacheUtil = ForexCacheUtil(container: container)

        let result = cacheUtil.getFallback(base: .EUR, symbols: [.CAD])

        XCTAssertNil(result)
    }

    func testGetFallbackWithInvalidSymbols() {
        let cases: [(Currencies, [Currencies])] = [
            (.CAD, []),
            (.CAD, [.CAD]),
        ]

        let initialCacheContainerData = [Date(): [ExchangeRates(
            base: .CAD,
            date: Date(),
            rates: [.EUR: 420, .USD: 69]
        )]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let cacheUtil = ForexCacheUtil(container: container)
        for (base, symbols) in cases {
            let result = cacheUtil.getFallback(base: base, symbols: symbols)
            XCTAssertNil(result)
        }
    }

    func testGetFallbackWithNoCache() {
        let container = TestCacheContainer(exchangeRates: nil)
        let cacheUtil = ForexCacheUtil(container: container)
        XCTAssertNil(cacheUtil.getFallback(base: .EUR, symbols: [.CAD]))
    }

    func testCacheLatestWithInvalidSymbols() async throws {
        let cases: [[Currencies]] = [
            [],
            [.EUR],
        ]
        for symbols in cases {
            let client = ForexCacheUtil(container: TestCacheContainer())

            let result = try await client.cacheLatest(base: .EUR, symbols: symbols, apiCall: { _, _ in
                XCTFail("Should be unreachable")
                return .failure(.responseError(message: "Will not come here anyway", code: 420))
            }).get()

            XCTAssertNil(result)
        }
    }

    func testCacheLatestWithNoCache() async throws {
        let cases: [[Date: [ExchangeRates]]?] = [
            nil,
            [:],
            [Date(): []],
            [Date().addingTimeInterval(-86401): [ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 420])]],
        ]

        for initialCacheContainerData in cases {
            let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
            let client = ForexCacheUtil(container: container)
            let expectedResult = ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 1.0666])

            var called = false
            let result = await client.cacheLatest(base: .EUR, symbols: [.USD], apiCall: { _, _ in
                called = true
                return .success(expectedResult)
            })

            XCTAssert(called)
            XCTAssertEqual(try result.get(), expectedResult)
            let cachedExchangeRates = try XCTUnwrap(container.exchangeRates)
            XCTAssertEqual(cachedExchangeRates.count, 1)
            let exchangeRates = try XCTUnwrap(cachedExchangeRates.first?.value)
            XCTAssertEqual(exchangeRates.count, 1)
            let exchangeRate = try XCTUnwrap(exchangeRates.first)
            XCTAssertEqual(exchangeRate, expectedResult)
        }
    }

    func testCacheLatestWithFullCacheFound() async throws {
        let cases: [(Currencies, [Currencies], ExchangeRates)] = [
            (.EUR, [.USD, .CAD], ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 1.0666, .CAD: 1.444])),
        ]
        for (base, symbols, expectedResult) in cases {
            let initialCacheContainerData = [Date(): [expectedResult]]
            let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
            let client = ForexCacheUtil(container: container)

            let result = try await client.cacheLatest(base: base, symbols: symbols, apiCall: { _, _ in
                XCTFail("Should be unreachable")
                return .failure(.responseError(message: "Will not come here anyway", code: 69))
            }).get()

            let unwrappedResult = try XCTUnwrap(result)
            XCTAssertEqual(unwrappedResult.base, expectedResult.base)
            XCTAssertEqual(unwrappedResult.rates, expectedResult.rates)

            let cachedExchangeRates = try XCTUnwrap(container.exchangeRates)
            XCTAssertEqual(cachedExchangeRates.count, 1)
            let exchangeRates = try XCTUnwrap(cachedExchangeRates.first?.value)
            XCTAssertEqual(exchangeRates.count, 1)
            let exchangeRate = try XCTUnwrap(exchangeRates.first)
            XCTAssertEqual(exchangeRate, unwrappedResult)
        }
    }

    func testCacheLatestWithConversion() async throws {
        let base: Currencies = .CAD
        let symbols: [Currencies] = [.EUR, .USD]
        let initialCacheContainerData = [Date(): [
            ExchangeRates(base: .EUR, date: Date(), rates: [.CAD: 0.6925]),
            ExchangeRates(base: .USD, date: Date(), rates: [.CAD: 1.36]),
        ]]
        let expectedRates: [Currencies: Double] = [.EUR: 1.444, .USD: 0.7353]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let client = ForexCacheUtil(container: container)

        let result = try await client.cacheLatest(base: base, symbols: symbols, apiCall: { _, _ in
            XCTFail("Should be unreachable")
            return .failure(.responseError(message: "Will not come here anyway", code: 69))
        }).get()

        let unwrappedResult = try XCTUnwrap(result)
        let expectedResult = ExchangeRates(base: base, date: unwrappedResult.date, rates: expectedRates)
        XCTAssertEqual(unwrappedResult, expectedResult)

        let cachedExchangeRates = try XCTUnwrap(container.exchangeRates)
        XCTAssertEqual(cachedExchangeRates.count, 1)
        let exchangeRates = try XCTUnwrap(cachedExchangeRates.first?.value)
        XCTAssertEqual(exchangeRates.count, initialCacheContainerData.first!.value.count + 1)
        let exchangeRate = try XCTUnwrap(exchangeRates.first(where: { $0.base == base.rawValue }))
        XCTAssertEqual(exchangeRate, unwrappedResult)
    }

    func testCacheLatestWithPartialCacheFound() async throws {
        let initialCacheContainerData = [Date(): [ExchangeRates(base: .EUR, date: Date(), rates: [.CAD: 1.444])]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let client = ForexCacheUtil(container: container)

        var called = false
        let result = try await client.cacheLatest(base: .EUR, symbols: [.USD, .CAD], apiCall: { _, _ in
            called = true
            return .success(ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 1.0666]))
        }).get()

        XCTAssert(called)
        let unwrappedResult = try XCTUnwrap(result)
        let expectedResult = ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 1.0666, .CAD: 1.444])
        XCTAssertEqual(unwrappedResult.base, expectedResult.base)
        XCTAssertEqual(unwrappedResult.rates, expectedResult.rates)

        let cachedExchangeRates = try XCTUnwrap(container.exchangeRates)
        XCTAssertEqual(cachedExchangeRates.count, 1)
        let exchangeRates = try XCTUnwrap(cachedExchangeRates.first?.value)
        XCTAssertEqual(exchangeRates.count, 1)
        let exchangeRate = try XCTUnwrap(exchangeRates.first)
        XCTAssertEqual(exchangeRate, unwrappedResult)
    }

    func testCacheLatestWithFailure() async throws {
        let client = ForexCacheUtil(container: TestCacheContainer())

        let result = await client.cacheLatest(base: .EUR, symbols: [.USD, .CAD], apiCall: { _, _ in
            .failure(.notAValidJSON)
        })

        XCTAssertEqual(result, .failure(.notAValidJSON))
    }
}

class TestCacheContainer: CacheContainerable {
    var exchangeRates: [Date: [ExchangeRates]]?

    init(exchangeRates: [Date: [ExchangeRates]]? = nil) {
        self.exchangeRates = exchangeRates
    }
}