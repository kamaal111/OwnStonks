//
//  InfoResponse.swift
//  
//
//  Created by Kamaal M Farah on 21/06/2021.
//

import Foundation

public struct InfoResponse: Codable {
    public let currency: String?
    public let logoUrl: URL?
    public let longName: String?
    public let close: Double
    public let shortName: String?
    public let symbol: String

    public init(
        currency: String?,
        logoUrl: URL?,
        longName: String?,
        close: Double,
        shortName: String?,
        symbol: String) {
        self.currency = currency
        self.logoUrl = logoUrl
        self.longName = longName
        self.close = close
        self.shortName = shortName
        self.symbol = symbol
    }

    public enum CodingKeys: String, CodingKey {
        case currency
        case logoUrl = "logo_url"
        case longName = "long_name"
        case close = "close"
        case shortName = "short_name"
        case symbol
    }
}
