//
//  AddTransactionScreen+ViewModel.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 03/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Combine
import Foundation
import ConsoleSwift
import StonksLocale
import StonksNetworker

extension AddTransactionScreen {
    final class ViewModel: ObservableObject {

        @Published var investment = ""
        @Published var costPerShare = 0.0
        @Published var shares = 0.0
        @Published var transactionDate = Date()
        @Published var showAlert = false
        @Published var symbol = ""
        @Published private(set) var alertMessage: (title: String, message: String)? {
            didSet {
                guard alertMessage != nil else { return }
                showAlert = true
            }
        }

        private let networkController = NetworkController()

        var transactionArgs: CoreTransaction.Args {
            var maybeSymbol: String?
            if !symbol.trimmingByWhitespacesAndNewLines.isEmpty {
                maybeSymbol = symbol
            }
            return .init(
                name: investment,
                costPerShare: costPerShare,
                shares: shares,
                transactionDate: transactionDate,
                symbol: maybeSymbol)
        }

        func getActualPrice() async {
            let infoResult = await networkController.getInfo(of: symbol)
            let info: InfoResponse
            switch infoResult {
            case let .failure(failure):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    switch failure {
                    case .noSymbol:
                        #warning("Localize this")
                        self.alertMessage = ("No symbol provided",
                                             "The symbol is needed to get the actual information")
                    case .generalError:
                        #warning("Localize this")
                        self.alertMessage = ("Could not get info", "")
                    }
                }
                return
            case let .success(success): info = success
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.symbol = info.symbol
                self.costPerShare = info.close
                if let shortName = info.shortName {
                    self.investment = shortName
                }
            }
        }

        func saveAction(stonkResult: Result<CoreTransaction, StonksManager.Errors>) -> Bool {
            switch stonkResult {
            case .failure(let failure):
                switch failure {
                case .generalError(let error):
                    console.error(Date(), error.localizedDescription)
                    return false
                case .invalidStonkName:
                    alertMessage = (failure.localizedDescription,
                                    StonksLocale.Keys.INVALID_NAME_ALERT_MESSAGE.localized)
                    return false
                case .invalidAmountOfShares:
                    alertMessage = (failure.localizedDescription,
                                    StonksLocale.Keys.INVALID_AMOUNT_OF_SHARES_ALERT_MESSAGE.localized)
                    return false
                }
            case .success(_):
                return true
            }
        }

    }
}
