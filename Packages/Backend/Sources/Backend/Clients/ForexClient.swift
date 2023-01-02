//
//  ForexClient.swift
//  
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Models
import Swinject
import ForexAPI
import Foundation

public struct ForexClient {
    private let preview: Bool
    private let cacheUtil = ForexCacheUtil()

    public init(preview: Bool = false) {
        self.preview = preview
    }

    public func getLatest(base: Currencies, symbols: [Currencies]) async -> Result<ExchangeRates?, Errors> {
        guard !preview else { return .success(.preview) }

        return await cacheUtil.cacheLatest(base: base, symbols: symbols, apiCall: { base, symbols in
            await api.latest(base: base, symbols: symbols)
        })
        .mapError({ .getExchangeFailure(context: $0) })
    }

    private var api: ForexAPI {
        container.resolve(ForexAPI.self, argument: preview)!
    }
}

extension ForexClient {
    public enum Errors: Error {
        case getExchangeFailure(context: ForexAPI.Errors)
    }
}
