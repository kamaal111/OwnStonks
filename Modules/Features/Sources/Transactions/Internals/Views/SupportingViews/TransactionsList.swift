//
//  TransactionsList.swift
//
//
//  Created by Kamaal M Farah on 11/12/2023.
//

import SwiftUI
import KamaalUI

enum TransactionsListLayouts {
    case medium
    case large
}

struct TransactionsList: View {
    let transactions: [AppTransaction]
    let layout: TransactionsListLayouts
    let transactionAction: (_ transaction: AppTransaction) -> Void
    let transactionDelete: (_ transaction: AppTransaction) -> Void
    let transactionEdit: (_ transaction: AppTransaction) -> Void

    var body: some View {
        ForEach(transactions) { transaction in
            TransactionsListItem(
                transaction: transaction,
                layout: layout,
                action: { transactionAction(transaction) },
                onDelete: { transactionDelete(transaction) },
                onEdit: { transactionEdit(transaction) }
            )
            .focusable()
            .onKeyPress { keyPress in handleKeyPress(keyPress, transaction: transaction) }
            #if os(macOS)
                .onDeleteCommand(perform: { transactionDelete(transaction) })
            #endif
            #if os(macOS)
            if transactions.last != transaction {
                Divider()
            }
            #endif
        }
    }

    private func handleKeyPress(_ keyPress: KeyPress, transaction: AppTransaction) -> KeyPress.Result {
        switch keyPress.key {
        case .return:
            transactionAction(transaction)
            return .handled
        default: break
        }

        return .ignored
    }
}

#Preview {
    TransactionsList(
        transactions: [],
        layout: .large,
        transactionAction: { _ in },
        transactionDelete: { _ in },
        transactionEdit: { _ in }
    )
}
