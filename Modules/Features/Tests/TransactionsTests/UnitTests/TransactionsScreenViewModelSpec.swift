//
//  TransactionsScreenViewModelSpec.swift
//
//
//  Created by Kamaal M Farah on 26/11/2023.
//

import Quick
import Nimble
import Foundation
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

            it("should open transaction details sheet") {
                // When
                viewModel.handleTransactionPress(testTransaction)

                expect(viewModel.shownSheet) == .transactionDetails(testTransaction)
                expect(viewModel.showSheet) == true
            }

            it("should have the correct state by default") {
                // Then
                expect(viewModel.shownSheet).to(beNil())
                expect(viewModel.showSheet) == false
            }

            it("should reset sheet state on sheet dismissal by setting showSheet to false") {
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

private let testTransaction = AppTransaction(
    id: UUID(uuidString: "519c218b-79c6-4f13-b38b-d8c7b5d0d3f5")!,
    name: "Shopify",
    transactionDate: Date(timeIntervalSince1970: 1_702_741_633),
    transactionType: .buy,
    amount: 200,
    pricePerUnit: Money(value: 500, currency: .CAD),
    fees: Money(value: 3.2, currency: .USD)
)
