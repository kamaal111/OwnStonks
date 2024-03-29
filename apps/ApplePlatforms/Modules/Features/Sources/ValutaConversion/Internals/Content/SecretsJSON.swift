//
//  SecretsJSON.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import Foundation
import KamaalUtils
import KamaalLogger

private let logger = KamaalLogger(from: SecretsJSON.self, failOnError: true)

struct Secrets: Decodable {
    let forexAPIURL: URL?

    enum CodingKeys: String, CodingKey {
        case forexAPIURL = "forex_api_url"
    }
}

class SecretsJSON {
    private(set) var content: Secrets?

    private init() {
        do {
            self.content = try JSONFileUnpacker<Secrets>(filename: "Secrets", bundle: .module).content
        } catch {
            logger.error(label: "Failed to unpack json file", error: error)
        }
    }

    static let shared = SecretsJSON()
}
