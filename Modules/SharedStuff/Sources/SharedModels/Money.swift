//
//  Money.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import ForexKit
import Foundation
import KamaalExtensions

public struct Money: Hashable {
    public let value: Double
    public let currency: Currencies

    public init(value: Double, currency: Currencies) {
        self.value = value
        self.currency = currency
    }

    public var localized: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency.symbol

        guard let string = formatter.string(from: value.nsNumber) else {
            assertionFailure("Failed to format money")
            return ""
        }

        return string
    }
}
