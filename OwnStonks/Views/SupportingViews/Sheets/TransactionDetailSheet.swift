//
//  TransactionDetailSheet.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 29/12/2022.
//

import Models
import SwiftUI
import SalmonUI
import ZaWarudo
import OSLocales
import ShrimpExtensions

struct TransactionDetailSheet: View {
    @StateObject private var viewModel = ViewModel()

    @Binding var isShown: Bool

    let context: TransactionDetailSheetContext
    let submittedTransaction: (_ transaction: OSTransaction) -> Void

    var body: some View {
        KSheetStack(
            title: title,
            leadingNavigationButton: { closeButton },
            trailingNavigationButton: { doneButton }) {
                content
            }
            .frame(minWidth: 320, minHeight: 348)
            .onAppear(perform: handleOnAppear)
    }

    private var content: some View {
        VStack(spacing: 4) {
            EditableText(text: $viewModel.assetName, localized: .NAME, isEditing: viewModel.isEditing)
            EditableDate(date: $viewModel.transactionDate, localized: .TRANSACTION_DATE, isEditing: viewModel.isEditing)
            EditablePickerType(
                selection: $viewModel.transactionType,
                localized: .TYPE,
                items: TransactionTypes.allCases,
                isEditing: viewModel.isEditing) { item in
                    OSText(item.localized)
                }
            EditableDecimal(value: $viewModel.transactionAmount, localized: .AMOUNT, isEditing: viewModel.isEditing)
            EditableMoney(
                currency: $viewModel.pricePerUnitCurrency,
                value: $viewModel.pricePerUnit,
                localized: .PRICE_PER_UNIT,
                isEditing: viewModel.isEditing)
            EditableMoney(
                currency: $viewModel.feesCurrency,
                value: $viewModel.fees,
                localized: .FEES,
                isEditing: viewModel.isEditing)
        }
        .padding(.vertical, .medium)
    }

    private var closeButton: some View {
        Button(action: onClose) {
            OSText(localized: .CLOSE)
                .foregroundColor(.accentColor)
        }
    }

    private var doneButton: some View {
        KJustStack {
            if viewModel.isEditing {
                Button(action: onDone) {
                    OSText(localized: .DONE)
                        .foregroundColor(.accentColor)
                }
                .disabled(viewModel.invalidTransaction)
            } else {
                Button(action: onEdit) {
                    OSText(localized: .EDIT)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }

    private var title: String {
        switch context {
        case .addTransaction:
            return OSLocales.getText(.ADD_TRANSACTION)
        case .editTransaction(transaction: let transaction):
            return transaction.assetName
        }
    }

    private func handleOnAppear() {
        switch context {
        case .addTransaction:
            break
        case .editTransaction(transaction: let transaction):
            viewModel.setValues(with: transaction)
        }
    }

    private func onClose() {
        isShown = false
    }

    private func onDone() {
        submittedTransaction(viewModel.transaction)
        onClose()
    }

    private func onEdit() {
        viewModel.toggleEditing()
    }
}

private final class ViewModel: ObservableObject {
    @Published var assetName = ""
    @Published var transactionDate = Current.date()
    @Published var transactionType: TransactionTypes = .buy
    @Published var transactionAmount = 0.0
    @Published var pricePerUnitCurrency: Currencies = .EUR
    @Published var pricePerUnit = 0.0
    @Published var feesCurrency: Currencies = .EUR
    @Published var fees = 0.0
    @Published private(set) var isEditing = true

    private var transactionID: UUID?

    var transaction: OSTransaction {
        .init(
            id: transactionID,
            assetName: assetName,
            date: transactionDate,
            type: transactionType,
            amount: transactionAmount,
            pricePerUnit: .init(amount: pricePerUnit, currency: pricePerUnitCurrency),
            fees: .init(amount: fees, currency: feesCurrency))
    }

    var invalidTransaction: Bool {
        assetName.trimmingByWhitespacesAndNewLines.isEmpty
    }

    @MainActor
    func toggleEditing() {
        isEditing.toggle()
    }

    @MainActor
    func setValues(with transaction: OSTransaction) {
        transactionID = transaction.id
        assetName = transaction.assetName
        transactionDate = transaction.date
        transactionType = transaction.type
        transactionAmount = transaction.amount
        pricePerUnitCurrency = transaction.pricePerUnit.currency
        pricePerUnit = transaction.pricePerUnit.amount
        feesCurrency = transaction.fees.currency
        fees = transaction.fees.amount
        isEditing = false
    }
}

struct TransactionDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailSheet(isShown: .constant(true), context: .addTransaction, submittedTransaction: { _ in })
    }
}
