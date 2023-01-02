//
//  ForexClientTests.swift
//  
//
//  Created by Kamaal M Farah on 02/01/2023.
//

import XCTest
import Models
@testable import Backend

final class ForexClientTests: XCTestCase {
    func testGetCachedResultForLatest() {
        let client = ForexClient(preview: true)
        let cases: [(Currencies, [Currencies], [ExchangeRates], [Currencies : Double])] = [
            (.EUR, [.USD], [
                ExchangeRates(base: Currencies.EUR.rawValue, date: Date(), rates: [Currencies.USD.rawValue: 1.0666])
            ], [.USD: 1.0666]),
            (.EUR, [.USD], [
                ExchangeRates(base: Currencies.USD.rawValue, date: Date(), rates: [Currencies.EUR.rawValue: 0.9376])
            ], [.USD: 1.0666]),
        ]
        for (base, symbols, cachedExchangeRates, expectedResult) in cases {
            let cachedResult = client.getCachedResultForLatest(
                cachedExchangeRates: cachedExchangeRates,
                base: base,
                symbols: symbols)
            XCTAssertEqual(cachedResult, expectedResult)
        }
    }
}

//0,937558597412338
