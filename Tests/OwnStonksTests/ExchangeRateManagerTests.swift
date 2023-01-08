//
//  ExchangeRateManagerTests.swift
//  OwnStonksTests
//
//  Created by Kamaal M Farah on 07/01/2023.
//

import XCTest
import Backend
import Logster
import Environment
import MockURLProtocol
@testable import OwnStonks

final class ExchangeRateManagerTests: XCTestCase {
    var logHolder: LogHolder!
    var manager: ExchangeRateManager!

    override func setUpWithError() throws {
        Environment.CommandLineArguments.inject(.skipForexCaching)
        logHolder = LogHolder()
        let logger = Logster(from: ExchangeRateManagerTests.self, holder: logHolder)
        manager = ExchangeRateManager(backend: Backend(preview: false, urlSession: urlSession), logger: logger)
    }

    override func tearDownWithError() throws {
        Environment.CommandLineArguments.remove(.skipForexCaching)
    }

    lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }()

    func testFetch() async throws {
        let response = """
{
    "base": "EUR",
    "date": "2022-12-30",
    "rates": {
        "CAD": 1.444,
        "GBP": 0.88693,
        "JPY": 140.66,
        "TRY": 19.9649,
        "USD": 1.0666
    }
}
"""
        makeResponse(with: response, status: 200)
        await manager.fetch(preferedCurrency: .EUR)

        let exchangeRates = try XCTUnwrap(manager.exchangeRates)
        XCTAssertEqual(exchangeRates.baseCurrency, .EUR)
        let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: exchangeRates.date)
        XCTAssertEqual(dateComponents.day, 30)
        XCTAssertEqual(dateComponents.month, 12)
        XCTAssertEqual(dateComponents.year, 2022)
        XCTAssertEqual(exchangeRates.ratesMappedByCurrency[.CAD], 1.444)
        XCTAssertEqual(exchangeRates.ratesMappedByCurrency[.USD], 1.0666)
        XCTAssertNil(exchangeRates.ratesMappedByCurrency[.EUR])
    }

    func testFetchFailure() async throws {
        makeResponse(with: "{\"message\": \"oh noooo!\"}", status: 400)

        await manager.fetch(preferedCurrency: .EUR)
        try await Task.sleep(milliSeconds: 40) // How else do wait untill the logs have been synced? 🤷‍♂️

        let maybeError = await logHolder.logs.first(where: { $0.type == .error })
        let error = try XCTUnwrap(maybeError)
        XCTAssert(error.message.contains("oh noooo!"))
        XCTAssertNil(manager.exchangeRates)
    }

    func makeResponse(with responseBody: String, status: Int) {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://kamaal.io")!,
                statusCode: status,
                httpVersion: nil,
                headerFields: nil
            )!

            let data = responseBody.data(using: .utf8)
            return (response, data)
        }
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }

    static func sleep(milliSeconds: Double) async throws {
        try await sleep(seconds: milliSeconds / 1000)
    }
}

private let forexData = """
{
    "base": "EUR",
    "date": "2022-12-30",
    "rates": {
        "CAD": 1.444
    }
}
"""
