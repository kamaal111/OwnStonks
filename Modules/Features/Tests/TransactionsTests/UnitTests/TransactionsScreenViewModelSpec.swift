//
//  TransactionsScreenViewModelSpec.swift
//
//
//  Created by Kamaal M Farah on 26/11/2023.
//

import Quick
import Nimble
import Foundation
import SharedModels
@testable import Transactions

final class TransactionsScreenViewModelSpec: AsyncSpec {
    override class func spec() {
        var viewModel: TransactionsScreen.ViewModel!

        beforeEach {
            viewModel = TransactionsScreen.ViewModel()
        }

        describe("deleting transactions") {
            it("should set the right transaction to delete") {
                // Given
                await viewModel.setTransactions([testTransaction])

                // When
                await viewModel.onTransactionDelete(testTransaction)

                // Then
                expect(viewModel.deletingTransaction) == true
                expect(viewModel.transactionToDelete) == testTransaction
            }

            it("should remove definitly deleted transaction") {
                // Given
                await viewModel.setTransactions([testTransaction])
                await viewModel.onTransactionDelete(testTransaction)

                // When
                await viewModel.onDefiniteTransactionDelete()

                // Then
                expect(viewModel.deletingTransaction) == false
                expect(viewModel.transactionToDelete) == nil
                expect(viewModel.transactions.isEmpty) == true
            }
        }

        describe("ViewModel sheet state") {
            it("should show add transaction sheet") {
                // When
                await viewModel.showAddTransactionSheet()

                // Then
                expect(viewModel.shownSheet) == .addTransction
                expect(viewModel.showSheet) == true
            }

            it("should open transaction details sheet") {
                // When
                await viewModel.handleTransactionPress(testTransaction)

                // Then
                expect(viewModel.shownSheet) == .transactionDetails(testTransaction)
                expect(viewModel.showSheet) == true
            }

            it("should open transaction detail sheet, but directly in edit mode") {
                // When
                await viewModel.handleTransactionEditSelect(testTransaction)

                // Then
                expect(viewModel.shownSheet) == .transactionEdit(testTransaction)
                expect(viewModel.showSheet) == true
            }

            it("should reset sheet state from details sheet on sheet dismissal by setting showSheet to false") {
                // When
                await viewModel.handleTransactionPress(testTransaction)

                // When
                viewModel.showSheet = false

                // Then
                expect(viewModel.shownSheet).to(beNil())
                expect(viewModel.showSheet) == false
            }

            it("should have the correct state by default") {
                // Then
                expect(viewModel.shownSheet).to(beNil())
                expect(viewModel.showSheet) == false
            }

            it("should reset sheet state on sheet dismissal by setting showSheet to false") {
                await viewModel.showAddTransactionSheet()

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
