//
//  StonksHealthPingResponse.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation

public struct StonksHealthPingResponse: Codable {
    public let message: String

    public init(message: String) {
        self.message = message
    }
}
