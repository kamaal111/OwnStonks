//
//  OSTransaction.swift
//  
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Foundation

public struct OSTransaction: Hashable, Codable {
    public let id: UUID?
    public let assetName: String
    public let date: Date
    public let type: TransactionTypes
    public let amount: Double
    public let pricePerUnit: Money
    public let fees: Money

    public init(
        id: UUID?,
        assetName: String,
        date: Date,
        type: TransactionTypes,
        amount: Double,
        pricePerUnit: Money,
        fees: Money) {
            self.id = id
            self.assetName = assetName
            self.date = date
            self.type = type
            self.amount = amount
            self.pricePerUnit = pricePerUnit
            self.fees = fees
        }
}
