//
//  StonksManager.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 03/05/2021.
//

import Combine
import ConsoleSwift
import Foundation
import ShrimpExtensions

final class StonksManager: ObservableObject {

    @Published private(set) var stonks: [CoreStonk] = []

    private let persistenceController = PersistenceController.shared

    init() {
        let fetchResult = persistenceController.fetch(CoreStonk.self)
        switch fetchResult {
        case .failure(let failure):
            console.error(Date(), failure.localizedDescription, failure)
            return
        case .success(let success):
            if let success = success {
                self.stonks = success
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

    var portfolioStonks: [StonksData] {
        var combinedStonks: [String: StonksData] = [:]
        for stonk in stonks {
            if let symbol = stonk.symbol {
                if let stonkInCombinedStonks = combinedStonks[symbol] {
                    combinedStonks[symbol] = StonksData(name: stonk.name,
                                                        shares: stonk.shares + stonkInCombinedStonks.shares,
                                                        costs: stonk.costs + stonkInCombinedStonks.costs,
                                                        transactionDate: stonk.transactionDate,
                                                        symbol: symbol)
                } else {
                    combinedStonks[symbol] = stonk.stonksData
                }
            } else {
                if let stonkInCombinedStonks = combinedStonks[stonk.name] {
                    combinedStonks[stonk.name] = StonksData(name: stonk.name,
                                                            shares: stonk.shares + stonkInCombinedStonks.shares,
                                                            costs: stonk.costs + stonkInCombinedStonks.costs,
                                                            transactionDate: stonk.transactionDate)
                } else {
                    combinedStonks[stonk.name] = stonk.stonksData
                }
            }
        }
        return combinedStonks.map(\.value)
    }

    func setStonk(with args: CoreStonk.Args) -> Result<CoreStonk, Errors> {
        guard !args.name.trimmingByWhitespacesAndNewLines.isEmpty else { return .failure(.invalidStonkName) }
        guard !args.shares.isZero else { return .failure(.invalidAmountOfShares) }
        let stonkResult = CoreStonk.setStonk(args: args, managedObjectContext: persistenceController.context!)
        let stonk: CoreStonk
        switch stonkResult {
        case .failure(let failure): return .failure(.generalError(error: failure))
        case .success(let success): stonk = success
        }
        stonks.append(stonk)
        return .success(stonk)
    }

}
