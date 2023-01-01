//
//  TransactionDetailSheetContext.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Models
import Foundation

enum TransactionDetailSheetContext {
    case addTransaction
    case editTransaction(transaction: OSTransaction)

    var initialyEditing: Bool {
        switch self {
        case .addTransaction:
            return true
        case .editTransaction:
            return false
        }
    }
}
