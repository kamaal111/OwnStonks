//
//  AppTransaction.swift
//
//
//  Created by Kamaal M Farah on 03/12/2023.
//

import ForexKit
import Foundation

struct AppTransaction: Hashable, Identifiable {
    let id: UUID?
    let name: String
    let transactionDate: Date
    let transactionType: TransactionTypes
    let amount: Double
    let pricePerUnit: Money
    let fees: Money

    init(
        id: UUID? = nil,
        name: String,
        transactionDate: Date,
        transactionType: TransactionTypes,
        amount: Double,
        pricePerUnit: Money,
        fees: Money
    ) {
        self.id = id
        self.name = name
        self.transactionDate = transactionDate
        self.transactionType = transactionType
        self.amount = amount
        self.pricePerUnit = pricePerUnit
        self.fees = fees
    }
}

struct Money: Hashable {
    let value: Double
    let currency: Currencies
}
