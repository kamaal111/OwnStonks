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

/// This class manages all core data objects
final class StonksManager: ObservableObject {

    @Published private(set) var transactions: [CoreTransaction] = []

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
                return "Invalid stonk name provided"
            case .invalidAmountOfShares:
                return "Invalid amount of shares"
            case .generalError(let error):
                return "Something went wrong \(error)"
            }
        }
    }

    var portfolioStonks: [CoreTransaction.Hasher] {
        var combinedTranactions: [String: CoreTransaction.Hasher] = [:]
        for transaction in transactions {
            if let symbol = transaction.symbol {
                if let transactionInCombinedTransactions = combinedTranactions[symbol] {
                } else {
                }
            } else {
                if let transactionInCombinedTransactions = combinedTranactions[transaction.name] {
                } else {
                }
            }
        }
        return combinedTranactions.map(\.value)
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
