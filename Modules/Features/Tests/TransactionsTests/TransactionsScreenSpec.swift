//
//  TransactionsScreenSpec.swift
//
//
//  Created by Kamaal M Farah on 26/11/2023.
//

import Quick
import Nimble
import XCTest
@testable import Transactions

final class TransactionsScreenSpec: QuickSpec {
    override class func spec() {
        describe("ViewModel sheet state") {
            it("should show add transaction sheet") {
                // Given
                let viewModel = TransactionsScreen.ViewModel()

                // When
                viewModel.showAddTransactionSheet()

                // Then
                XCTAssertEqual(viewModel.shownSheet, .addTransction)
                XCTAssert(viewModel.showSheet)
            }

            it("should have the correct state by default") {
                // Given
                let viewModel = TransactionsScreen.ViewModel()

                // Then
                XCTAssertNil(viewModel.shownSheet)
                XCTAssertFalse(viewModel.showSheet)
            }

            it("should reset sheet state on sheet dismissal") {
                // Given
                let viewModel = TransactionsScreen.ViewModel()
                viewModel.showAddTransactionSheet()

                // When
                viewModel.showSheet = false

                // Then
                XCTAssertNil(viewModel.shownSheet)
                XCTAssertFalse(viewModel.showSheet)
            }
        }
    }
}
