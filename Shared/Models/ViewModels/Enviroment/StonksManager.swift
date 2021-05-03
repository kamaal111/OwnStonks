//
//  StonksManager.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 03/05/2021.
//

import Combine
import ConsoleSwift
import Foundation

final class StonksManager: ObservableObject {

    @Published private(set) var stonks: [CoreStonk] = []

    private let persistenceController = PersistenceController.shared

    var portfolioStonks: [StonksData] {
        var groupedStonks: [String: [StonksData]] = [:]
        for stonk in stonks {
            if let symbol = stonk.symbol {
                if groupedStonks[symbol] != nil {
                    groupedStonks[symbol]?.append(stonk.stonksData)
                } else {
                    groupedStonks[symbol] = [stonk.stonksData]
                }
            } else {
                if groupedStonks[stonk.name] != nil {
                    groupedStonks[stonk.name]?.append(stonk.stonksData)
                } else {
                    groupedStonks[stonk.name] = [stonk.stonksData]
                }
            }
        }
        var combinedStonks: [StonksData] = []
        for stonkObject in groupedStonks {
            var costs = 0.0
            var shares = 0.0
            var name: String?
            var symbol: String?
            for stonk in stonkObject.value {
                costs += stonk.costs
                shares += stonk.shares
                if name == nil {
                    name = stonk.name
                }
                if symbol == nil {
                    symbol = stonk.symbol
                }
            }
            if let name = name {
                combinedStonks.append(StonksData(name: name, shares: shares, costs: costs, symbol: symbol))
            }
        }
        return combinedStonks
    }

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

    func setStonk(with args: CoreStonk.Args) {
        let stonkResult = CoreStonk.setStonk(args: args, managedObjectContext: persistenceController.context!)
        let stonk: CoreStonk
        switch stonkResult {
        case .failure(let failure):
            console.error(Date(), failure.localizedDescription, failure)
            return
        case .success(let success):
            stonk = success
        }
        stonks.append(stonk)
    }

}
