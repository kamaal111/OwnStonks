//
//  TransactionSheet.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 10/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI
import StonksUI
import StonksLocale

struct TransactionSheet: View {
    @ObservedObject
    private var viewModel: ViewModel

    let transaction: CoreTransaction?
    let currency: String
    let close: () -> Void
    let delete: () -> Void
    let editTransaction: (_ id: UUID, _ args: CoreTransaction.Args) -> Void

    init(
        transaction: CoreTransaction?,
        currency: String,
        close: @escaping () -> Void,
        delete: @escaping () -> Void,
        editTransaction: @escaping (_ id: UUID, _ args: CoreTransaction.Args) -> Void) {
        self.transaction = transaction
        self.currency = currency
        self.close = close
        self.delete = delete
        self.editTransaction = editTransaction
        self.viewModel = ViewModel(transaction: transaction)
    }

    var body: some View {
        SheetStack(
            title: .TRANSACTION,
            leadingNavigationButton: { NavigationButton(
                title: viewModel.editMode ? .DONE : .EDIT,
                action: {
                    viewModel.onEditPress(editTransaction: editTransaction)
                }) },
            trailingNavigationButton: { NavigationButton(
                title: .CLOSE,
                action: close) }) {
            VStack {
                HStack {
                    Text(localized: .CREATED_DATE, with: Self.creationDateFormatter.string(from: Date()))
                        .foregroundColor(.secondary)
                        .font(.callout)
                    Spacer()
                }
                if !viewModel.editMode {
                    if let transaction = self.transaction {
                    TransactionSheetRow(title: .INVESTMENT_LABEL, value: transaction.name)
                    TransactionSheetRow(
                        title: .COST_SHARE_HEADER_TITLE,
                        value: "\(currency)\(transaction.costPerShare.toFixed(2))")
                    TransactionSheetRow(title: .SHARES_LABEL, value: "\(transaction.shares)")
                    TransactionSheetRow(
                        title: .TRANSACTION_DATE_LABEL,
                        value: Self.tranactionDateFormatter.string(from: transaction.transactionDate))
                    }
                } else {
                    /// - TODO: Put this in a reuseable view
                    FloatingTextField(text: $viewModel.editedInvestment, title: .INVESTMENT_LABEL)
                    EnforcedFloatingDecimalField(
                        value: $viewModel.editedCostPerShare,
                        title: StonksLocale.Keys.COST_SHARE_LABEL.localized(with: currency))
                    EnforcedFloatingDecimalField(value: $viewModel.editedShares, title: .SHARES_LABEL)
                    FloatingDatePicker(value: $viewModel.editedTransactionDate, title: .TRANSACTION_DATE_LABEL)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: delete) {
                        Text(localized: .DELETE)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .frame(minWidth: 360, minHeight: viewModel.editMode ? 296 : 248)
    }

    static let tranactionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    static let creationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

}

private struct TransactionSheetRow: View {
    let title: String
    let value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    init(title: StonksLocale.Keys, value: String) {
        self.title = title.localized
        self.value = value
    }

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .bold()
                .frame(width: 100, alignment: .leading)
            Text(value)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

 struct TransactionSheet_Previews: PreviewProvider {
    static var previews: some View {
        let transaction: CoreTransaction?
        do {
            transaction = try PersistenceController.preview.fetch(CoreTransaction.self).get()?.first
        } catch {
            fatalError("Could not find transaction")
        }
        return Text("Hallo")
            .sheet(isPresented: .constant(true), content: {
                TransactionSheet(
                    transaction: transaction,
                    currency: "$",
                    close: { },
                    delete: { },
                    editTransaction: { _, _  in })
        })
    }
 }
