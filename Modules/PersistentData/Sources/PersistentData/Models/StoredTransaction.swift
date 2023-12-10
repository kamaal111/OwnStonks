//
//  StoredTransaction.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import ForexKit
import SwiftData
import Foundation
import KamaalExtensions

@Model
public final class StoredTransaction: Identifiable {
    public let id: UUID?
    public let name: String?
    public let transactionDate: Date?
    public let transactionType: String?
    public let amount: Double?
    public let pricePerUnit: Double?
    public let pricePerUnitCurrency: String?
    public let fees: Double?
    public let feesCurrency: String?
    public let updatedDate: Date?
    public let creationDate: Date?

    init(
        id: UUID,
        name: String,
        transactionDate: Date,
        transactionType: String,
        amount: Double,
        pricePerUnit: (value: Double, currency: Currencies),
        fees: (value: Double, currency: Currencies),
        updatedDate: Date = Date(),
        creationDate: Date = Date()
    ) {
        assert(!name.trimmingByWhitespacesAndNewLines.isEmpty)
        self.id = id
        self.name = name
        self.transactionDate = transactionDate
        self.transactionType = transactionType
        self.amount = amount
        self.pricePerUnit = pricePerUnit.value
        self.pricePerUnitCurrency = pricePerUnit.currency.rawValue
        self.fees = fees.value
        self.feesCurrency = fees.currency.rawValue
        self.updatedDate = updatedDate
        self.creationDate = creationDate
    }

    public static func create(
        name: String,
        transactionDate: Date,
        transactionType: String,
        amount: Double,
        pricePerUnit: (value: Double, currency: Currencies),
        fees: (value: Double, currency: Currencies),
        context: ModelContext
    ) -> StoredTransaction {
        let transaction = StoredTransaction(
            id: UUID(),
            name: name,
            transactionDate: transactionDate,
            transactionType: transactionType,
            amount: amount,
            pricePerUnit: pricePerUnit,
            fees: fees
        )
        context.insert(transaction)
        return transaction
    }
}
