//
//  AppTransactionDataSource.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import CloudKit
import Foundation
import SharedModels
import PersistentData

public struct AppTransactionDataSource: Hashable, Identifiable, CloudQueryable {
    public let id: UUID?
    let sourceType: AssetDataSources
    let ticker: String
    let updatedDate: Date?
    let creationDate: Date?
    let transactionRecordID: CKRecord.ID?
    let recordID: CKRecord.ID?

    init(
        id: UUID? = nil,
        sourceType: AssetDataSources,
        ticker: String,
        updatedDate: Date?,
        creationDate: Date?,
        transactionRecordID: CKRecord.ID?,
        recordID: CKRecord.ID?
    ) {
        self.id = id
        self.sourceType = sourceType
        self.ticker = ticker
        self.transactionRecordID = transactionRecordID
        self.updatedDate = updatedDate
        self.creationDate = creationDate
        self.recordID = recordID
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
            case .sourceType: record[ckRecordKey] = sourceType.rawValue
            case .ticker: record[ckRecordKey] = ticker
            case .updatedDate: record[ckRecordKey] = updatedDate
            case .creationDate: record[ckRecordKey] = creationDate
            case .transaction: record[ckRecordKey] = transactionRecordID?.recordName
            }
            return record
        }
    }

    public static var recordName = "CD_StoredTransactionDataSource"

    static func fromCKRecord(_ record: CKRecord, transactionRecordID: CKRecord.ID?) -> AppTransactionDataSource? {
        guard let id = record[.id] as? String, let id = UUID(uuidString: id) else { return nil }
        guard let sourceType = record[.sourceType] as? String,
              let sourceType = AssetDataSources(rawValue: sourceType) else { return nil }
        guard let ticker = record[.ticker] as? String else { return nil }

        return AppTransactionDataSource(
            id: id,
            sourceType: sourceType,
            ticker: ticker,
            updatedDate: record[.updatedDate] as? Date,
            creationDate: record[.creationDate] as? Date,
            transactionRecordID: transactionRecordID,
            recordID: record.recordID
        )
    }

    public enum CloudKeys: String, CloudKeyEnumable {
        case id
        case sourceType
        case ticker
        case updatedDate
        case creationDate
        case transaction
    }
}

extension CKRecord {
    fileprivate subscript(key: AppTransactionDataSource.CloudKeys) -> Any? {
        self[key.ckRecordKey]
    }
}
