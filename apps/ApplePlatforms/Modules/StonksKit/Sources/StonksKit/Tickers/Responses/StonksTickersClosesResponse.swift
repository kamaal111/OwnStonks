//
//  StonksTickersClosesResponse.swift
//
//
//  Created by Kamaal M Farah on 13/01/2024.
//

import Foundation
import KamaalExtensions

public struct StonksTickersClosesResponse: Codable {
    public let closes: [String: Double]
    public let currency: String

    public init(closes: [String: Double], currency: String) {
        self.closes = closes
        self.currency = currency
    }

    public var closesMappedByDates: [Date: Double] {
        closes
            .reduce([:]) { result, dict in
                guard let dateString = dict.key.split(separator: "T").first else {
                    assertionFailure("Should pass this")
                    return result
                }

                guard let date = Self.dateFormatter.date(from: String(dateString)) else {
                    assertionFailure("Should pass this")
                    return result
                }
                return result.merged(with: [date: dict.value])
            }
    }

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
}
