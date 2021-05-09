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

        @Published var showTransactionModal = false
        @Published private(set) var selectedCell: StonkGridCellData? {
            didSet {
                guard selectedCell != nil else { return }
                showTransactionModal = true
            }
        }

        func selectCell(_ cell: StonkGridCellData) {
            self.selectedCell = cell
        }

    }
}
