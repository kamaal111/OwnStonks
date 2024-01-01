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
    public let currency: String?
    public let symbol: String
    public let closeDate: String?

    enum CodingKeys: String, CodingKey {
        case name
        case close
        case currency
        case symbol
        case closeDate = "close_date"
    }
}
