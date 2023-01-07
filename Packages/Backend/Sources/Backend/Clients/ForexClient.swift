//
//  ForexClient.swift
//  
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Models
import ForexAPI
import Foundation

public struct ForexClient {
    private let preview: Bool
    private let cacheUtil = ForexCacheUtil()
    private let forexAPI: ForexAPI

    public init(preview: Bool = false, urlSession: URLSession = .shared) {
        self.forexAPI = ForexAPI(preview: preview, urlSession: urlSession)
        self.preview = preview
    }

    public func getLatest(base: Currencies, symbols: [Currencies]) async -> Result<ExchangeRates?, Errors> {
        guard !preview else { return .success(.preview) }

        return await cacheUtil.cacheLatest(base: base, symbols: symbols, apiCall: { base, symbols in
            await forexAPI.latest(base: base, symbols: symbols)
        })
        .mapError({ .getExchangeFailure(context: $0) })
    }
}

extension ForexClient {
    public enum Errors: Error {
        case getExchangeFailure(context: ForexAPI.Errors)
    }
}
