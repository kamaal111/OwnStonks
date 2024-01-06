//
//  CacheStorage.swift
//
//
//  Created by Kamaal M Farah on 06/01/2024.
//

import Foundation
import KamaalUtils

protocol CacheStorable {
    var stonksAPIGetCache: [URL: Data]? { get set }
}

extension CacheStorable {
    func getStonksAPIGetCache<T: Decodable>(from url: URL, ofType type: T.Type) throws -> T? {
        guard let cachedValue = stonksAPIGetCache?[url] else { return nil }

        return try JSONDecoder().decode(type, from: cachedValue)
    }

    mutating func setStonksAPIGetCache(on url: URL, data: some Encodable) throws {
        let data = try JSONEncoder().encode(data)
        if stonksAPIGetCache == nil {
            stonksAPIGetCache = [url: data]
        } else {
            stonksAPIGetCache![url] = data
        }
    }
}

struct CacheStorage: CacheStorable {
    @UserDefaultsObject(key: "io.kamaal.swift-stonks-api.get_cache")
    var stonksAPIGetCache: [URL: Data]?
}
