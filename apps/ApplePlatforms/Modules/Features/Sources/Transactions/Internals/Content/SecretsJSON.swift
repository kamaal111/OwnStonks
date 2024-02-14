//
//  SecretsJSON.swift
//
//
//  Created by Kamaal M Farah on 20/01/2024.
//

import Foundation
import KamaalUtils
import KamaalLogger

private let logger = KamaalLogger(from: SecretsJSON.self, failOnError: true)

struct Secrets: Decodable {
    let stonksKitURL: URL?

    enum CodingKeys: String, CodingKey {
        case stonksKitURL = "stonks_kit_url"
    }
}

class SecretsJSON {
    private(set) var content: Secrets?

    private init() {
        #if DEBUG
        let stonksKitURLFromEnvironment = ProcessInfo.processInfo.environment[Secrets.CodingKeys.stonksKitURL.rawValue]
        assert(
            stonksKitURLFromEnvironment == nil ||
                (stonksKitURLFromEnvironment != nil && URL(string: stonksKitURLFromEnvironment!) != nil)
        )
        if let stonksKitURLFromEnvironment, let stonksKitURL = URL(string: stonksKitURLFromEnvironment) {
            self.content = .init(stonksKitURL: stonksKitURL)
            return
        }
        #endif

        do {
            self.content = try JSONFileUnpacker<Secrets>(filename: "Secrets", bundle: .module).content
        } catch {
            logger.warning("Failed to unpack json file; error=\(error)")
        }
    }

    static let shared = SecretsJSON()
}
