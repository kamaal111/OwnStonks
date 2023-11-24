//
//  JSONUnpacker.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 05/01/2023.
//

import Logster
import Foundation

private let logger = Logster(label: "JSONUnpacker")

class JSONUnpacker<Content: Decodable> {
    var content: Content?

    init(filename: String, ofType fileType: String = "json") {
        guard let path = Bundle.main.path(forResource: filename, ofType: fileType) else {
            logger.warning("json resources with name \(filename) not found")
            assertionFailure("json resources with name \(filename) not found")
            return
        }
        let url = URL(fileURLWithPath: path)
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            logger.error(label: "failed to read json data with name \(filename)", error: error)
            assertionFailure("failed to read json data with name \(filename)")
            return
        }

        let content: Content
        do {
            content = try JSONDecoder().decode(Content.self, from: data)
        } catch {
            logger.error(label: "failed to decode json file with name \(filename)", error: error)
            assertionFailure("failed to decode json file with name \(filename)")
            return
        }

        self.content = content
    }
}
