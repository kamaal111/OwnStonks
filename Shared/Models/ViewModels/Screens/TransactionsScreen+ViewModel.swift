//
//  TransactionsScreen+ViewModel.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 09/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Combine

extension TransactionsScreen {
    final class ViewModel: ObservableObject {

        @Published var showTransactionSheet = false
        @Published private(set) var selectedTranaction: CoreTransaction? {
            didSet {
                guard selectedTranaction != nil else { return }
                showTransactionSheet = true
            }
        }

        func selectCell(_ cell: StonkGridCellData, from transactions: [CoreTransaction]) {
            let selectedTransaction = transactions.first(where: { $0.id == cell.transactionID })
            self.selectedTranaction = selectedTransaction
        }

    }
}
