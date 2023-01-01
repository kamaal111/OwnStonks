//
//  TransactionTypes.swift
//  
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import SwiftUI
import OSLocales

public enum TransactionTypes: String, CaseIterable, Codable, Localized {
    case buy
    case sell

    public var color: Color {
        switch self {
        case .buy:
            return .green
        case .sell:
            return .red
        }
    }

    public var localized: String {
        switch self {
        case .buy:
            return OSLocales.getText(.BUY)
        case .sell:
            return OSLocales.getText(.SELL)
        }
    }
}
