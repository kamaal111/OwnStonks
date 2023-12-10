//
//  ModifyTransactionSheet.swift
//
//
//  Created by Kamaal M Farah on 25/11/2023.
//

import AppUI
import SwiftUI
import KamaalUI
import ForexKit
import KamaalExtensions

enum ModifyTransactionSheetContext {
    case new
}

struct ModifyTransactionSheet: View {
    @State private var name = ""
    @State private var transactionDate = Date()
    @State private var transactionType: TransactionTypes = .buy
    @State private var amount = "0.0"
    @State private var pricePerUnitCurrency: Currencies = .EUR
    @State private var pricePerUnit = "0.0"
    @State private var feesCurrency: Currencies = .EUR
    @State private var fees = "0.0"

    @Binding var isShown: Bool

    let context: ModifyTransactionSheetContext
    let onDone: (_ transaction: AppTransaction) -> Void

    var body: some View {
        KSheetStack(
            title: title,
            leadingNavigationButton: { navigationButton(label: "Close", action: close) },
            trailingNavigationButton: {
                navigationButton(label: "Done", action: handleDone).disabled(!transactionIsValid)
            }
        ) {
            VStack(alignment: .leading) {
                KFloatingTextField(text: $name, title: NSLocalizedString("Name", bundle: .module, comment: ""))
                KFloatingDatePicker(
                    value: $transactionDate,
                    title: NSLocalizedString("Transaction Date", bundle: .module, comment: ""),
                    displayedComponents: [.date]
                )
                KTitledPicker(
                    selection: $transactionType,
                    title: NSLocalizedString("Type", bundle: .module, comment: ""),
                    items: TransactionTypes.allCases
                ) { type in
                    Text(type.localized)
                }
                KFloatingDecimalField(
                    value: $amount,
                    title: NSLocalizedString("Amount", bundle: .module, comment: ""),
                    fixButtonTitle: NSLocalizedString("Fix", bundle: .module, comment: ""),
                    fixMessage: NSLocalizedString("Invalid value", bundle: .module, comment: "")
                )
                MoneyField(
                    currency: $pricePerUnitCurrency,
                    value: $pricePerUnit,
                    title: NSLocalizedString("Price per unit", bundle: .module, comment: ""),
                    currencies: Currencies.allCases.filter { !$0.isCryptoCurrency },
                    fixButtonTitle: NSLocalizedString("Fix", bundle: .module, comment: ""),
                    fixMessage: NSLocalizedString("Invalid value", bundle: .module, comment: "")
                )
                MoneyField(
                    currency: $feesCurrency,
                    value: $fees,
                    title: NSLocalizedString("Fees", bundle: .module, comment: ""),
                    currencies: Currencies.allCases.filter { !$0.isCryptoCurrency },
                    fixButtonTitle: NSLocalizedString("Fix", bundle: .module, comment: ""),
                    fixMessage: NSLocalizedString("Invalid value", bundle: .module, comment: "")
                )
            }
        }
        .padding(.vertical, .medium)
        #if os(macOS)
            .frame(minWidth: 320, minHeight: 348)
        #endif
            .onChange(of: pricePerUnitCurrency, onPricePerUnitCurrencyChange)
    }

    private var title: String {
        switch context {
        case .new: NSLocalizedString("Add Transaction", bundle: .module, comment: "")
        }
    }

    private var transactionIsValid: Bool {
        transaction != nil
    }

    private var transaction: AppTransaction? {
        guard !name.trimmingByWhitespacesAndNewLines.isEmpty else { return nil }
        guard let amount = Double(amount) else { return nil }
        guard let pricePerUnit = Double(pricePerUnit) else { return nil }
        guard let fees = Double(fees) else { return nil }

        return AppTransaction(
            name: name,
            transactionDate: transactionDate,
            transactionType: transactionType,
            amount: amount,
            pricePerUnit: Money(value: pricePerUnit, currency: pricePerUnitCurrency),
            fees: Money(value: fees, currency: feesCurrency)
        )
    }

    private func navigationButton(label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label, bundle: .module)
                .bold()
                .foregroundStyle(.tint)
        }
    }

    private func handleDone() {
        assert(transactionIsValid)
        guard let transaction else { return }

        onDone(transaction)
        close()
    }

    private func close() {
        isShown = false
    }

    private func onPricePerUnitCurrencyChange(_: Currencies, _ newValue: Currencies) {
        if feesCurrency != newValue {
            feesCurrency = newValue
        }
    }
}

#Preview {
    ModifyTransactionSheet(isShown: .constant(true), context: .new, onDone: { _ in })
}
