//
//  AddTransactionSheet.swift
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

struct AddTransactionSheet: View {
    @StateObject private var viewModel = ViewModel()

    @Binding var isShown: Bool

    let submittedTransaction: (_ transaction: OSTransaction) -> Void

    var body: some View {
        KSheetStack(
            title: OSLocales.getText(.ADD_TRANSACTION),
            leadingNavigationButton: { closeButton },
            trailingNavigationButton: { doneButton }) {
                content
            }
            .frame(minWidth: 320, minHeight: 348)
    }

    private var content: some View {
        VStack {
            KFloatingTextField(text: $viewModel.assetName, title: OSLocales.getText(.NAME))
            KFloatingDatePicker(value: $viewModel.transactionDate, title: OSLocales.getText(.TRANSACTION_DATE))
                .ktakeWidthEagerly(alignment: .leading)
            TitledPicker(
                selection: $viewModel.transactionType,
                localized: .TYPE,
                items: TransactionTypes.allCases) { item in
                    OSText(item.localized)
                }
                .padding(.top, -(AppSizes.small.rawValue))
            KEnforcedFloatingDecimalField(
                value: $viewModel.transactionAmount,
                title: OSLocales.getText(.AMOUNT))
            MoneyTextField(
                currency: $viewModel.pricePerUnitCurrency,
                value: $viewModel.pricePerUnit,
                localized: .PRICE_PER_UNIT)
            MoneyTextField(
                currency: $viewModel.feesCurrency,
                value: $viewModel.fees,
                localized: .FEES)
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
        Button(action: onDone) {
            OSText(localized: .DONE)
                .foregroundColor(.accentColor)
        }
        .disabled(viewModel.invalidTransaction)
    }

    private func onClose() {
        isShown = false
    }

    private func onDone() {
        submittedTransaction(viewModel.transaction)
        onClose()
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

    var transaction: OSTransaction {
        .init(
            id: .none,
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
}

struct AddTransactionSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionSheet(isShown: .constant(true), submittedTransaction: { _ in })
    }
}
