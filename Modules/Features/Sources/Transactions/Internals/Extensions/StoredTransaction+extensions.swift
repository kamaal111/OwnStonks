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
        guard let transactionType, let transactionType = TransactionTypes(rawValue: transactionType) else { return nil }
        guard let amount else { return nil }
        guard let pricePerUnit,
              let pricePerUnitCurrency,
              let pricePerUnitCurrency = Currencies(rawValue: pricePerUnitCurrency) else { return nil }
        guard let fees, let feesCurrency, let feesCurrency = Currencies(rawValue: feesCurrency) else { return nil }

        return AppTransaction(
            id: id,
            name: name,
            transactionDate: transactionDate,
            transactionType: transactionType,
            amount: amount,
            pricePerUnit: Money(value: pricePerUnit, currency: pricePerUnitCurrency),
            fees: Money(value: fees, currency: feesCurrency),
            updatedDate: updatedDate,
            creationDate: creationDate
        )
    }
}
