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

enum ModifyTransactionSheetContext {
    case new
}

struct ModifyTransactionSheet: View {
    @State private var name = ""
    @State private var transactionDate = Date()
    @State private var transactionType: TransactionTypes = .buy
    @State private var amount = "0.0"
    @State private var pricePerAssetCurrency: Currencies = .EUR
    @State private var pricePerAsset = "0.0"

    @Binding var isShown: Bool

    let context: ModifyTransactionSheetContext
    let onDone: () -> Void

    var body: some View {
        KSheetStack(
            title: title,
            leadingNavigationButton: { navigationButton(label: "Close", action: { isShown = false }) },
            trailingNavigationButton: { navigationButton(label: "Done", action: onDone) }
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
                    value: $amount, title: NSLocalizedString("Amount", bundle: .module, comment: ""),
                    fixButtonTitle: NSLocalizedString("Fix", bundle: .module, comment: ""),
                    fixMessage: NSLocalizedString("Invalid value", bundle: .module, comment: "")
                )
                MoneyField(
                    currency: $pricePerAssetCurrency,
                    value: $pricePerAsset,
                    title: NSLocalizedString("Price per unit", bundle: .module, comment: ""),
                    currencies: Currencies.allCases.filter { !$0.isCryptoCurrency },
                    fixButtonTitle: NSLocalizedString("Fix", bundle: .module, comment: ""),
                    fixMessage: NSLocalizedString("Invalid value", bundle: .module, comment: "")
                )
                // Fees Field
            }
        }
        .padding(.vertical, .medium)
        #if os(macOS)
            .frame(minWidth: 320, minHeight: 348)
        #endif
    }

    private var title: String {
        switch context {
        case .new: NSLocalizedString("Add Transaction", bundle: .module, comment: "")
        }
    }

    private func navigationButton(label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label, bundle: .module)
                .bold()
                .foregroundStyle(.tint)
        }
    }
}

#Preview {
    ModifyTransactionSheet(isShown: .constant(true), context: .new, onDone: { })
}
