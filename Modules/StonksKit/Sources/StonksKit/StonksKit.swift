//
//  StonksKit.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import KamaalNetworker

public struct StonksKit {
    public let health: StonksHealth
    public let tickers: StonksTickers

    public init() {
        let networker = KamaalNetworker()
        let cacheStorage = CacheStorage()
        self.init(networker: networker, cacheStorage: cacheStorage)
    }

    init(networker: KamaalNetworker, cacheStorage: CacheStorable) {
        self.health = .init(networker: networker, cacheStorage: cacheStorage)
        self.tickers = .init(networker: networker, cacheStorage: cacheStorage)
    }
}
