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

enum TransactionDetailsSheetContext: Equatable {
    case new(_ preferredCurrency: Currencies)
    case details(_ transaction: AppTransaction)
}

struct TransactionDetailsSheet: View {
    @State private var viewModel: ViewModel

    @Binding var isShown: Bool

    let onDone: (_ transaction: AppTransaction) -> Void

    init(
        isShown: Binding<Bool>,
        context: TransactionDetailsSheetContext,
        onDone: @escaping (_: AppTransaction) -> Void
    ) {
        self._isShown = isShown
        self._viewModel = State(initialValue: ViewModel(context: context))
        self.onDone = onDone
    }

    var body: some View {
        KSheetStack(
            title: viewModel.title,
            leadingNavigationButton: { navigationButton(label: "Close", action: close) },
            trailingNavigationButton: {
                KJustStack {
                    if viewModel.isEditing {
                        navigationButton(label: "Done", action: handleDone).disabled(!viewModel.transactionIsValid)
                    } else {
                        navigationButton(label: "Edit", action: { viewModel.enableEditing() })
                    }
                }
            }
        ) {
            VStack(alignment: .leading) {
                EditableText(
                    text: $viewModel.name,
                    label: NSLocalizedString("Name", bundle: .module, comment: ""),
                    isEditing: viewModel.isEditing,
                    textCase: .none
                )
                EditableDate(
                    date: $viewModel.transactionDate,
                    label: NSLocalizedString("Transaction Date", bundle: .module, comment: ""),
                    isEditing: viewModel.isEditing
                )
                .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                EditablePicker(
                    selection: $viewModel.transactionType,
                    label: NSLocalizedString("Type", bundle: .module, comment: ""),
                    isEditing: viewModel.isEditing,
                    items: TransactionTypes.allCases,
                    valueColor: viewModel.transactionType.color
                ) { item in
                    Text(item.localized)
                }
                .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                EditableDecimalText(
                    text: $viewModel.amount,
                    label: NSLocalizedString("Amount", bundle: .module, comment: ""),
                    isEditing: viewModel.isEditing
                )
                .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                EditableMoney(
                    currency: $viewModel.pricePerUnitCurrency,
                    value: $viewModel.pricePerUnit,
                    label: NSLocalizedString("Price per unit", bundle: .module, comment: ""),
                    isEditing: viewModel.isEditing
                )
                .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                EditableMoney(
                    currency: $viewModel.feesCurrency,
                    value: $viewModel.fees,
                    label: NSLocalizedString("Fees", bundle: .module, comment: ""),
                    isEditing: viewModel.isEditing
                )
            }
            #if os(macOS)
            .padding(.vertical, .medium)
            #endif
        }
        .padding(.vertical, .medium)
        #if os(macOS)
            .frame(minWidth: 320, minHeight: viewModel.isEditing ? 380 : 260)
        #endif
    }

    private func navigationButton(label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label, bundle: .module)
                .bold()
                .foregroundStyle(.tint)
        }
    }

    private func handleDone() {
        assert(viewModel.transactionIsValid)
        guard let transaction = viewModel.transaction else { return }

        onDone(transaction)
        if case .details = viewModel.context {
            Task { await viewModel.disableEditing() }
        } else {
            close()
        }
    }

    private func close() {
        isShown = false
    }
}

extension TransactionDetailsSheet {
    @Observable
    final class ViewModel {
        var name: String
        var transactionDate: Date
        var transactionType: TransactionTypes
        var amount: String
        var pricePerUnitCurrency: Currencies {
            didSet { pricePerUnitCurrencyDidSet() }
        }

        var pricePerUnit: String
        var feesCurrency: Currencies
        var fees: String
        private(set) var isEditing: Bool

        let context: TransactionDetailsSheetContext

        convenience init(context: TransactionDetailsSheetContext) {
            switch context {
            case let .new(preferredCurrency):
                self.init(
                    context: context,
                    name: "",
                    transactionDate: Date(),
                    transactionType: .buy,
                    amount: "0.0",
                    pricePerUnitCurrency: preferredCurrency,
                    pricePerUnit: "0.0",
                    feesCurrency: preferredCurrency,
                    fees: "0.0",
                    isEditing: true
                )
            case let .details(transaction):
                self.init(
                    context: context,
                    name: transaction.name,
                    transactionDate: transaction.transactionDate,
                    transactionType: transaction.transactionType,
                    amount: String(transaction.amount),
                    pricePerUnitCurrency: transaction.pricePerUnit.currency,
                    pricePerUnit: String(transaction.pricePerUnit.value),
                    feesCurrency: transaction.fees.currency,
                    fees: String(transaction.fees.value),
                    isEditing: false
                )
            }
        }

        init(
            context: TransactionDetailsSheetContext,
            name: String,
            transactionDate: Date,
            transactionType: TransactionTypes,
            amount: String,
            pricePerUnitCurrency: Currencies,
            pricePerUnit: String,
            feesCurrency: Currencies,
            fees: String,
            isEditing: Bool
        ) {
            self.context = context
            self.name = name
            self.transactionDate = transactionDate
            self.transactionType = transactionType
            self.amount = amount
            self.pricePerUnitCurrency = pricePerUnitCurrency
            self.pricePerUnit = pricePerUnit
            self.feesCurrency = feesCurrency
            self.fees = fees
            self.isEditing = isEditing
        }

        var transactionIsValid: Bool {
            transaction != nil
        }

        var title: String {
            switch context {
            case .new: NSLocalizedString("Add Transaction", bundle: .module, comment: "")
            case let .details(transaction): transaction.name
            }
        }

        var transaction: AppTransaction? {
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

        @MainActor
        func enableEditing() {
            withAnimation { isEditing = true }
        }

        @MainActor
        func disableEditing() {
            isEditing = false
        }

        private func pricePerUnitCurrencyDidSet() {
            if feesCurrency != pricePerUnitCurrency {
                feesCurrency = pricePerUnitCurrency
            }
        }
    }
}

#Preview {
    TransactionDetailsSheet(isShown: .constant(true), context: .new(.CAD), onDone: { _ in })
}
