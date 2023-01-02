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
        apiCall: (_ base: Currencies, _ symbols: [Currencies]) async -> Result<ExchangeRates, ForexAPI.Errors>) async -> Result<ExchangeRates?, ForexAPI.Errors> {
            let symbols = symbols.filter({ $0 != base })
            guard !symbols.isEmpty else { return .success(.none) }

            let now = Current.date()
            var foundCachedRates: [Currencies: Double] = [:]
            var remainingSymbols = symbols
            let cachedExchangeRates = (container.exchangeRates ?? [:])
                .find(where: { $0.key.isSameDay(as: now) })?
                .value
            if let cachedExchangeRates {
                foundCachedRates = getCachedResultForLatest(
                    cachedExchangeRates: cachedExchangeRates,
                    base: base,
                    symbols: symbols)
                let foundCachedRatesSymbols = foundCachedRates
                    .map(\.key)
                    .sorted(by: \.rawValue, using: .orderedAscending)

                if foundCachedRatesSymbols == symbols.sorted(by: \.rawValue, using: .orderedAscending) {
                    let completeExchangeRates = ExchangeRates(base: base, date: now, rates: foundCachedRates)
                    var groupedExchangeRatesByBase: [Currencies: ExchangeRates] = Dictionary(
                        grouping: cachedExchangeRates.filter({ $0.baseCurrency != nil }),
                        by: \.baseCurrency!)
                        .reduce([:], {
                            var result = $0
                            if let rate = $1.value.first {
                                result[$1.key] = rate
                            }
                            return result
                        })
                    groupedExchangeRatesByBase[base] = completeExchangeRates
                    container.exchangeRates = [now: groupedExchangeRatesByBase.values.asArray()]
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
                .map({
                    ExchangeRates(
                        base: base,
                        date: $0.date,
                        rates: $0.ratesMappedByCurrency.merged(with: foundCachedRates))
                })

            let completeExchangeRates: ExchangeRates
            switch result {
            case .failure(let failure):
                return .failure(failure)
            case .success(let success):
                completeExchangeRates = success
            }

            var groupedExchangeRatesByBase: [Currencies: ExchangeRates] = Dictionary(
                grouping: (cachedExchangeRates ?? []).filter({ $0.baseCurrency != nil }),
                by: \.baseCurrency!)
                .reduce([:], {
                    var result = $0
                    if let rate = $1.value.first {
                        result[$1.key] = rate
                    }
                    return result
                })
            groupedExchangeRatesByBase[base] = completeExchangeRates
            container.exchangeRates = [now: groupedExchangeRatesByBase.values.asArray()]

            logger.info("Fetched exchange rates from API")
            return .success(completeExchangeRates)
        }

    private func getCachedResultForLatest(
        cachedExchangeRates: [ExchangeRates],
        base: Currencies,
        symbols: [Currencies]) -> [Currencies: Double] {
            return cachedExchangeRates.reduce([:], { result, exchangeRate in
                guard let exchangeRateBase = exchangeRate.baseCurrency else {
                    assertionFailure("Unsupported currency \(exchangeRate.base)")
                    return result
                }

                let ratesMappedByCurrency = exchangeRate.ratesMappedByCurrency
                var result = result
                if exchangeRateBase == base {
                    symbols.forEach({ symbol in
                        guard let rate = ratesMappedByCurrency[symbol] else { return }

                        result[symbol] = rate
                    })

                    return result
                }

                guard let symbol = symbols.find(where: { $0 == exchangeRateBase }),
                      let rate = ratesMappedByCurrency[base] else { return result }

                result[symbol] = Double((1 / rate).toFixed(4))
                return result
            })
        }
}
