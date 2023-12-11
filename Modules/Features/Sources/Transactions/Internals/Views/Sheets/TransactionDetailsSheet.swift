//
//  TransactionDetailsSheet.swift
//
//
//  Created by Kamaal M Farah on 25/11/2023.
//

import AppUI
import SwiftUI
import KamaalUI
import ForexKit
import KamaalExtensions

enum TransactionDetailsSheetContext {
    case new
    case details(_ transaction: AppTransaction)
}

struct TransactionDetailsSheet: View {
    @State private var name = ""
    @State private var transactionDate = Date()
    @State private var transactionType: TransactionTypes = .buy
    @State private var amount = "0.0"
    @State private var pricePerUnitCurrency: Currencies = .EUR
    @State private var pricePerUnit = "0.0"
    @State private var feesCurrency: Currencies = .EUR
    @State private var fees = "0.0"
    @State private var isEditing = true

    @Binding var isShown: Bool

    let context: TransactionDetailsSheetContext
    let onDone: (_ transaction: AppTransaction) -> Void

    init(
        isShown: Binding<Bool>,
        context: TransactionDetailsSheetContext,
        onDone: @escaping (_: AppTransaction) -> Void
    ) {
        self._isShown = isShown
        self.context = context
        self.onDone = onDone
        switch context {
        case .new: break
        case let .details(transaction):
            self._name = State(initialValue: transaction.name)
            self._transactionDate = State(initialValue: transaction.transactionDate)
            self._transactionType = State(initialValue: transaction.transactionType)
            self._amount = State(initialValue: String(transaction.amount))
            self._pricePerUnitCurrency = State(initialValue: transaction.pricePerUnit.currency)
            self._pricePerUnit = State(initialValue: String(transaction.pricePerUnit.value))
            self._feesCurrency = State(initialValue: transaction.fees.currency)
            self._fees = State(initialValue: String(transaction.fees.value))
            self._isEditing = State(initialValue: false)
        }
    }

    var body: some View {
        KSheetStack(
            title: title,
            leadingNavigationButton: { navigationButton(label: "Close", action: close) },
            trailingNavigationButton: {
                KJustStack {
                    if isEditing {
                        navigationButton(label: "Done", action: handleDone).disabled(!transactionIsValid)
                    } else {
                        navigationButton(label: "Edit", action: { withAnimation { isEditing = true } })
                    }
                }
            }
        ) {
            VStack(alignment: .leading) {
                EditableText(
                    text: $name,
                    label: NSLocalizedString("Name", bundle: .module, comment: ""),
                    isEditing: isEditing,
                    textCase: .none
                )
                EditableDate(
                    date: $transactionDate,
                    label: NSLocalizedString("Transaction Date", bundle: .module, comment: ""),
                    isEditing: isEditing
                )
                .padding(.top, isEditing ? .nada : .extraExtraSmall)
                EditablePicker(
                    selection: $transactionType,
                    label: NSLocalizedString("Type", bundle: .module, comment: ""),
                    isEditing: isEditing,
                    items: TransactionTypes.allCases,
                    valueColor: transactionType.color
                ) { item in
                    Text(item.localized)
                }
                .padding(.top, isEditing ? .nada : .extraExtraSmall)
                EditableDecimalText(
                    text: $amount,
                    label: NSLocalizedString("Amount", bundle: .module, comment: ""),
                    isEditing: isEditing
                )
                .padding(.top, isEditing ? .nada : .extraExtraSmall)
                EditableMoney(
                    currency: $pricePerUnitCurrency,
                    value: $pricePerUnit,
                    label: NSLocalizedString("Price per unit", bundle: .module, comment: ""),
                    isEditing: isEditing
                )
                .padding(.top, isEditing ? .nada : .extraExtraSmall)
                EditableMoney(
                    currency: $feesCurrency,
                    value: $fees,
                    label: NSLocalizedString("Fees", bundle: .module, comment: ""),
                    isEditing: isEditing
                )
            }
            #if os(macOS)
            .padding(.vertical, .medium)
            #endif
        }
        .padding(.vertical, .medium)
        #if os(macOS)
            .frame(minWidth: 320, minHeight: isEditing ? 380 : 260)
        #endif
            .onChange(of: pricePerUnitCurrency, onPricePerUnitCurrencyChange)
    }

    private var title: String {
        switch context {
        case .new: NSLocalizedString("Add Transaction", bundle: .module, comment: "")
        case let .details(transaction): transaction.name
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

        var id: UUID?
        if case let .details(transaction) = context {
            id = transaction.id
        }

        return AppTransaction(
            id: id,
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
        if case .details = context {
            withAnimation { isEditing = false }
        }

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
    TransactionDetailsSheet(isShown: .constant(true), context: .new, onDone: { _ in })
}
