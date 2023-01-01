//
//  Money.swift
//  
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Foundation
import ShrimpExtensions

public struct Money: Hashable, Codable, Localized {
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
