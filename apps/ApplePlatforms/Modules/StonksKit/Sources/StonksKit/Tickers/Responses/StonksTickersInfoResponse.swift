//
//  StonksTickersInfoResponse.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation

public struct StonksTickersInfoResponse: Codable {
    public let name: String?
    public let close: Double
    public let currency: String
    public let closeDate: String?

    public init(name: String?, close: Double, currency: String, closeDate: String?) {
        self.name = name
        self.close = close
        self.currency = currency
        self.closeDate = closeDate
    }

    enum CodingKeys: String, CodingKey {
        case name
        case close
        case currency
        case closeDate = "close_date"
    }
}
