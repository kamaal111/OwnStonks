//
//  TransactionTypes.swift
//
//
//  Created by Kamaal M Farah on 28/11/2023.
//

import SwiftUI

enum TransactionTypes: CaseIterable {
    case buy
    case sell

    var color: Color {
        switch self {
        case .buy: .green
        case .sell: .red
        }
    }

    var localized: String {
        switch self {
        case .buy: NSLocalizedString("Buy", bundle: .module, comment: "")
        case .sell: NSLocalizedString("Sell", bundle: .module, comment: "")
        }
    }
}
