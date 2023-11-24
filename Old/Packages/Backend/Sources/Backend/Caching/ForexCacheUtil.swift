//
//  ForexCacheUtil.swift
//
//
//  Created by Kamaal M Farah on 02/01/2023.
//

import Models
import Logster
import ZaWarudo
import ForexAPI
import Foundation
import Environment
import ShrimpExtensions

class ForexCacheUtil {
    var container: CacheContainerable

    private let logger = Logster(from: ForexCacheUtil.self)

    init(container: CacheContainerable = CacheContainer()) {
        self.container = container
    }

    func cacheLatest(
        base: Currencies,
        symbols: [Currencies],
        apiCall: (_ base: Currencies, _ symbols: [Currencies]) async -> Result<ExchangeRates, ForexAPI.Errors>
    ) async
        -> Result<ExchangeRates?, ForexAPI.Errors> {
        let symbols = symbols.filter { $0 != base }
        guard !symbols.isEmpty else { return .success(.none) }

        if Environment.CommandLineArguments.skipForexCaching.enabled {
            return await apiCall(base, symbols)
                .map { success -> ExchangeRates? in
                    success
                }
        }

        let now = Current.date()
        var foundCachedRates: [Currencies: Double] = [:]
        var remainingSymbols = symbols
        let cachedExchangeRates = (container.exchangeRates ?? [:])
            .find(where: { $0.key.isSameDay(as: now.hashed) })?
            .value
        if let cachedExchangeRates {
            foundCachedRates = getCachedResultForLatest(
                cachedExchangeRates: cachedExchangeRates,
                base: base,
                symbols: symbols
            )
            let foundCachedRatesSymbols = foundCachedRates
                .map(\.key)
                .sorted(by: \.rawValue, using: .orderedAscending)

            if foundCachedRatesSymbols == symbols.sorted(by: \.rawValue, using: .orderedAscending) {
                let completeExchangeRates = ExchangeRates(base: base, date: now, rates: foundCachedRates)
                var groupedExchangeRatesByBase: [Currencies: ExchangeRates] = Dictionary(
                    grouping: cachedExchangeRates.filter { $0.baseCurrency != nil },
                    by: \.baseCurrency!
                )
                .reduce([:]) {
                    var result = $0
                    if let rate = $1.value.first {
                        result[$1.key] = rate
                    }
                    return result
                }
                groupedExchangeRatesByBase[base] = completeExchangeRates
                container.exchangeRates = [now.hashed: groupedExchangeRatesByBase.values.asArray()]
                logger.info("Got exchange rates for \(base.rawValue) from cache")
                return .success(completeExchangeRates)
            } else {
                var newRemainingSymbols: [Currencies] = []
                for symbol in symbols where !foundCachedRatesSymbols.contains(symbol) {
                    newRemainingSymbols = newRemainingSymbols.appended(symbol)
                }
                remainingSymbols = newRemainingSymbols
            }
        }

        assert(!remainingSymbols.isEmpty, "Remaining symbols should not be empty!")

        if remainingSymbols != symbols {
            logger.info("Fetching uncached symbols \(remainingSymbols)")
        }

        let result = await apiCall(base, remainingSymbols)
            .map {
                ExchangeRates(
                    base: base,
                    date: $0.date,
                    rates: $0.ratesMappedByCurrency.merged(with: foundCachedRates)
                )
            }

        let completeExchangeRates: ExchangeRates
        switch result {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            completeExchangeRates = success
        }

        var groupedExchangeRatesByBase: [Currencies: ExchangeRates] = Dictionary(
            grouping: (cachedExchangeRates ?? []).filter { $0.baseCurrency != nil },
            by: \.baseCurrency!
        )
        .reduce([:]) {
            var result = $0
            if let rate = $1.value.first {
                result[$1.key] = rate
            }
            return result
        }
        groupedExchangeRatesByBase[base] = completeExchangeRates
        container.exchangeRates = [now.hashed: groupedExchangeRatesByBase.values.asArray()]

        logger.info("Fetched exchange rates from API")
        return .success(completeExchangeRates)
    }

    func getFallback(base: Currencies, symbols: [Currencies]) -> ExchangeRates? {
        guard let cachedExchangeRates = container.exchangeRates else { return nil }

        let symbols = symbols.filter { $0 != base }
        guard !symbols.isEmpty else { return nil }

        let sortedKeys = cachedExchangeRates
            .keys
            .sorted(by: { $0.compare($1) == .orderedDescending })

        for key in sortedKeys {
            let exchangeRates = cachedExchangeRates[key]!
            var rates: [Currencies: Double] = [:]
            if let exchangeRateWithSameBase = exchangeRates.find(by: \.base, is: base.rawValue) {
                let ratesMappedByCurrency = exchangeRateWithSameBase.ratesMappedByCurrency
                for symbol in symbols {
                    if let rate = ratesMappedByCurrency[symbol] {
                        rates[symbol] = rate
                    }
                }

                let sortedRatesSymbols = rates.keys.sorted(by: \.rawValue, using: .orderedDescending)
                let sortedSymbols = symbols.sorted(by: \.rawValue, using: .orderedDescending)
                if sortedRatesSymbols == sortedSymbols {
                    return exchangeRateWithSameBase
                }
            }

            for exchangeRate in exchangeRates {
                guard let exchangeRateBase = exchangeRate.baseCurrency else {
                    assertionFailure("Failed to get base currency")
                    continue
                }

                let remainingSymbols = symbols.filter { !rates.keys.contains($0) }
                guard let symbol = remainingSymbols.find(where: { $0 == exchangeRateBase }),
                      let rate = exchangeRate.ratesMappedByCurrency[base] else { continue }

                rates[symbol] = Double((1 / rate).toFixed(4))
            }

            let sortedRatesSymbols = rates.keys.sorted(by: \.rawValue, using: .orderedDescending)
            let sortedSymbols = symbols.sorted(by: \.rawValue, using: .orderedDescending)
            if sortedRatesSymbols == sortedSymbols {
                return ExchangeRates(base: base, date: key, rates: rates)
            }
        }

        return nil
    }

    private func getCachedResultForLatest(
        cachedExchangeRates: [ExchangeRates],
        base: Currencies,
        symbols: [Currencies]
    ) -> [Currencies: Double] {
        cachedExchangeRates.reduce([:]) { result, exchangeRate in
            guard let exchangeRateBase = exchangeRate.baseCurrency else {
                assertionFailure("Unsupported currency \(exchangeRate.base)")
                return result
            }

            let ratesMappedByCurrency = exchangeRate.ratesMappedByCurrency
            var result = result
            if exchangeRateBase == base {
                symbols.forEach { symbol in
                    guard let rate = ratesMappedByCurrency[symbol] else { return }

                    result[symbol] = rate
                }

                return result
            }

            guard let symbol = symbols.find(where: { $0 == exchangeRateBase }),
                  let rate = ratesMappedByCurrency[base] else { return result }

            result[symbol] = Double((1 / rate).toFixed(4))
            return result
        }
    }
}

extension Date {
    var hashed: Date {
        let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: self)
        guard let hashedDate = Calendar.current.date(from: dateComponents) else {
            assertionFailure("Failed to hash date")
            return Date()
        }

        return hashedDate
    }
}
