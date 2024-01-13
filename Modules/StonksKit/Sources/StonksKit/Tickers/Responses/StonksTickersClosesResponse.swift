//
//  StonksTickersClosesResponse.swift
//
//
//  Created by Kamaal M Farah on 13/01/2024.
//

import Foundation

public struct StonksTickersClosesResponse: Codable {
    public let closes: [String: Double]
    public let currency: String

    public init(closes: [String: Double], currency: String) {
        self.closes = closes
        self.currency = currency
    }

    public var closesMappedByDates: [Date: Double] {
        var closesMappedByDates: [Date: Double] = [:]
        for (key, close) in closes {
            guard let dateString = key.split(separator: "T").first else {
                assertionFailure("Should pass this")
                continue
            }

            guard let date = Self.dateFormatter.date(from: String(dateString)) else {
                assertionFailure("Should pass this")
                continue
            }
            closesMappedByDates[date] = close
        }
        return closesMappedByDates
    }

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
}
