//
//  AppTransaction.swift
//
//
//  Created by Kamaal M Farah on 03/12/2023.
//

import CloudKit
import ForexKit
import Foundation
import SharedModels
import PersistentData
import KamaalExtensions

struct AppTransaction: Hashable, Identifiable {
    let id: UUID?
    let name: String
    let transactionDate: Date
    let transactionType: TransactionTypes
    let amount: Double
    let pricePerUnit: Money
    let fees: Money
    var recordID: CKRecord.ID?

    init(
        id: UUID? = nil,
        name: String,
        transactionDate: Date,
        transactionType: TransactionTypes,
        amount: Double,
        pricePerUnit: Money,
        fees: Money,
        recordID: CKRecord.ID? = nil
    ) {
        self.id = id
        self.name = name
        self.transactionDate = transactionDate
        self.transactionType = transactionType
        self.amount = amount
        self.pricePerUnit = pricePerUnit
        self.fees = fees
        self.recordID = recordID
    }

    var totalPriceExcludingFees: Money {
        Money(value: pricePerUnit.value * amount, currency: pricePerUnit.currency)
    }

    static func fromCKRecord(_ record: CKRecord) -> AppTransaction? {
        guard let id = record["CD_id"] as? String, let id = UUID(uuidString: id) else { return nil }
        guard let name = record["CD_name"] as? String else { return nil }
        guard let transactionDate = record["CD_transactionDate"] as? Date else { return nil }
        guard let transactionType = record["CD_transactionType"] as? String,
              let transactionType = TransactionTypes(rawValue: transactionType) else { return nil }
        guard let amount = record["CD_amount"] as? Double else { return nil }
        guard let pricePerUnitValue = record["CD_pricePerUnit"] as? Double,
              let pricePerUnitCurrency = record["CD_pricePerUnitCurrency"] as? String,
              let pricePerUnitCurrency = Currencies(rawValue: pricePerUnitCurrency) else { return nil }
        guard let feesValue = record["CD_fees"] as? Double,
              let feesCurrency = record["CD_feesCurrency"] as? String,
              let feesCurrency = Currencies(rawValue: feesCurrency) else { return nil }

        let pricePerUnit = Money(value: pricePerUnitValue, currency: pricePerUnitCurrency)
        let fees = Money(value: feesValue, currency: feesCurrency)

        return AppTransaction(
            id: id,
            name: name,
            transactionDate: transactionDate,
            transactionType: transactionType,
            amount: amount,
            pricePerUnit: pricePerUnit,
            fees: fees,
            recordID: record.recordID
        )
    }

    static let preview = AppTransaction(
        name: "Apple",
        transactionDate: Date(timeIntervalSince1970: 1_702_233_813),
        transactionType: .buy,
        amount: 25,
        pricePerUnit: Money(value: 100, currency: .USD),
        fees: Money(value: 1, currency: .EUR)
    )
}
