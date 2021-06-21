//
//  TransactionSheet+ViewModel.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 12/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI
import StonksLocale
import StonksNetworker

extension TransactionSheet {
    final class ViewModel: ObservableObject {

        @Published var editMode = false
        @Published var editedInvestment = ""
        @Published var editedCostPerShare = 0.0
        @Published var editedShares = 0.0
        @Published var editedTransactionDate = Date()
        @Published var editedSymbol = ""
        @Published var showAlert = false
        @Published private(set) var alertMessage: (title: String, message: String)? {
            didSet {
                guard alertMessage != nil else { return }
                showAlert = true
            }
        }

        let transaction: CoreTransaction?

        private let networkController = NetworkController.shared

        init(transaction: CoreTransaction?) {
            self.transaction = transaction
        }

        @available(macOS 12.0, *)
        func getActualPrice() async {
            let infoResult = await networkController.getInfo(of: editedSymbol, on: editedTransactionDate)
            let info: InfoResponse
            switch infoResult {
            case let .failure(failure):
                DispatchQueue.main.async { [weak self] in
                    self?.alertMessage = (failure.title, failure.message)
                }
                return
            case let .success(success): info = success
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.editedSymbol = info.symbol
                self.editedCostPerShare = info.close
                if let shortName = info.shortName {
                    self.editedInvestment = shortName
                }
            }
        }

        func onEditPress(editTransaction: (_ id: UUID, _ args: CoreTransaction.Args) -> Void) {
            if editMode {
                guard !editedInvestment.isEmpty && !editedShares.isZero,
                      let transactionID = transaction?.id else { return }
                var symbol: String?
                if !editedSymbol.trimmingByWhitespacesAndNewLines.isEmpty {
                    symbol = editedSymbol
                }
                let args = CoreTransaction.Args(
                    name: editedInvestment,
                    costPerShare: editedCostPerShare,
                    shares: editedShares,
                    transactionDate: editedTransactionDate,
                    symbol: symbol)
                withAnimation { editMode = false }
                editTransaction(transactionID, args)
            } else {
                if let transaction = self.transaction {
                    editedInvestment = transaction.name
                    editedShares = transaction.shares
                    editedCostPerShare = transaction.costPerShare
                    editedTransactionDate = transaction.transactionDate
                    editedSymbol = transaction.symbol ?? ""
                }
                withAnimation { editMode = true }
            }
        }

    }
}
