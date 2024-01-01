//
//  StoredTransaction+extensions.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import ForexKit
import Foundation
import SharedModels
import PersistentData

extension StoredTransaction {
    var appTransaction: AppTransaction? {
        guard let id else { return nil }
        guard let name, !name.trimmingByWhitespacesAndNewLines.isEmpty else { return nil }
        guard let transactionDate else { return nil }
        guard let transactionType = transactionTypeFormatted else { return nil }
        guard let amount else { return nil }
        guard let pricePerUnit = pricePerUnitFormatted else { return nil }
        guard let fees = feesFormatted else { return nil }

        return AppTransaction(
            id: id,
            name: name,
            transactionDate: transactionDate,
            transactionType: transactionType,
            amount: amount,
            pricePerUnit: pricePerUnit,
            fees: fees,
            assetDataSource: assetDataSourceFormatted,
            updatedDate: updatedDate,
            creationDate: creationDate
        )
    }
}
