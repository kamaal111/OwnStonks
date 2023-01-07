//
//  File.swift
//  
//
//  Created by Kamaal M Farah on 07/01/2023.
//

import Foundation

extension StringProtocol {
    var localizedStringToDouble: Double? {
        let string = self.trimmingByWhitespacesAndNewLines
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

        return Double(String(rawAmount
            .enumerated()
            .filter({ $0.offset == seperatorIndex || !seperators.contains($0.element) })
            .map(\.element))
            .replacingOccurrences(of: ",", with: "."))
    }
}
