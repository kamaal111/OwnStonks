//
//  NetworkCache.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 20/06/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Foundation

class NetworkCache {

    private var cache: [CacheKeys: [String: Data]]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        var cache: [CacheKeys: [String: Data]] = [:]
        for key in CacheKeys.allCases {
            cache[key] = [:]
        }
        self.cache = cache
    }

    enum CacheKeys: CaseIterable {
        case info
    }

    func getCache<T: Codable>(from cacheKey: CacheKeys, with objectKey: String) -> T? {
        guard let data = cache[cacheKey]?[objectKey] else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func setCache<T: Codable>(this object: T, in cacheKey: CacheKeys, with objectKey: String) {
        guard let data = try? encoder.encode(object) else { return }
        cache[cacheKey]?[objectKey] = data
    }

}
