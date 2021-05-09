//
//  PortfolioItem.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 06/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Foundation

struct PortfolioItem: Hashable {
    let name: String
    let shares: Double
    let totalPrice: Double
    let symbol: String?
    let id: UUID
    private let coreObject: CoreTransaction?

    init(
        name: String,
        shares: Double,
        totalPrice: Double,
        id: UUID,
        symbol: String? = nil) {
        self.name = name
        self.shares = shares
        self.totalPrice = totalPrice
        self.symbol = symbol
        self.id = id
        self.coreObject = nil
    }

    init(coreObject: CoreTransaction) {
        self.name = coreObject.name
        self.shares = coreObject.shares
        self.totalPrice = coreObject.costPerShare * coreObject.shares
        self.symbol = coreObject.symbol
        self.id = coreObject.id
        self.coreObject = coreObject
    }
}
