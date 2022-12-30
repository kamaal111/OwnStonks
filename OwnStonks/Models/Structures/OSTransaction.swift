//
//  OSTransaction.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 30/12/2022.
//

import Foundation

struct OSTransaction: Hashable, Codable {
    let assetName: String
    let date: Date
    let type: TransactionTypes
    let amount: Double
    let pricePerUnit: Money
    let fees: Money
}

struct Money: Hashable, Codable {
    let amount: Double
    let currency: Currencies
}
