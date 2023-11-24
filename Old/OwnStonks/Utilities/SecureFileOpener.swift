//
//  SecureFileOpener.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 05/01/2023.
//

import Logster
import Foundation

private let logger = Logster(from: SecureFileOpener.self)

struct SecureFileOpener {
    private init() { }

    static func readData(from url: URL) throws -> Data? {
        guard url.startAccessingSecurityScopedResource() else {
            logger.warning("Not allowed to access file")
            assertionFailure("Not allowed to access file")
            return nil
        }

        let content = try Data(contentsOf: url)
        url.stopAccessingSecurityScopedResource()
        return content
    }
}
