//
//  TransactionsScreen+ViewModel.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 09/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Combine
import Dispatch

extension TransactionsScreen {
    final class ViewModel: ObservableObject {

        @Published var showTransactionSheet = false
        @Published private(set) var selectedTranaction: CoreTransaction? {
            didSet {
                guard selectedTranaction != nil else { return }
                showTransactionSheet = true
            }
        }
        @Published var showDeleteWarning = false

        func selectCell(_ cell: StonkGridCellData, from transactions: [CoreTransaction]) {
            let selectedTransaction = transactions.first(where: { $0.id == cell.transactionID })
            self.selectedTranaction = selectedTransaction
        }

        func onDelete() {
            showTransactionSheet = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.showDeleteWarning = true
            }
        }

    }
}
