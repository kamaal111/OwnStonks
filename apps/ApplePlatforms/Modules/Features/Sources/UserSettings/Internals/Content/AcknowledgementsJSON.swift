//
//  AcknowledgementsJSON.swift
//
//
//  Created by Kamaal M Farah on 17/12/2023.
//

import Foundation
import KamaalUtils
import KamaalLogger
import KamaalSettings

private let logger = KamaalLogger(from: AcknowledgementsJSON.self, failOnError: true)

class AcknowledgementsJSON {
    private(set) var content: Acknowledgements?

    private init() {
        do {
            self.content = try JSONFileUnpacker<Acknowledgements>(filename: "Acknowledgements", bundle: .module).content
        } catch {
            logger.error(label: "Failed to unpack json file", error: error)
        }
    }

    static let shared = AcknowledgementsJSON()
}
