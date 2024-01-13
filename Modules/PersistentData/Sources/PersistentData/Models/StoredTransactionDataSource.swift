//
//  StoredTransactionDataSource.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import SwiftData
import Foundation
import SharedModels
import SwiftBuilder

@Builder
@Model
public final class StoredTransactionDataSource: Identifiable, Buildable, PersistentStorable {
    public let id: UUID?
    public private(set) var transaction: StoredTransaction?
    public private(set) var sourceType: String?
    public private(set) var ticker: String?
    public private(set) var updatedDate: Date?
    public let creationDate: Date?

    init(
        id: UUID,
        transaction: StoredTransaction?,
        sourceType: AssetDataSources,
        ticker: String,
        updatedDate: Date,
        creationDate: Date
    ) {
        self.id = id
        self.sourceType = sourceType.rawValue
        self.transaction = transaction
        self.ticker = ticker
        self.updatedDate = updatedDate
        self.creationDate = creationDate
    }

    public func update(payload: Payload) throws -> StoredTransactionDataSource {
        sourceType = payload.sourceType.rawValue
        ticker = payload.ticker
        updatedDate = Date()
        assert(modelContext != nil)
        try modelContext?.save()
        return self
    }

    public static func validate(_ container: [BuildableProperties: Any]) -> Bool {
        for property in BuildableProperties.allCases {
            switch property {
            case .id, .sourceType, .updatedDate, .creationDate, .ticker:
                if container[property] == nil {
                    return false
                }
            case .transaction: break
            }
        }
        return true
    }

    public static func build(_ container: [BuildableProperties: Any]) -> StoredTransactionDataSource {
        StoredTransactionDataSource(
            id: container[.id] as! UUID,
            transaction: container[.transaction] as? StoredTransaction,
            sourceType: AssetDataSources(rawValue: container[.sourceType] as! String)!,
            ticker: container[.ticker] as! String,
            updatedDate: container[.updatedDate] as! Date,
            creationDate: container[.creationDate] as! Date
        )
    }

    public static func create(payload: Payload, context: ModelContext?) throws -> StoredTransactionDataSource {
        let dataSource = try Builder()
            .setId(UUID())
            .setTransaction(payload.transaction)
            .setSourceType(payload.sourceType.rawValue)
            .setTicker(payload.ticker)
            .setUpdatedDate(Date())
            .setCreationDate(Date())
            .build()
            .get()
        context?.insert(dataSource)
        return dataSource
    }

    public struct Payload {
        public let id: UUID?
        public let transaction: StoredTransaction?
        public let sourceType: AssetDataSources
        public let ticker: String

        public init(id: UUID?, transaction: StoredTransaction?, sourceType: AssetDataSources, ticker: String) {
            self.id = id
            self.transaction = transaction
            self.sourceType = sourceType
            self.ticker = ticker
        }
    }
}
