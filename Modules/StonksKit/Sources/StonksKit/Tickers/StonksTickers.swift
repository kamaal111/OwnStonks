//
//  StonksTickers.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import KamaalUtils
import KamaalNetworker
import KamaalExtensions

public final class StonksTickers: StonksKitClient {
    public func info(
        for ticker: String,
        date: Date
    ) async -> Result<StonksTickersInfoResponse, StonksTickersErrors> {
        let url = clientURL
            .appending(path: "info")
            .appending(path: ticker)
            .appending(queryItems: [
                .init(name: "date", value: formatDate(date)),
            ])
        return await get(url: url, enableCaching: true)
            .mapError(StonksTickersErrors.fromNetworker(_:))
    }

    public func closes(
        for ticker: String,
        startDate: Date
    ) async -> Result<StonksTickersClosesResponse, StonksTickersErrors> {
        let endDate = Date()
        if let cachedValue = cacheStorage.getStonksTickerClosesCache(
            ticker: ticker,
            startDate: startDate,
            endDate: endDate
        ) {
            return .success(cachedValue)
        }
        let url = clientURL
            .appending(path: "closes")
            .appending(path: ticker)
            .appending(queryItems: [
                .init(name: "start_date", value: formatDate(startDate)),
                .init(name: "end_date", value: formatDate(endDate)),
            ])
        let result: Result<StonksTickersClosesResponse, KamaalNetworker.Errors> = await get(
            url: url,
            enableCaching: false
        )
        let closes: StonksTickersClosesResponse
        switch result {
        case let .failure(failure): return .failure(.fromNetworker(failure))
        case let .success(success): closes = success
        }
        cacheStorage.setStonksTickerClosesCache(
            ticker: ticker,
            startDate: startDate,
            endDate: endDate,
            closes: closes
        )

        return .success(closes)
    }

    public func tickerIsValid(_ ticker: String) async -> Result<Bool, StonksTickersErrors> {
        if let cachePath = getAnyInfoCacheKey(forTicker: ticker),
           (try? cacheStorage.getStonksAPIGetCache(from: cachePath, ofType: StonksTickersInfoResponse.self)) != nil {
            return .success(true)
        }

        let result = await info(for: ticker, date: Date())
        let isFound: Bool
        switch result {
        case let .failure(failure):
            switch failure {
            case .notFound: isFound = false
            case .badRequest, .general: return .failure(failure)
            }
        case .success: isFound = true
        }
        return .success(isFound)
    }

    private func getAnyInfoCacheKey(forTicker ticker: String) -> URL? {
        cacheStorage.stonksAPIGetCache?
            .keys
            .first(where: { key in
                var path = key.absoluteString
                    .split(separator: "/")
                    .suffix(3)
                    .joined(separator: "/")
                guard path.starts(with: "tickers/info") else { return false }

                if path.contains("?") {
                    path = path
                        .split(separator: "?")
                        .dropLast()
                        .joined(separator: "?")
                }

                guard let symbol = path.split(separator: "/").last else { return false }

                return symbol == ticker
            })
    }

    private func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    private var clientURL: URL {
        Self.BASE_URL
            .appending(path: "tickers")
    }

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
}
