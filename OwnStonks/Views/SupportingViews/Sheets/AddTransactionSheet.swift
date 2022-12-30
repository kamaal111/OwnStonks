//
//  AddTransactionSheet.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 29/12/2022.
//

import SwiftUI
import SalmonUI
import OSLocales

struct AddTransactionSheet: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        KSheetStack(
            title: OSLocales.getText(.ADD_TRANSACTION),
            leadingNavigationButton: { closeButton },
            trailingNavigationButton: { doneButton }) {
                content
            }
            .frame(minWidth: 320, minHeight: 310)
    }

    private var closeButton: some View {
        OSButton(action: onClose) {
            OSText(localized: .CLOSE)
                .foregroundColor(.accentColor)
        }
    }

    private var doneButton: some View {
        OSButton(action: onDone) {
            OSText(localized: .DONE)
                .foregroundColor(.accentColor)
        }
    }

    private var content: some View {
        VStack {
            KFloatingDatePicker(value: $viewModel.transactionDate, title: OSLocales.getText(.TRANSACTION_DATE))
            TitledPicker(
                selection: $viewModel.transactionType,
                localized: .TYPE,
                items: TransactionTypes.allCases) { item in
                    Text(item.localized)
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

    private func onClose() { }

    private func onDone() { }
}

private final class ViewModel: ObservableObject {
    @Published var transactionDate = Date()
    @Published var transactionType: TransactionTypes = .buy
    @Published var transactionAmount = 0.0
    @Published var pricePerUnitCurrency: Currencies = .EUR
    @Published var pricePerUnit = 0.0
    @Published var feesCurrency: Currencies = .EUR
    @Published var fees = 0.0

    init() { }
}

struct AddTransactionSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionSheet()
    }
}
