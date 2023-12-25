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
    public private(set) var updatedDate: Date?
    public let creationDate: Date?

    @Transient
    public private(set) var recordID: CKRecord.ID?

    init(
        id: UUID,
        name: String,
        transactionDate: Date,
        transactionType: String,
        amount: Double,
        pricePerUnit: Money,
        fees: Money,
        updatedDate: Date = Date(),
        creationDate: Date = Date(),
        recordID: CKRecord.ID? = nil
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
        self.recordID = recordID
    }

    public func delete() {
        modelContext?.delete(self)
    }

    public func update(
        name: String,
        transactionDate: Date,
        transactionType: String,
        amount: Double,
        pricePerUnit: (value: Double, currency: Currencies),
        fees: (value: Double, currency: Currencies)
    ) throws -> StoredTransaction {
        self.name = name
        self.transactionDate = transactionDate
        self.transactionType = transactionType
        self.amount = amount
        self.pricePerUnit = pricePerUnit.value
        pricePerUnitCurrency = pricePerUnit.currency.rawValue
        self.fees = fees.value
        feesCurrency = fees.currency.rawValue
        updatedDate = Date()
        try modelContext?.save()
        return self
    }

    public static func create(
        name: String,
        transactionDate: Date,
        transactionType: String,
        amount: Double,
        pricePerUnit: Money,
        fees: Money,
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
