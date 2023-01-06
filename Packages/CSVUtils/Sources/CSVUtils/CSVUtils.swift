//
//  CSVUtils.swift
//
//
//  Created by Kamaal M Farah on 06/01/2023.
//

import Foundation

public struct CSVUtils {
    private init() { }

    public enum DecodingErrors: Error {
        case incorrectEncoding
    }

    public static func decode<Target: Decodable>(
        data: Data,
        seperator: Character,
        encoding: String.Encoding = .utf8) throws -> [Target] {
            guard let string = String(data: data, encoding: encoding) else { throw DecodingErrors.incorrectEncoding }

            let rows = string
                .split(whereSeparator: \.isNewline)
                .map({ $0.split(separator: seperator) })
            guard let header = rows.first else { return [] }

            let dictionary: [[String: String]] = rows[1..<rows.count]
                .map({
                    $0
                        .enumerated()
                        .reduce([:], {
                            var result = $0
                            result[String(header[$1.offset])] = String($1.element)
                            return result
                        })
                })

            let data = try JSONEncoder().encode(dictionary)
            return try JSONDecoder().decode([Target].self, from: data)
        }
}
