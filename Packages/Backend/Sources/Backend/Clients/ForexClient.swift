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
    private var cachedExchangeRates: [Date: ExchangeRates]?

    public init(preview: Bool = false) {
        self.preview = preview
        self.cachedExchangeRates = UserDefaults.exchangeRates
    }

    public func getLatest() async -> ExchangeRates? {
        let now = Current.date()
        for (date, exchangeRates) in cachedExchangeRates ?? [:] where date.isSameDay(as: now) {
            logger.info("returning chached exchange rates")
            return exchangeRates
        }

        #warning("Handle error")
        let result = try! await api.latest().get()
        UserDefaults.exchangeRates = [now: result]
        return result
    }

    private var api: ForexAPI {
        container.resolve(ForexAPI.self, argument: preview)!
    }
}
