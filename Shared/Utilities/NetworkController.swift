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
    private let cache = NetworkCache()

    private init() { }

    static let shared = NetworkController()

    enum InfoErrors: Error {
        case noSymbol
        case generalError
    }

    @available(macOS 12.0, *)
    func getInfo(of symbol: String, on closeDate: Date) async -> Result<InfoResponse, InfoErrors> {
        let trimmedSymbol = symbol.trimmingByWhitespacesAndNewLines.filter({ character in
            character == ","
        })
        print(trimmedSymbol)
        guard !symbol.trimmingByWhitespacesAndNewLines.isEmpty else {
            return .failure(.noSymbol)
        }
        let formattedCloseDate = closeDate.getFormattedDateString(withFormat: "yyyy-MM-dd")
        let cacheKey = "\(symbol)-\(formattedCloseDate)"
        if let responseFromCache: InfoResponse = cache.getCache(from: .info, with: cacheKey) {
            return .success(responseFromCache)
        }
        let queryItems = [
            "close_date": formattedCloseDate
        ].urlQueryItems
        let result = await networker.getInfo(of: [symbol], with: queryItems)
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
            guard let success = success else {
                return .failure(.generalError)
            }
            if let infoResponseFound = success.first(where: { (key: String, _: InfoResponse) in
                key.uppercased() == symbol.uppercased()
            }) {
                print(infoResponseFound)
            }
            guard let infoValue = success.first?.value else {
                return .failure(.generalError)
            }
            info = infoValue
        }
        cache.setCache(this: info, in: .info, with: cacheKey)
        return .success(info)
    }

}
