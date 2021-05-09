//
//  StonksManager.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 03/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Combine
import ConsoleSwift
import Foundation
import ShrimpExtensions
import StonksLocale

/// This class manages all core data objects
final class StonksManager: ObservableObject {

    @Published private var transactions: [CoreTransaction] = []

    private let persistenceController = PersistenceController.shared

    init() {
        let fetchResult = persistenceController.fetch(CoreTransaction.self)
        switch fetchResult {
        case .failure(let failure):
            console.error(Date(), failure.localizedDescription, failure)
            return
        case .success(let success):
            if let success = success {
                self.transactions = success
            }
        }
    }

    enum Errors: Error {
        case invalidStonkName
        case invalidAmountOfShares
        case generalError(error: Error)

        var localizedDescription: String {
            switch self {
            case .invalidStonkName:
                return StonksLocale.Keys.INVALID_NAME_ALERT_TITLE.localized
            case .invalidAmountOfShares:
                return StonksLocale.Keys.INVALID_AMOUNT_OF_SHARES_ALERT_TITLE.localized
            case .generalError(let error):
                return StonksLocale.Keys.GENERAL_ALERT_TITLE.localized(with: error.localizedDescription)
            }
        }
    }

    var sortedTransactions: [CoreTransaction] {
        transactions.sorted(by: { $0.transactionDate.compare($1.transactionDate) == .orderedDescending })
    }

    var portfolioStonks: [PortfolioItem] {
        var combinedTranactions: [String: PortfolioItem] = [:]
        for transaction in transactions {
            let key: String
            if let symbol = transaction.symbol {
                key = symbol.lowercased()
            } else {
                key = transaction.name.lowercased()
            }
            if let transactionInCombinedTransactions = combinedTranactions[key] {
                let shares = transactionInCombinedTransactions.shares + transaction.shares
                let totalPrice = transactionInCombinedTransactions.totalPrice + transaction.totalPrice
                let transactionToAdd = PortfolioItem(
                    name: transactionInCombinedTransactions.name,
                    shares: shares,
                    totalPrice: totalPrice,
                    id: transaction.id,
                    symbol: transactionInCombinedTransactions.symbol)
                combinedTranactions[key] = transactionToAdd
            } else {
                combinedTranactions[key] = transaction.initialPortfolioItem
            }
        }
        return combinedTranactions
            .sorted(by: { $0.value.totalPrice > $1.value.totalPrice })
            .map(\.value)
    }

    func setTransaction(with args: CoreTransaction.Args) -> Result<CoreTransaction, Errors> {
        guard let context = persistenceController.context else { fatalError("No context") }
        guard !args.name.trimmingByWhitespacesAndNewLines.isEmpty else { return .failure(.invalidStonkName) }
        guard !args.shares.isZero else { return .failure(.invalidAmountOfShares) }
        let stonkResult = CoreTransaction.setTransaction( args: args, managedObjectContext: context)
        let stonk: CoreTransaction
        switch stonkResult {
        case .failure(let failure): return .failure(.generalError(error: failure))
        case .success(let success): stonk = success
        }
        transactions.append(stonk)
        return .success(stonk)
    }

}
