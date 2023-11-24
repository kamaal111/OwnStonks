//
//  CSVUtilsTests.swift
//
//
//  Created by Kamaal M Farah on 06/01/2023.
//

import XCTest
@testable import CSVUtils

final class CSVUtilsTests: XCTestCase {
    let testData = """
    Date;Type;Name;Amount;Per unit;Fees
    1/10/22;Buy;Apple;30;€ 123,12;€ 0,00
    04/05/22;Buy;Uber;20;US$ 20,00;€ 0,96
    """

    func testDecode() throws {
        let expectedResult: [TestType] = [
            .init(type: "Buy", name: "Apple", perUnit: "€ 123,12", amount: "30", fees: "€ 0,00", date: "1/10/22"),
            .init(type: "Buy", name: "Uber", perUnit: "US$ 20,00", amount: "20", fees: "€ 0,96", date: "04/05/22"),
        ]
        let result: [TestType] = try CSVUtils.decode(data: testData.data(using: .utf8)!, seperator: ";")
        XCTAssertEqual(result, expectedResult)
    }
}

struct TestType: Codable, Equatable {
    let type: String
    let name: String
    let perUnit: String
    let amount: String
    let fees: String
    let date: String

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case name = "Name"
        case perUnit = "Per unit"
        case amount = "Amount"
        case fees = "Fees"
        case date = "Date"
    }
}
