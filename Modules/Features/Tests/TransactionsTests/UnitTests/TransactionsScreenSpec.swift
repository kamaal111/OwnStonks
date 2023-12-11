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
                expect(viewModel.shownSheet) == .addTransction
                expect(viewModel.showSheet) == true
            }

            it("should have the correct state by default") {
                // Given
                let viewModel = TransactionsScreen.ViewModel()

                // Then
                expect(viewModel.shownSheet).to(beNil())
                expect(viewModel.showSheet) == false
            }

            it("should reset sheet state on sheet dismissal") {
                // Given
                let viewModel = TransactionsScreen.ViewModel()
                viewModel.showAddTransactionSheet()

                // When
                viewModel.showSheet = false

                // Then
                expect(viewModel.shownSheet).to(beNil())
                expect(viewModel.showSheet) == false
            }
        }
    }
}
