//
//  MoneyTests.swift
//
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import XCTest
@testable import Models

final class MoneyTests: XCTestCase {
    func testDecodeMoneyFromString() throws {
        let cases = [
            ("1,127.0US$", Money(amount: 1127.0, currency: .USD)),
            ("US$1,127.0", Money(amount: 1127.0, currency: .USD)),
            ("€ 0,96", Money(amount: 0.96, currency: .EUR)),
            ("0,96 €", Money(amount: 0.96, currency: .EUR)),
            ("CA$ 420.69", Money(amount: 420.69, currency: .CAD)),
        ]
        for (input, expectedResult) in cases {
            let result = try XCTUnwrap(Money.fromString(string: input))
            XCTAssertEqual(result, expectedResult)
        }
    }
}
