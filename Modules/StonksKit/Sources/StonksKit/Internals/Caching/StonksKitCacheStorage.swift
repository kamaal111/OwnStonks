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
    var stonksAPIGetCache: [URL: Data]? { get set }
    var closesCache: [Date: [String: [Date: Double]]]? { get set }
}

extension StonksKitCacheStorable {
    func getStonksAPIGetCache<T: Decodable>(from url: URL, ofType type: T.Type) throws -> T? {
        guard let cachedValue = stonksAPIGetCache?[url] else { return nil }

        return try JSONDecoder().decode(type, from: cachedValue)
    }

    mutating func setStonksAPIGetCache(on url: URL, data: some Encodable) throws {
        let data = try JSONEncoder().encode(data)
        if stonksAPIGetCache == nil {
            stonksAPIGetCache = [url: data]
        } else {
            stonksAPIGetCache![url] = data
        }
    }

    func getStonksTickerClosesCache(ticker: String, startDate: Date, endDate: Date) -> [Date: Double]? {
        guard let closes = closesCache?[stonksTickerClosesMainKey(endDate: endDate)] else { return nil }

        return closes[stonksTickerClosesKey(ticker: ticker, startDate: startDate)]
    }

    mutating func setStonksTickerClosesCache(ticker: String, startDate: Date, endDate: Date, closes: [Date: Double]) {
        let mainKey = stonksTickerClosesMainKey(endDate: endDate)
        if closesCache?[mainKey] == nil {
            closesCache = [
                mainKey: [stonksTickerClosesKey(ticker: ticker, startDate: startDate): closes],
            ]
        } else {
            closesCache![mainKey]![stonksTickerClosesKey(ticker: ticker, startDate: startDate)] = closes
        }
        for key in closesCache?.keys.asArray() ?? [] where key != mainKey {
            closesCache?[key] = nil
        }
    }

    private func stonksTickerClosesKey(ticker: String, startDate: Date) -> String {
        "\(ticker)-\(startDate.dayNumberOfWeek)-\(startDate.weekNumber)-\(startDate.yearNumber)"
    }

    private func stonksTickerClosesMainKey(endDate: Date) -> Date {
        endDate.beginningOfDay
    }
}

struct StonksKitCacheStorage: StonksKitCacheStorable {
    @UserDefaultsObject(key: "io.kamaal.StonksKit.get_cache")
    var stonksAPIGetCache: [URL: Data]?

    @UserDefaultsObject(key: "io.kamaal.StonksKit.ticker_closes_cache")
    var closesCache: [Date: [String: [Date: Double]]]?
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
