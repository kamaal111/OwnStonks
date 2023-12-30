//
//  TransactionTypes.swift
//
//
//  Created by Kamaal M Farah on 30/12/2023.
//

import SwiftUI

public enum TransactionTypes: String, CaseIterable, LocalizedItem {
    case buy
    case sell

    public var color: Color {
        switch self {
        case .buy: .green
        case .sell: .red
        }
    }

    public var localized: String {
        switch self {
        case .buy: NSLocalizedString("Buy", bundle: .module, comment: "")
        case .sell: NSLocalizedString("Sell", bundle: .module, comment: "")
        }
    }
}
