//
//  TransactionsList.swift
//
//
//  Created by Kamaal M Farah on 11/12/2023.
//

import SwiftUI

enum TransactionsListLayouts {
    case medium
    case large
}

struct TransactionsList: View {
    let transactions: [AppTransaction]
    let layout: TransactionsListLayouts
    let transactionAction: (_ transaction: AppTransaction) -> Void
    let transactionDelete: (_ transaction: AppTransaction) -> Void

    var body: some View {
        ForEach(transactions) { transaction in
            TransactionsListItem(
                transaction: transaction,
                layout: layout,
                action: { transactionAction(transaction) }
            )
            .focusable()
            .onDeleteCommand(perform: { transactionDelete(transaction) })
            .onKeyPress { keyPress in handleKeyPress(keyPress, transaction: transaction) }
            #if os(macOS)
            if transactions.last != transaction {
                Divider()
            }
            #endif
        }
        .onDelete { indices in
            for index in indices {
                transactionDelete(transactions[index])
            }
        }
    }

    private func handleKeyPress(_ keyPress: KeyPress, transaction: AppTransaction) -> KeyPress.Result {
        if keyPress.key == .return {
            transactionAction(transaction)
            return .handled
        }
        return .ignored
    }
}

#Preview {
    TransactionsList(transactions: [], layout: .large, transactionAction: { _ in }, transactionDelete: { _ in })
}
