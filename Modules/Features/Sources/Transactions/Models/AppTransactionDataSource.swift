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
    let recordID: CKRecord.ID?

    init(id: UUID? = nil, sourceType: AssetDataSources, ticker: String, recordID: CKRecord.ID?) {
        self.id = id
        self.sourceType = sourceType
        self.ticker = ticker
        self.recordID = recordID
    }

    public static var recordName = "CD_StoredTransactionDataSource"

    static func fromCKRecord(_ record: CKRecord) -> AppTransactionDataSource? {
        guard let id = record[.id] as? String, let id = UUID(uuidString: id) else { return nil }
        guard let sourceType = record[.sourceType] as? String,
              let sourceType = AssetDataSources(rawValue: sourceType) else { return nil }
        guard let ticker = record[.ticker] as? String else { return nil }

        return AppTransactionDataSource(id: id, sourceType: sourceType, ticker: ticker, recordID: record.recordID)
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
