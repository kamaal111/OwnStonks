//
//  NetworkController.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 19/06/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Foundation
import StonksNetworker
import ShrimpExtensions
import XiphiasNet
import ConsoleSwift

final class NetworkController {

    private let networker = StonksNetworker()
    private var cache: [CacheKeys: [String: Data]]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        var cache: [CacheKeys: [String: Data]] = [:]
        for key in CacheKeys.allCases {
            cache[key] = [:]
        }
        self.cache = cache
    }

    static let shared = NetworkController()

    private enum CacheKeys: CaseIterable {
        case info
    }

    enum InfoErrors: Error {
        case noSymbol
        case generalError
    }

    @available(macOS 12.0, *)
    func getInfo(of symbol: String, on closeDate: Date) async -> Result<InfoResponse, InfoErrors> {
        guard !symbol.trimmingByWhitespacesAndNewLines.isEmpty else {
            return .failure(.noSymbol)
        }
        let formattedCloseDate = closeDate.getFormattedDateString(withFormat: "yyyy-MM-dd")
        let cacheKey = "\(symbol)-\(formattedCloseDate)"
        if let responseFromCache = cache[.info]?[cacheKey],
            let decodedResponseFromCache = try? decoder.decode(InfoResponse.self, from: responseFromCache) {
            return .success(decodedResponseFromCache)
        }
        let queryItems = [
            "close_date": formattedCloseDate
        ].urlQueryItems
        let result = await networker.getInfo(of: symbol, with: queryItems)
        let info: InfoResponse
        switch result {
        case let .failure(error):
            console.log(Date(), error.localizedDescription, error)
            if let error = error as? XiphiasNet.NetworkerErrors {
                switch error {
                case .responseError(_, _): return .failure(.generalError)
                case .dataError, .notAValidJSON: return .failure(.generalError)
                }
            }
            return .failure(.generalError)
        case let .success(success):
            guard let success = success, let infoValue = success.first?.value else {
                return .failure(.generalError)
            }
            info = infoValue
        }
        if let encodedInfo = try? encoder.encode(info) {
            cache[.info]?[cacheKey] = encodedInfo
        }
        return .success(info)
    }

}
