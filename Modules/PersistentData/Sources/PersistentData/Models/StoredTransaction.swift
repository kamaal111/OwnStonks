//
//  StoredTransaction.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import CloudKit
import ForexKit
import SwiftData
import Foundation
import SharedModels
import KamaalExtensions

@Model
public final class StoredTransaction: Identifiable {
    public let id: UUID?
    public private(set) var name: String?
    public private(set) var transactionDate: Date?
    public private(set) var transactionType: String?
    public private(set) var amount: Double?
    public private(set) var pricePerUnit: Double?
    public private(set) var pricePerUnitCurrency: String?
    public private(set) var fees: Double?
    public private(set) var feesCurrency: String?
    public private(set) var assetDataSource: String?
    public private(set) var updatedDate: Date?
    public let creationDate: Date?

    init(
        id: UUID,
        name: String,
        transactionDate: Date,
        transactionType: String,
        amount: Double,
        pricePerUnit: Money,
        fees: Money,
        assetDataSource: AssetDataSources?,
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
        self.assetDataSource = assetDataSource?.rawValue
        self.updatedDate = updatedDate
        self.creationDate = creationDate
    }

    public func delete() {
        assert(modelContext != nil)
        modelContext?.delete(self)
    }

    public func update(payload: Payload) throws -> StoredTransaction {
        name = payload.name
        transactionDate = payload.transactionDate
        transactionType = payload.transactionType.rawValue
        amount = payload.amount
        pricePerUnit = payload.pricePerUnit.value
        pricePerUnitCurrency = payload.pricePerUnit.currency.rawValue
        fees = payload.fees.value
        assetDataSource = payload.assetDataSource?.rawValue
        feesCurrency = payload.fees.currency.rawValue
        updatedDate = Date()
        assert(modelContext != nil)
        try modelContext?.save()
        return self
    }

    public static func create(payload: Payload, context: ModelContext) -> StoredTransaction {
        let transaction = StoredTransaction(
            id: UUID(),
            name: payload.name,
            transactionDate: payload.transactionDate,
            transactionType: payload.transactionType.rawValue,
            amount: payload.amount,
            pricePerUnit: payload.pricePerUnit,
            fees: payload.fees,
            assetDataSource: payload.assetDataSource
        )
        context.insert(transaction)
        return transaction
    }

    public struct Payload {
        public let name: String
        public let transactionDate: Date
        public let transactionType: TransactionTypes
        public let amount: Double
        public let pricePerUnit: Money
        public let fees: Money
        public let assetDataSource: AssetDataSources?

        public init(
            name: String,
            transactionDate: Date,
            transactionType: TransactionTypes,
            amount: Double,
            pricePerUnit: Money,
            fees: Money,
            assetDataSource: AssetDataSources?
        ) {
            self.name = name
            self.transactionDate = transactionDate
            self.transactionType = transactionType
            self.amount = amount
            self.pricePerUnit = pricePerUnit
            self.fees = fees
            self.assetDataSource = assetDataSource
        }
    }
}
