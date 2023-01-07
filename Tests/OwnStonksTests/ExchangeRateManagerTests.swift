//
//  ExchangeRateManagerTests.swift
//  OwnStonksTests
//
//  Created by Kamaal M Farah on 07/01/2023.
//

import XCTest
import Backend
import Logster
import MockURLProtocol
@testable import OwnStonks

final class ExchangeRateManagerTests: XCTestCase {
    func testFetchFailure() async throws {
        MockURLProtocol.requestHandler = { _ in
            let statusCode = 400
            let jsonString = """
            {
                "message": "oh nooooo!"
            }
            """

            let response = HTTPURLResponse(
                url: URL(string: "https://kamaal.io")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!

            let data = jsonString.data(using: .utf8)
            return (response, data)
        }
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        let manager = ExchangeRateManager(backend: Backend(preview: false, urlSession: urlSession))
        await manager.fetch(preferedCurrency: .EUR)
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
