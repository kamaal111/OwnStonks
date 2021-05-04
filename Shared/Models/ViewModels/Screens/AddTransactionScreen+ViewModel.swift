//
//  AddTransactionScreen+ViewModel.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 03/05/2021.
//

import Combine
import Foundation
import ConsoleSwift

extension AddTransactionScreen {
    final class ViewModel: ObservableObject {

        @Published var investment = ""
        @Published var costs = 0.0
        @Published var shares = 0.0
        @Published var transactionDate = Date()
        @Published var showAlert = false
        @Published private(set) var alertMessage: (title: String, message: String)? {
            didSet {
                guard alertMessage != nil else { return }
                showAlert = true
            }
        }

        var stonkArgs: CoreStonk.Args {
            CoreStonk.Args(name: investment, costs: costs, shares: shares, transactionDate: transactionDate)
        }

        func saveAction(stonkResult: Result<CoreStonk, StonksManager.Errors>) -> Bool {
            switch stonkResult {
            case .failure(let failure):
                switch failure {
                case .generalError(let error):
                    console.error(Date(), error.localizedDescription)
                    return false
                case .invalidStonkName:
                    alertMessage = (failure.localizedDescription, "Please provide a valid name")
                    return false
                case .invalidAmountOfShares:
                    alertMessage = (failure.localizedDescription, "Please add atleast some shares")
                    return false
                }
            case .success(_):
                return true
            }
        }

    }
}
