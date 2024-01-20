//
//  StonksKit.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import KamaalNetworker

public struct StonksKit {
    public let tickers: StonksTickers

    public init(baseURL: URL) {
        let urlSession = URLSession.shared
        let cacheStorage = StonksKitCacheStorage()
        self.init(baseURL: baseURL, urlSession: urlSession, cacheStorage: cacheStorage)
    }

    public init(baseURL: URL, urlSession: URLSession, cacheStorage: StonksKitCacheStorable) {
        let networker = KamaalNetworker(urlSession: urlSession)
        self.tickers = .init(baseURL: baseURL, networker: networker, cacheStorage: cacheStorage)
    }
}
