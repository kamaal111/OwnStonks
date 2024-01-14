//
//  StonksKitCacheStorage.swift
//
//
//  Created by Kamaal M Farah on 06/01/2024.
//

import Foundation
import KamaalUtils
import KamaalExtensions

public protocol StonksKitCacheStorable {
    var infoCache: [Date: [String: StonksTickersInfoResponse]]? { get set }
    var closesCache: [Date: [String: StonksTickersClosesResponse]]? { get set }
}

extension StonksKitCacheStorable {
    mutating func withStonksClosesCache(
        tickers: [String],
        startDate: Date,
        endDate: Date,
        apiCall: (
            _ remainingTickers: [String]
        ) async -> Result<[String: StonksTickersClosesResponse], StonksTickersErrors>
    ) async -> Result<[String: StonksTickersClosesResponse], StonksTickersErrors> {
        let cachedValues = tickers
            .reduce([String: StonksTickersClosesResponse]()) { result, ticker in
                guard let cachedValue = getStonksTickerClosesCache(
                    ticker: ticker,
                    startDate: startDate,
                    endDate: endDate
                ) else { return result }
                return result.merged(with: [ticker: cachedValue])
            }
        let cachedValuesTickers = cachedValues.keys
        let remainingTickers = tickers.filter { ticker in !cachedValuesTickers.contains(ticker) }
        guard !remainingTickers.isEmpty else { return .success(cachedValues) }

        return await apiCall(remainingTickers)
            .map { success in
                for (ticker, closes) in success {
                    setStonksTickerClosesCache(
                        ticker: ticker,
                        startDate: startDate,
                        endDate: endDate,
                        closes: closes
                    )
                }
                return success.merged(with: cachedValues)
            }
    }

    func getStonksInfoCache(ticker: String, date: Date?) -> StonksTickersInfoResponse? {
        guard let infoCache else { return nil }

        if let date {
            return infoCache[rootKey(date: date)]?[ticker]
        }

        return infoCache.first(where: { value in (value.value[ticker]) != nil })?.value[ticker]
    }

    mutating func setStonksInfoCache(ticker: String, date: Date, info: StonksTickersInfoResponse) {
        let rootKey = rootKey(date: date)
        if infoCache?[rootKey] == nil {
            infoCache = [rootKey: [ticker: info]]
        } else {
            infoCache![rootKey]![ticker] = info
        }
    }

    private func getStonksTickerClosesCache(
        ticker: String,
        startDate: Date,
        endDate: Date
    ) -> StonksTickersClosesResponse? {
        guard let closes = closesCache?[rootKey(date: endDate)] else { return nil }

        return closes[stonksTickerClosesKey(ticker: ticker, startDate: startDate)]
    }

    private mutating func setStonksTickerClosesCache(
        ticker: String,
        startDate: Date,
        endDate: Date,
        closes: StonksTickersClosesResponse
    ) {
        let rootKey = rootKey(date: endDate)
        if closesCache?[rootKey] == nil {
            closesCache = [
                rootKey: [stonksTickerClosesKey(ticker: ticker, startDate: startDate): closes],
            ]
        } else {
            closesCache![rootKey]![stonksTickerClosesKey(ticker: ticker, startDate: startDate)] = closes
        }
        for key in closesCache?.keys.asArray() ?? [] where key != rootKey {
            closesCache?[key] = nil
        }
    }

    private func stonksTickerClosesKey(ticker: String, startDate: Date) -> String {
        "\(ticker)-\(startDate.dayNumberOfWeek)-\(startDate.weekNumber)-\(startDate.yearNumber)"
    }

    private func rootKey(date: Date) -> Date {
        date.beginningOfDay
    }
}

struct StonksKitCacheStorage: StonksKitCacheStorable {
    @UserDefaultsObject(key: makeKey("info_cache"))
    var infoCache: [Date: [String: StonksTickersInfoResponse]]?

    @UserDefaultsObject(key: makeKey("ticker_closes"))
    var closesCache: [Date: [String: StonksTickersClosesResponse]]?

    private static func makeKey(_ key: String) -> String {
        "io.kamaal.StonksKit.\(key)"
    }
}

extension Date {
    fileprivate var beginningOfDay: Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        var components = calendar.dateComponents(unitFlags, from: self)
        components.timeZone = TimeZone(abbreviation: "UTC")
        return calendar.date(from: components)!
    }
}
