//
//  ValutaConversion.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import ForexKit
import Foundation
import Observation
import KamaalLogger

public enum ValutaConversionErrors: Error {
    case fetchExchangeRatesFailure
}

/// Observable object that manages user valuta exchange rates.
@Observable
public final class ValutaConversion {
    private(set) var rates: ExchangeRates?

    private let forexKit: ForexKit
    private let quickStorage: ValutaConversionQuickStoragable
    private let symbols = Currencies.allCases.filter { currency in !currency.isCryptoCurrency }
    private let logger = KamaalLogger(from: ValutaConversion.self, failOnError: true)

    /// Initializer of ``ValutaConversion/ValutaConversion``.
    public convenience init() {
        let quickStorage = ValutaConversionQuickStorage()
        self.init(quickStorage: quickStorage)
    }

    init(quickStorage: ValutaConversionQuickStoragable) {
        self.forexKit = Self.makeForexKit(withStorage: quickStorage)
        self.quickStorage = quickStorage
    }

    /// Fetch latest exchange rates based on the given currency.
    /// - Parameter currency: The base currency to get the exchange rates for.
    public func fetchExchangeRates(of currency: Currencies) async throws {
        var rates = try await forexKit.getLatest(base: currency, symbols: symbols).get()
        if rates == nil {
            logger.warning("Failed to fetch latest exchange rates, getting fallback instead")
            rates = forexKit.getFallback(base: currency, symbols: symbols)
        } else {
            logger.info("Succesfully fetched exchange rates for \(currency.localized)")
        }
        guard let rates else { throw ValutaConversionErrors.fetchExchangeRatesFailure }

        await setRates(rates)
    }

//    public func exchangeMoney()

    @MainActor
    private func setRates(_ rates: ExchangeRates) {
        self.rates = rates
    }

    private static func makeForexKit(withStorage storage: ValutaConversionQuickStoragable) -> ForexKit {
        var forexKitConfiguration: ForexKitConfiguration?
        if let forexAPIURL = SecretsJSON.shared.content?.forexAPIURL {
            forexKitConfiguration = .init(container: storage, forexBaseURL: forexAPIURL)
        }
        return ForexKit(configuration: forexKitConfiguration ?? ForexKitConfiguration(container: storage))
    }
}
