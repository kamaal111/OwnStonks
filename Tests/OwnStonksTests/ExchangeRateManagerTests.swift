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

    func testFetchFailure() async throws {
        makeResponse(with: "{\"message\": \"oh noooo!\"}", status: 400)

        await manager.fetch(preferedCurrency: .EUR)
        try await Task.sleep(milliSeconds: 50) // How else do wait untill the logs have been synced? 🤷‍♂️

        let maybeError = await logHolder.logs.first(where: { $0.type == .error })
        let error = try XCTUnwrap(maybeError)
        print(error)
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
