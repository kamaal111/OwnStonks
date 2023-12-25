//
//  TransactionDetailsSheet.swift
//
//
//  Created by Kamaal M Farah on 25/11/2023.
//

import SwiftUI
import SharedUI
import KamaalUI
import ForexKit
import SharedModels
import KamaalExtensions

enum TransactionDetailsSheetContext: Equatable {
    case new(_ preferredCurrency: Currencies)
    case details(_ transaction: AppTransaction)
    case edit(_ transaction: AppTransaction)
}

struct TransactionDetailsSheet: View {
    @State private var viewModel: ViewModel

    @Binding var isShown: Bool

    let isNotPendingInTheCloud: Bool
    let onDone: (_ transaction: AppTransaction) -> Void
    let onDelete: () -> Void

    init(
        isShown: Binding<Bool>,
        context: TransactionDetailsSheetContext,
        isNotPendingInTheCloud: Bool,
        onDone: @escaping (_: AppTransaction) -> Void,
        onDelete: @escaping () -> Void = { }
    ) {
        self._isShown = isShown
        self._viewModel = State(initialValue: ViewModel(context: context))
        self.isNotPendingInTheCloud = isNotPendingInTheCloud
        self.onDone = onDone
        self.onDelete = onDelete
    }

    var body: some View {
        KSheetStack(
            title: viewModel.title,
            leadingNavigationButton: { navigationButton(label: "Close", action: close) },
            trailingNavigationButton: {
                KJustStack {
                    if !isNotPendingInTheCloud {
                        Text("")
                    } else if viewModel.isEditing {
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
                .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                if viewModel.isEditing, !viewModel.isNew {
                    Button(action: handleDelete) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete this transaction", bundle: .module)
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.top, .small)
                    .ktakeWidthEagerly(alignment: .center)
                }
            }
            .padding(.vertical, .medium)
        }
        .padding(.vertical, .medium)
        #if os(macOS)
            .frame(minWidth: 320, minHeight: viewModel.isEditing ? 412 : 260)
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

    func handleDelete() {
        close()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            onDelete()
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
        let isNew: Bool

        convenience init(context: TransactionDetailsSheetContext) {
            switch context {
            case let .new(preferredCurrency):
                self.init(
                    context: context,
                    name: "",
                    transactionDate: Date(),
                    transactionType: .buy,
                    amount: 0,
                    pricePerUnit: Money(value: 0, currency: preferredCurrency),
                    fees: Money(value: 0, currency: preferredCurrency),
                    isEditing: true,
                    isNew: true
                )
            case let .details(transaction):
                self.init(
                    context: context,
                    name: transaction.name,
                    transactionDate: transaction.transactionDate,
                    transactionType: transaction.transactionType,
                    amount: transaction.amount,
                    pricePerUnit: transaction.pricePerUnit,
                    fees: transaction.fees,
                    isEditing: false,
                    isNew: false
                )
            case let .edit(transaction):
                self.init(
                    context: context,
                    name: transaction.name,
                    transactionDate: transaction.transactionDate,
                    transactionType: transaction.transactionType,
                    amount: transaction.amount,
                    pricePerUnit: transaction.pricePerUnit,
                    fees: transaction.fees,
                    isEditing: true,
                    isNew: false
                )
            }
        }

        init(
            context: TransactionDetailsSheetContext,
            name: String,
            transactionDate: Date,
            transactionType: TransactionTypes,
            amount: Double,
            pricePerUnit: Money,
            fees: Money,
            isEditing: Bool,
            isNew: Bool
        ) {
            self.context = context
            self.name = name
            self.transactionDate = transactionDate
            self.transactionType = transactionType
            self.amount = String(amount)
            self.pricePerUnitCurrency = pricePerUnit.currency
            self.pricePerUnit = String(pricePerUnit.value)
            self.feesCurrency = fees.currency
            self.fees = String(fees.value)
            self.isEditing = isEditing
            self.isNew = isNew
        }

        var transactionIsValid: Bool {
            transaction != nil
        }

        var title: String {
            switch context {
            case .new: NSLocalizedString("Add Transaction", bundle: .module, comment: "")
            case let .details(transaction): transaction.name
            case let .edit(transaction): transaction.name
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
    TransactionDetailsSheet(
        isShown: .constant(true),
        context: .new(.CAD),
        isNotPendingInTheCloud: true,
        onDone: { _ in },
        onDelete: { }
    )
}
