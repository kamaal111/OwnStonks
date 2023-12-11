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

    var body: some View {
        ForEach(transactions) { transaction in
            TransactionsListItem(
                transaction: transaction,
                layout: layout,
                action: { transactionAction(transaction) }
            )
            #if os(macOS)
            if transactions.last != transaction {
                Divider()
            }
            #endif
        }
    }
}

#Preview {
    TransactionsList(transactions: [], layout: .large, transactionAction: { _ in })
}
