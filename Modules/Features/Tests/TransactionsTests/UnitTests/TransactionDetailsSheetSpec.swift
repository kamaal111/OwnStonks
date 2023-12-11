//
//  TransactionDetailsSheetSpec.swift
//
//
//  Created by Kamaal M Farah on 11/12/2023.
//

import Quick
import Nimble
import Foundation
@testable import Transactions

final class TransactionDetailsSheetSpec: AsyncSpec {
    override class func spec() {
        describe("State changes") {
            context("Fees and price per unit currency changes") {
                it("should set fees currency when price per unit changes") {
                    // Given
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .details(testTransaction))

                    // When
                    viewModel.pricePerUnitCurrency = .AUD

                    // Then
                    expect(viewModel.feesCurrency).to(equal(.AUD))
                    expect(viewModel.pricePerUnitCurrency).to(equal(.AUD))
                }

                it("should not set price per unit currency when fees currency changes") {
                    // Given
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .details(testTransaction))

                    // When
                    viewModel.feesCurrency = .JPY

                    // Then
                    expect(viewModel.feesCurrency).to(equal(.JPY))
                    expect(viewModel.pricePerUnitCurrency).to(equal(.USD))
                }
            }
        }

        describe("Toggling editing") {
            it("should toggle editing on") {
                // Given
                let viewModel = TransactionDetailsSheet.ViewModel(context: .details(testTransaction))

                // When
                await viewModel.enableEditing()

                // Then
                expect(viewModel.isEditing) == true
            }

            it("should toggle editing off") {
                // Given
                let viewModel = TransactionDetailsSheet.ViewModel(context: .new)

                // When
                await viewModel.disableEditing()

                // Then
                expect(viewModel.isEditing) == false
            }
        }

        describe("Context initializers") {
            context("Details context") {
                it("should set all the right default values") {
                    // Given
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .details(testTransaction))

                    // Then
                    expect(viewModel.transactionIsValid) == true
                    expect(viewModel.transaction) == testTransaction
                    expect(viewModel.context).to(equal(.details(testTransaction)))
                    expect(viewModel.title) == testTransaction.name
                    expect(viewModel.isEditing) == false
                    expect(viewModel.feesCurrency).to(equal(.EUR))
                    expect(viewModel.pricePerUnitCurrency).to(equal(.USD))
                }
            }

            context("New context") {
                it("should set all the right default values") {
                    // Given
                    let viewModel = TransactionDetailsSheet.ViewModel(context: .new)

                    // Then
                    expect(viewModel.transactionIsValid) == false
                    expect(viewModel.transaction).to(beNil())
                    expect(viewModel.title) == NSLocalizedString("Add Transaction", bundle: .module, comment: "")
                    expect(viewModel.isEditing) == true
                }
            }
        }
    }
}

private let testTransaction = AppTransaction(
    id: UUID(uuidString: "7d28a378-6c12-4d92-8843-baf2e2a9bcdc")!,
    name: "Google",
    transactionDate: Date(timeIntervalSince1970: 1_702_328_316),
    transactionType: .sell,
    amount: 100,
    pricePerUnit: Money(value: 500, currency: .USD),
    fees: Money(value: 3.2, currency: .EUR)
)
