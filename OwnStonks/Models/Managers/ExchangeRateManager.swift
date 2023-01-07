//
//  ExchangeRateManager.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Models
import Logster
import Backend
import Foundation

private let logger = Logster(from: ExchangeRateManager.self)

final class ExchangeRateManager: ObservableObject {
    @Published private(set) var exchangeRates: ExchangeRates?

    private let backend: Backend

    init(backend: Backend = .shared) {
        self.backend = backend
    }

    func convert(from money: Money, preferedCurrency: Currencies) -> Money {
        guard let exchangeRates else { return money }

        guard let rate = exchangeRates.ratesMappedByCurrency[money.currency] else {
            logger.warning("Rate for \(money.currency) not fetched yet")
            return money
        }

        return money
    }

    func fetch(preferedCurrency: Currencies) async {
        await benchmark(
            function: {
                logger.info("Fetching exchange rates")
                let result = await backend.forex.getLatest(base: preferedCurrency, symbols: Currencies.allCases)
                var exchangeRates: ExchangeRates?
                switch result {
                case .failure(let failure):
                    logger.error(label: "Failed to fetch exchange rates", error: failure)
                case .success(let success):
                    exchangeRates = success
                }

                if exchangeRates == nil {
                    logger.info("Attempting to access fallback exchange rates")
                    exchangeRates = getFallbackExchangeRates(preferedCurrency: preferedCurrency)
                }

                guard let exchangeRates else {
                    logger.error("No exchange rates found")
                    return
                }

                await setExchangeRates(exchangeRates)
            },
            duration: { duration in
                logger.info("Successfully fetched exchange rates in \((duration) * 1000) ms")
            })
    }

    @MainActor
    private func setExchangeRates(_ exchangeRates: ExchangeRates) {
        self.exchangeRates = exchangeRates
    }

    private func getFallbackExchangeRates(preferedCurrency: Currencies) -> ExchangeRates? {
        guard let cachedExchangeRates = UserDefaults.exchangeRates else { return nil }

        let latestKey = cachedExchangeRates
            .keys
            .sorted(by: { $0.compare($1) == .orderedDescending })
            .first
        guard let latestKey else { return nil }

        return cachedExchangeRates[latestKey]?
            .find(by: \.base, is: preferedCurrency.rawValue)
    }

    private func benchmark<T>(function: () async -> T, duration: (_ duration: TimeInterval) -> Void) async -> T {
        #warning("Duplicate code")
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime
        let result = await function()
        duration(info.systemUptime - begin)
        return result
    }
}
