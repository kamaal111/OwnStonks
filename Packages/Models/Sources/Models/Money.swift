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

    static func fromString(string: String) -> Money? {
        let string = string.trimmingByWhitespacesAndNewLines
        guard let startNumberIndex = string.firstIndex(where: \.isNumber),
              let endNumberIndex = string.lastIndex(where: \.isNumber) else { return nil }

        let rawAmount = string[startNumberIndex...endNumberIndex]
        let rawAmountCount = rawAmount.count
        var seperatorIndex: Int?
        let seperators: [Character] = [".", ","]
        if rawAmountCount > 1 {
            for index in 0..<rawAmountCount {
                let characterIndex = rawAmountCount - index - 1
                let character = rawAmount[characterIndex]
                if seperators.contains(character) {
                    seperatorIndex = characterIndex
                    break
                }
            }
        }

        let amount = Double(String(rawAmount
            .enumerated()
            .filter({ $0.offset == seperatorIndex || !seperators.contains($0.element) })
            .map(\.element))
            .replacingOccurrences(of: ",", with: "."))

        guard let amount else { return nil }

        let currencyString: String.SubSequence
        if startNumberIndex != string.startIndex {
            currencyString = string[string.startIndex..<startNumberIndex]
        } else {
            currencyString = string[string.index(endNumberIndex, offsetBy: 1)..<string.endIndex]
        }

        guard let currency = Currencies.fromSymbol(String(currencyString).trimmingByWhitespacesAndNewLines)
        else { return nil }

        return Money(amount: amount, currency: currency)
    }
}
