//
//  ForexClient.swift
//  
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Models
import Swinject
import ForexAPI
import Logster
import ZaWarudo
import Foundation
import ShrimpExtensions

private let logger = Logster(from: ForexClient.self)

public struct ForexClient {
    private let preview: Bool
    private var cachedExchangeRates: [Date: [ExchangeRates]]?

    public init(preview: Bool = false) {
        self.preview = preview
        self.cachedExchangeRates = UserDefaults.exchangeRates
    }

    public func getLatest(base: Currencies, symbols: [Currencies]) async -> ExchangeRates? {
        guard !preview else { return .preview }

        let symbols = symbols.filter({ $0 != base })
        guard !symbols.isEmpty else { return nil }

        let now = Current.date()
        var foundCachedRates: [Currencies: Double] = [:]
        var remainingSymbols = symbols
        let cachedExchangeRates = (cachedExchangeRates ?? [:]).find(where: { $0.key.isSameDay(as: now) })?.value
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
                UserDefaults.exchangeRates = [now: groupedExchangeRatesByBase.values.asArray()]
                logger.info("Got exchange rates for \(base.rawValue) from cache")
                return completeExchangeRates
            } else {
                var newRemainingSymbols: [Currencies] = []
                for symbol in symbols where !foundCachedRatesSymbols.contains(symbol) {
                    newRemainingSymbols = newRemainingSymbols.appended(symbol)
                }
                remainingSymbols = newRemainingSymbols
            }
        }

        if remainingSymbols.isEmpty {
            assertionFailure("Remaining symbols should not be empty!")
        }

        if remainingSymbols != symbols {
            logger.info("Fetching uncached symbols \(remainingSymbols)")
        }

        #warning("Handle error")
        let result = try! await api.latest(base: base, symbols: remainingSymbols).get()

        let completeExchangeRates = ExchangeRates(
            base: base,
            date: result.date,
            rates: result.ratesMappedByCurrency.merged(with: foundCachedRates))
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
        UserDefaults.exchangeRates = [now: groupedExchangeRatesByBase.values.asArray()]

        logger.info("Fetched exchange rates from API")
        return result
    }

    func getCachedResultForLatest(
        cachedExchangeRates: [ExchangeRates],
        base: Currencies,
        symbols: [Currencies]) -> [Currencies: Double] {
            let symbols = symbols.filter({ $0 != base })
            guard !symbols.isEmpty else { return [:] }

            return cachedExchangeRates.reduce([:], { result, exchangeRate in
                guard let exchangeRateBase = exchangeRate.baseCurrency else { return result }

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

    private var api: ForexAPI {
        container.resolve(ForexAPI.self, argument: preview)!
    }
}
