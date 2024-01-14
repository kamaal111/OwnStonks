//
//  StoredTransactionDataSource+extensions.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import SharedModels
import PersistentData

extension StoredTransactionDataSource {
    var appTransactionDataSource: AppTransactionDataSource? {
        guard let id else { return nil }
        guard let sourceType, let sourceType = AssetDataSources(rawValue: sourceType) else { return nil }
        guard let ticker else { return nil }

        return AppTransactionDataSource(
            id: id,
            sourceType: sourceType,
            ticker: ticker,
            closes: nil,
            updatedDate: updatedDate,
            creationDate: creationDate,
            transactionRecordID: nil,
            recordID: nil
        )
    }
}
