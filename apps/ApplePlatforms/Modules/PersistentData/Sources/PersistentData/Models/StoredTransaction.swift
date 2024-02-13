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
public final class StoredTransaction: Identifiable, Buildable, PersistentStorable {
    public let id: UUID?
    public private(set) var name: String?
    public private(set) var transactionDate: Date?
    public private(set) var transactionType: String?
    public private(set) var amount: Double?
    public private(set) var pricePerUnit: Double?
    public private(set) var pricePerUnitCurrency: String?
    public private(set) var fees: Double?
    public private(set) var feesCurrency: String?
    @Relationship(deleteRule: .cascade, inverse: \StoredTransactionDataSource.transaction)
    public private(set) var dataSource: StoredTransactionDataSource?
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
        dataSource: StoredTransactionDataSource?,
        updatedDate: Date,
        creationDate: Date
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
        self.dataSource = dataSource
        self.updatedDate = updatedDate
        self.creationDate = creationDate
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
            case .dataSource: break
            }
        }

        return true
    }

    public static func build(_ container: [BuildableProperties: Any]) -> StoredTransaction {
        StoredTransaction(
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
            dataSource: container[.dataSource] as? StoredTransactionDataSource,
            updatedDate: container[.updatedDate] as! Date,
            creationDate: container[.creationDate] as! Date
        )
    }

    @MainActor
    public func update(payload: Payload) throws -> StoredTransaction {
        guard let context = modelContext else {
            assertionFailure("Expected context to exist at this point")
            return self
        }
        name = payload.name
        transactionDate = payload.transactionDate
        transactionType = payload.transactionType.rawValue
        amount = payload.amount
        pricePerUnit = payload.pricePerUnit.value
        pricePerUnitCurrency = payload.pricePerUnit.currency.rawValue
        fees = payload.fees.value
        feesCurrency = payload.fees.currency.rawValue
        updatedDate = Date()
        try Self.updatedDataSource(self, with: payload.dataSource, context: context)
        try context.save()
        return self
    }

    @MainActor
    public static func create(payload: Payload, context: ModelContext?) throws -> StoredTransaction {
        guard let context else {
            assertionFailure("Context should be present")
            throw StoredTransactionErrors.creationFailure
        }

        let dataSource = try updatedDataSource(nil, with: payload.dataSource, context: nil)
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
            .setDataSource(dataSource)
            .setUpdatedDate(Date())
            .setCreationDate(Date())
            .build()
            .get()
        context.insert(transaction)

        return transaction
    }

    @MainActor
    @discardableResult
    private static func updatedDataSource(
        _ transaction: StoredTransaction?,
        with dataSource: StoredTransactionDataSource.Payload?,
        context: ModelContext?
    ) throws -> StoredTransactionDataSource? {
        if let dataSource {
            if let storedDataSource = transaction?.dataSource {
                let updatedDataSource = try storedDataSource.update(payload: dataSource)
                return updatedDataSource
            }

            let newDataSource = try StoredTransactionDataSource.create(payload: dataSource, context: context)
            return newDataSource
        }

        if let storedDataSource = transaction?.dataSource {
            storedDataSource.delete()
            return nil
        }

        return nil
    }

    public struct Payload {
        public let name: String
        public let transactionDate: Date
        public let transactionType: TransactionTypes
        public let amount: Double
        public let pricePerUnit: Money
        public let fees: Money
        public let dataSource: StoredTransactionDataSource.Payload?

        public init(
            name: String,
            transactionDate: Date,
            transactionType: TransactionTypes,
            amount: Double,
            pricePerUnit: Money,
            fees: Money,
            dataSource: StoredTransactionDataSource.Payload?
        ) {
            self.name = name
            self.transactionDate = transactionDate
            self.transactionType = transactionType
            self.amount = amount
            self.pricePerUnit = pricePerUnit
            self.fees = fees
            self.dataSource = dataSource
        }
    }
}

public enum StoredTransactionErrors: Error {
    case creationFailure
}
