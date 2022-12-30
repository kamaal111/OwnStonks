//
//  TransactionTypes.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 30/12/2022.
//

import OSLocales
import Foundation

enum TransactionTypes: CaseIterable {
    case buy
    case sell

    var localized: String {
        switch self {
        case .buy:
            return OSLocales.getText(.BUY)
        case .sell:
            return OSLocales.getText(.SELL)
        }
    }
}
