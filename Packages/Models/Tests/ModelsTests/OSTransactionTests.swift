//
//  OSTransactionTests.swift
//  
//
//  Created by Kamaal M Farah on 06/01/2023.
//

import XCTest
@testable import Models

final class OSTransactionTests: XCTestCase {
    let testData = """
Date;Type;Name;Amount;Per unit;Fees
1/10/22;Buy;Apple;30;€ 123,12;€ 0,00
04/05/22;Buy;Uber;20;US$ 20,00;€ 0,96
"""

    func testDecodeFromCSVTOOSTransaction() throws {
        let data = try XCTUnwrap(testData.data(using: .utf8))
        let result = try OSTransaction.fromCSV(data: data, seperator: ";")
        let expectedResult = [
            OSTransaction(
                id: nil,
                assetName: "Apple",
                date: YearMonthDayStrategy.dateFormatter.date(from: "1/10/22")!,
                type: .buy,
                amount: 30,
                pricePerUnit: Money(amount: 123.12, currency: .EUR),
                fees: Money(amount: 0, currency: .EUR)),
            OSTransaction(
                id: nil,
                assetName: "Uber",
                date: YearMonthDayStrategy.dateFormatter.date(from: "04/05/22")!,
                type: .buy,
                amount: 20,
                pricePerUnit: Money(amount: 20, currency: .USD),
                fees: Money(amount: 0.96, currency: .EUR)),
        ]
        XCTAssertEqual(result, expectedResult)
    }
}
