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

public struct AppTransaction: Hashable, Identifiable, CloudQueryable {
    public let id: UUID?
    let name: String
    let transactionDate: Date
    let transactionType: TransactionTypes
    let amount: Double
    let pricePerUnit: Money
    let fees: Money
    var recordID: CKRecord.ID?
    let dataSource: AppTransactionDataSource?
    let updatedDate: Date?
    let creationDate: Date?

    init(
        id: UUID? = nil,
        name: String,
        transactionDate: Date,
        transactionType: TransactionTypes,
        amount: Double,
        pricePerUnit: Money,
        fees: Money,
        dataSource: AppTransactionDataSource?,
        updatedDate: Date?,
        creationDate: Date?,
        recordID: CKRecord.ID? = nil
    ) {
        self.id = id
        self.name = name
        self.transactionDate = transactionDate
        self.transactionType = transactionType
        self.amount = amount
        self.pricePerUnit = pricePerUnit
        self.fees = fees
        self.updatedDate = updatedDate
        self.creationDate = creationDate
        self.recordID = recordID
        self.dataSource = dataSource
    }

    var totalPriceExcludingFees: Money {
        Money(value: pricePerUnit.value * amount, currency: pricePerUnit.currency)
    }

    var asCKRecord: CKRecord {
        let initialRecord = if let recordID {
            CKRecord(recordType: Self.recordName, recordID: recordID)
        } else {
            CKRecord(recordType: Self.recordName)
        }
        return CloudKeys.allCases.reduce(initialRecord) { record, key in
            let ckRecordKey = key.ckRecordKey
            switch key {
            case .id: record[ckRecordKey] = id?.uuidString
            case .name: record[ckRecordKey] = name
            case .transactionDate: record[ckRecordKey] = transactionDate
            case .transactionType: record[ckRecordKey] = transactionType.rawValue
            case .amount: record[ckRecordKey] = amount
            case .pricePerUnit: record[ckRecordKey] = pricePerUnit.value
            case .pricePerUnitCurrency: record[ckRecordKey] = pricePerUnit.currency.rawValue
            case .fees: record[ckRecordKey] = fees.value
            case .feesCurrency: record[ckRecordKey] = fees.currency.rawValue
            case .updatedDate: record[ckRecordKey] = updatedDate
            case .creationDate: record[ckRecordKey] = creationDate
            case .dataSource:
                if let dataSourceRecordID = dataSource?.recordID {
                    record[ckRecordKey] = dataSourceRecordID.recordName
                }
            }
            return record
        }
    }

    func setUpdatedDate(_ updatedDate: Date) -> AppTransaction {
        AppTransaction(
            id: id,
            name: name,
            transactionDate: transactionDate,
            transactionType: transactionType,
            amount: amount,
            pricePerUnit: pricePerUnit,
            fees: fees,
            dataSource: dataSource,
            updatedDate: updatedDate,
            creationDate: creationDate
        )
    }

    func setCreationDate(_ creationDate: Date) -> AppTransaction {
        AppTransaction(
            id: id,
            name: name,
            transactionDate: transactionDate,
            transactionType: transactionType,
            amount: amount,
            pricePerUnit: pricePerUnit,
            fees: fees,
            dataSource: dataSource,
            updatedDate: updatedDate,
            creationDate: creationDate
        )
    }

    public static let recordName = "CD_StoredTransaction"

    static func fromCKRecord(_ record: CKRecord, dataSourceRecord: CKRecord?) -> AppTransaction? {
        guard let id = record[.id] as? String, let id = UUID(uuidString: id) else { return nil }
        guard let name = record[.name] as? String else { return nil }
        guard let transactionDate = record[.transactionDate] as? Date else { return nil }
        guard let transactionType = record[.transactionType] as? String,
              let transactionType = TransactionTypes(rawValue: transactionType) else { return nil }
        guard let amount = record[.amount] as? Double else { return nil }
        guard let pricePerUnitValue = record[.pricePerUnit] as? Double,
              let pricePerUnitCurrency = record[.pricePerUnitCurrency] as? String,
              let pricePerUnitCurrency = Currencies(rawValue: pricePerUnitCurrency) else { return nil }
        guard let feesValue = record[.fees] as? Double,
              let feesCurrency = record[.feesCurrency] as? String,
              let feesCurrency = Currencies(rawValue: feesCurrency) else { return nil }

        let pricePerUnit = Money(value: pricePerUnitValue, currency: pricePerUnitCurrency)
        let fees = Money(value: feesValue, currency: feesCurrency)
        var dataSource: AppTransactionDataSource?
        if let dataSourceRecord {
            dataSource = AppTransactionDataSource.fromCKRecord(dataSourceRecord, transactionRecordID: record.recordID)
            assert(dataSource != nil)
        }

        return AppTransaction(
            id: id,
            name: name,
            transactionDate: transactionDate,
            transactionType: transactionType,
            amount: amount,
            pricePerUnit: pricePerUnit,
            fees: fees,
            dataSource: dataSource,
            updatedDate: record[.updatedDate] as? Date,
            creationDate: record[.creationDate] as? Date,
            recordID: record.recordID
        )
    }

    static let preview = AppTransaction(
        name: "Apple",
        transactionDate: Date(timeIntervalSince1970: 1_702_233_813),
        transactionType: .buy,
        amount: 25,
        pricePerUnit: Money(value: 100, currency: .USD),
        fees: Money(value: 1, currency: .EUR),
        dataSource: .init(
            id: UUID(uuidString: "d8613b54-8a45-4b43-a90c-c068b0f8f077")!,
            sourceType: .stocks,
            ticker: "AAPL",
            closes: nil,
            updatedDate: Date(timeIntervalSince1970: 1_702_233_813),
            creationDate: Date(timeIntervalSince1970: 1_702_233_813),
            transactionRecordID: nil,
            recordID: nil
        ),
        updatedDate: Date(timeIntervalSince1970: 1_702_233_813),
        creationDate: Date(timeIntervalSince1970: 1_702_233_813)
    )

    public enum CloudKeys: String, CloudKeyEnumable {
        case id
        case name
        case transactionDate
        case transactionType
        case amount
        case pricePerUnit
        case pricePerUnitCurrency
        case fees
        case feesCurrency
        case updatedDate
        case creationDate
        case dataSource
    }
}

extension CKRecord {
    fileprivate subscript(key: AppTransaction.CloudKeys) -> Any? {
        self[key.ckRecordKey]
    }
}
