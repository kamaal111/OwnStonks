//
//  TransactionSheet+ViewModel.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 12/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI

extension TransactionSheet {
    final class ViewModel: ObservableObject {

        @Published var editMode = false
        @Published var editedInvestment = ""
        @Published var editedCostPerShare = 0.0
        @Published var editedShares = 0.0
        @Published var editedTransactionDate = Date()

        let transaction: CoreTransaction?

        init(transaction: CoreTransaction?) {
            self.transaction = transaction
        }

        func onEditPress(editTransaction: (_ id: UUID, _ args: CoreTransaction.Args) -> Void) {
            if editMode {
                guard !editedInvestment.isEmpty && !editedShares.isZero,
                      let transactionID = transaction?.id else { return }
                let args = CoreTransaction.Args(
                    name: editedInvestment,
                    costPerShare: editedCostPerShare,
                    shares: editedShares,
                    transactionDate: editedTransactionDate,
                    symbol: nil)
                withAnimation { editMode = false }
                editTransaction(transactionID, args)
            } else {
                if let transaction = self.transaction {
                    editedInvestment = transaction.name
                    editedShares = transaction.shares
                    editedCostPerShare = transaction.costPerShare
                    editedTransactionDate = transaction.transactionDate
                }
                withAnimation { editMode = true }
            }
        }

    }
}
