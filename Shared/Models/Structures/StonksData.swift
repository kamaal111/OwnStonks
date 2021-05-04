//
//  StonksData.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 01/05/2021.
//

import Foundation

struct StonksData: Hashable {
    let name: String
    let shares: Double
    let costs: Double
    let transactionDate: Date
    let symbol: String?

    init(name: String, shares: Double, costs: Double, transactionDate: Date, symbol: String? = nil) {
        self.name = name
        self.shares = shares
        self.costs = costs
        self.transactionDate = transactionDate
        self.symbol = symbol
    }
}
