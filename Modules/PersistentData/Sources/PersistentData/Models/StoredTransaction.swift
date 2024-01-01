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
import SwiftBuilder
import KamaalExtensions

@Builder
@Model
public final class StoredTransaction: Identifiable, Buildable {
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
        transactionType: TransactionTypes,
        amount: Double,
        pricePerUnit: Money,
        fees: Money,
        assetDataSource: AssetDataSources?,
        updatedDate: Date = Date(),
        creationDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.transactionDate = transactionDate
        self.transactionType = transactionType.rawValue
        self.amount = amount
        self.pricePerUnit = pricePerUnit.value
        self.pricePerUnitCurrency = pricePerUnit.currency.rawValue
        self.fees = fees.value
        self.feesCurrency = fees.currency.rawValue
        self.assetDataSource = assetDataSource?.rawValue
        self.updatedDate = updatedDate
        self.creationDate = creationDate
    }

    public var assetDataSourceFormatted: AssetDataSources? {
        guard let assetDataSource else { return nil }
        return AssetDataSources(rawValue: assetDataSource)
    }

    public var pricePerUnitFormatted: Money? {
        guard let pricePerUnit,
              let pricePerUnitCurrency,
              let pricePerUnitCurrency = Currencies(rawValue: pricePerUnitCurrency) else { return nil }
        return Money(value: pricePerUnit, currency: pricePerUnitCurrency)
    }

    public var feesFormatted: Money? {
        guard let fees,
              let feesCurrency,
              let feesCurrency = Currencies(rawValue: feesCurrency) else { return nil }
        return Money(value: fees, currency: feesCurrency)
    }

    public var transactionTypeFormatted: TransactionTypes? {
        guard let transactionType else { return nil }
        return TransactionTypes(rawValue: transactionType)
    }

    public static func validate(_ container: [BuildableProperties: Any]) -> Bool {
        for property in BuildableProperties.allCases {
            switch property {
            case .id,
                 .transactionDate,
                 .transactionType,
                 .amount,
                 .pricePerUnit,
                 .pricePerUnitCurrency,
                 .fees,
                 .feesCurrency,
                 .updatedDate,
                 .creationDate:
                if container[property] == nil {
                    return false
                }
            case .name:
                guard let value = container[property] as? String else { return false }
                if value.trimmingByWhitespacesAndNewLines.isEmpty {
                    return false
                }
            case .assetDataSource: break
            }
        }

        return true
    }

    public static func build(_ container: [BuildableProperties: Any]) -> StoredTransaction {
        var assetDataSource: AssetDataSources?
        if let assetDataSourceFromContainer = container[.assetDataSource] as? String {
            assetDataSource = AssetDataSources(rawValue: assetDataSourceFromContainer)
        }

        return StoredTransaction(
            id: container[.id] as! UUID,
            name: container[.name] as! String,
            transactionDate: container[.transactionDate] as! Date,
            transactionType: TransactionTypes(rawValue: container[.transactionType] as! String)!,
            amount: container[.amount] as! Double,
            pricePerUnit: Money(
                value: container[.pricePerUnit] as! Double,
                currency: Currencies(rawValue: container[.pricePerUnitCurrency] as! String)!
            ),
            fees: Money(
                value: container[.fees] as! Double,
                currency: Currencies(rawValue: container[.feesCurrency] as! String)!
            ),
            assetDataSource: assetDataSource,
            updatedDate: container[.updatedDate] as! Date,
            creationDate: container[.creationDate] as! Date
        )
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

    public static func create(payload: Payload, context: ModelContext) throws -> StoredTransaction {
        let transaction = try StoredTransaction
            .Builder()
            .setId(UUID())
            .setName(payload.name)
            .setTransactionDate(payload.transactionDate)
            .setTransactionType(payload.transactionType.rawValue)
            .setAmount(payload.amount)
            .setPricePerUnit(payload.pricePerUnit.value)
            .setPricePerUnitCurrency(payload.pricePerUnit.currency.rawValue)
            .setFees(payload.fees.value)
            .setFeesCurrency(payload.fees.currency.rawValue)
            .setAssetDataSource(payload.assetDataSource?.rawValue)
            .setUpdatedDate(Date())
            .setCreationDate(Date())
            .build()
            .get()
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
