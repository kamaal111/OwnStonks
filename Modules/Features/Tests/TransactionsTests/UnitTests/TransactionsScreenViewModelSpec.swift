//
//  TransactionsScreenViewModelSpec.swift
//
//
//  Created by Kamaal M Farah on 26/11/2023.
//

import Quick
import Nimble
@testable import Transactions

final class TransactionsScreenViewModelSpec: QuickSpec {
    override class func spec() {
        var viewModel: TransactionsScreen.ViewModel!

        beforeEach {
            viewModel = TransactionsScreen.ViewModel()
        }

        describe("ViewModel sheet state") {
            it("should show add transaction sheet") {
                // When
                viewModel.showAddTransactionSheet()

                // Then
                expect(viewModel.shownSheet) == .addTransction
                expect(viewModel.showSheet) == true
            }

            it("should have the correct state by default") {
                // Then
                expect(viewModel.shownSheet).to(beNil())
                expect(viewModel.showSheet) == false
            }

            it("should reset sheet state on sheet dismissal") {
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
