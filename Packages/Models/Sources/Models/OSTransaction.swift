//
//  OSTransaction.swift
//  
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import SwiftUI
import OSLocales
import Foundation
import ShrimpExtensions

public struct OSTransaction: Hashable, Codable {
    public let assetName: String
    public let date: Date
    public let type: TransactionTypes
    public let amount: Double
    public let pricePerUnit: Money
    public let fees: Money

    public init(
        assetName: String,
        date: Date,
        type: TransactionTypes,
        amount: Double,
        pricePerUnit: Money,
        fees: Money) {
            self.assetName = assetName
            self.date = date
            self.type = type
            self.amount = amount
            self.pricePerUnit = pricePerUnit
            self.fees = fees
        }
}

public struct Money: Hashable, Codable {
    public let amount: Double
    public let currency: Currencies

    public init(amount: Double, currency: Currencies) {
        self.amount = amount
        self.currency = currency
    }

    public var localized: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency.symbol

        guard let string = formatter.string(from: amount.nsNumber) else {
            assertionFailure("Failed to format money")
            return ""
        }

        return string
    }
}

public enum TransactionTypes: String, CaseIterable, Codable {
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

public enum Currencies: String, CaseIterable, Codable {
    case EUR
    case USD

    public var symbol: String {
        switch self {
        case .EUR:
            return "€"
        case .USD:
            return "$"
        }
    }
}
