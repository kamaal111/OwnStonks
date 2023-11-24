//
//  ForexCacheUtil.swift
//
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation

struct ForexKitConfiguration {
    let skipCaching: Bool

    init(skipCaching: Bool) {
        self.skipCaching = skipCaching
    }

    init() {
        self.init(skipCaching: false)
    }
}

class ForexCacheUtil {
    var container: CacheContainerable
    let configuration: ForexKitConfiguration

    init(container: CacheContainerable = CacheContainer(), configuration: ForexKitConfiguration = .init()) {
        self.container = container
        self.configuration = configuration
    }

    func cacheLatest(
        base: Currencies,
        symbols: [Currencies],
        apiCall: (_ base: Currencies, _ symbols: [Currencies]) async -> Result<ExchangeRates, ForexAPI.Errors>
    ) async
        -> Result<ExchangeRates?, ForexAPI.Errors> {
        let symbols = symbols.filter { $0 != base }
        guard !symbols.isEmpty else { return .success(nil) }

        if configuration.skipCaching {
            return await apiCall(base, symbols)
                .map { success -> ExchangeRates? in
                    success
                }
        }

        let cacheKey = Date().hashed
        var foundCachedRates: [Currencies: Double] = [:]
        var remainingSymbols = symbols
        let cachedExchangeRates = container.exchangeRates?
            .first(where: { $0.key.hashed == cacheKey })?
            .value
        if let cachedExchangeRates {
            foundCachedRates = getCachedResultForLatest(
                cachedExchangeRates: cachedExchangeRates,
                base: base,
                symbols: symbols
            )
            let foundCachedRatesSymbols = foundCachedRates
                .map(\.key)
                .sorted(by: { $0.rawValue < $1.rawValue })
            if foundCachedRatesSymbols == symbols.sorted(by: { $0.rawValue < $1.rawValue }) {
                let completeExchangeRates = ExchangeRates(base: base, date: cacheKey, rates: foundCachedRates)
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
                container.exchangeRates = [cacheKey: Array(groupedExchangeRatesByBase.values)]

                return .success(completeExchangeRates)
            } else {
                var newRemainingSymbols: [Currencies] = []
                for symbol in symbols where !foundCachedRatesSymbols.contains(symbol) {
                    newRemainingSymbols.append(symbol)
                }
                remainingSymbols = newRemainingSymbols
            }
        }

        assert(!remainingSymbols.isEmpty, "Remaining symbols should not be empty!")

        let result = await apiCall(base, remainingSymbols)
            .map {
                var ratesMappedByCurrency = $0.ratesMappedByCurrency
                for (key, value) in foundCachedRates {
                    ratesMappedByCurrency[key] = value
                }
                return ExchangeRates(
                    base: base,
                    date: $0.date,
                    rates: ratesMappedByCurrency
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
        container.exchangeRates = [cacheKey: Array(groupedExchangeRatesByBase.values)]

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
            if let exchangeRateWithSameBase = exchangeRates.first(where: { $0.base == base.rawValue }) {
                let ratesMappedByCurrency = exchangeRateWithSameBase.ratesMappedByCurrency
                for symbol in symbols {
                    if let rate = ratesMappedByCurrency[symbol] {
                        rates[symbol] = rate
                    }
                }

                let sortedRatesSymbols = rates.keys.sorted(by: { $0.rawValue < $1.rawValue })
                let sortedSymbols = symbols.sorted(by: { $0.rawValue < $1.rawValue })
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
                guard let symbol = remainingSymbols.first(where: { $0 == exchangeRateBase }),
                      let rate = exchangeRate.ratesMappedByCurrency[base] else { continue }

                rates[symbol] = Double(String(format: "%.\(4)f", 1 / rate))
            }

            let sortedRatesSymbols = rates.keys.sorted(by: { $0.rawValue < $1.rawValue })
            let sortedSymbols = symbols.sorted(by: { $0.rawValue < $1.rawValue })
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

            guard let symbol = symbols.first(where: { $0 == exchangeRateBase }),
                  let rate = ratesMappedByCurrency[base] else { return result }

            result[symbol] = Double(String(format: "%.\(4)f", 1 / rate))
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
