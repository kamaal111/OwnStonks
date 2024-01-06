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
        let urlSession = URLSession.shared
        let cacheStorage = StonksKitCacheStorage()
        self.init(urlSession: urlSession, cacheStorage: cacheStorage)
    }

    public init(urlSession: URLSession, cacheStorage: StonksKitCacheStorable) {
        let networker = KamaalNetworker(urlSession: urlSession)
        self.health = .init(networker: networker, cacheStorage: cacheStorage)
        self.tickers = .init(networker: networker, cacheStorage: cacheStorage)
    }
}
